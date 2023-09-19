import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:example/models/production.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/production_screen.dart';
import 'package:example/services/production.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfProductionReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();
    List<Production> _backupProductions = [];
    List<Production> _productions = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    ProductionService _productionService = ProductionService();
    List<List> newTableData = [];
    DateTime? _dateProduction;
    String _formateDate = "";
    String formateDateStart = formatDate(dateStart, [dd, " ", MM, " ", yyyy]);
    String formateDateEnd = formatDate(dateEnd, [dd, " ", MM, " ", yyyy]);

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _productionService.getProduction();
    _productions = res3.data;

    void tableData(Production pro) {
      newTableData.add([
        pro.productionCode,
        pro.productionDate!.substring(0, 10),
        pro.product?.productName ??
            pro.fabricatingMaterial?.fabricatingMaterialName,
        pro.product == null ? "No Type" : pro.product!.type!.typeName,
        pro.productionQty,
        pro.productionDesc == null ? "No Desc" : pro.productionDesc,
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Nomor Produksi":
          _productions.forEach((production) {
            if (production.productionCode!.contains(value.toString())) {
              tableData(production);
            }
          });
          break;
        case "Barang":
          _productions.forEach((production) {
            if (production.product != null &&
                    production.product!.productName!
                        .toLowerCase()
                        .contains(value.toLowerCase().toString()) ||
                production.fabricatingMaterial != null &&
                    production.fabricatingMaterial!.fabricatingMaterialName!
                        .toLowerCase()
                        .contains(value.toLowerCase().toString())) {
              tableData(production);
            }
          });
          break;
        case "Jenis Barang":
          _productions.forEach((production) {
            if (production.product != null &&
                production.product!.type!.typeName!
                    .toLowerCase()
                    .contains(value.toLowerCase().toString())) {
              tableData(production);
            }
          });
          break;
        case "Kuantiti Produksi":
          _productions.forEach((production) {
            if (production.productionQty!.contains(value.toString())) {
              tableData(production);
            }
          });
          break;
        default:
      }
    } else if (dateEnd != null && dateStart != null) {
      print("Date Start $dateStart");
      print("Date End $dateEnd");
      _productions.forEach((production) {
        _formateDate = production.productionDate!.substring(0, 10);
        _dateProduction = DateTime.parse(_formateDate);

        if ((_dateProduction!.isAtSameMomentAs(dateStart) ||
                _dateProduction!.isAtSameMomentAs(dateEnd)) ||
            (_dateProduction!.isBefore(dateEnd) &&
                _dateProduction!.isAfter(dateStart))) {
          tableData(production);
        }
      });
      // _productions = _backupProductions;
      // _productions = _productions.where((production) {
      //   _formateDate = production.productionDate!.substring(0, 10);
      //   _dateProduction = DateTime.parse(_formateDate);

      //   return (_dateProduction!.isAtSameMomentAs(dateStart) ||
      //           _dateProduction!.isAtSameMomentAs(dateEnd)) ||
      //       (_dateProduction!.isBefore(dateEnd) &&
      //           _dateProduction!.isAfter(dateStart));
      // }).toList();

      // _productions.forEach((production) {
      //   tableData(production);
      // });
    }
    // else {
    //   _productions.forEach((production) {
    //     tableData(production);
    //   });
    // }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Nomor Produksi',
      'Tanggal Produksi',
      'Barang',
      'Jenis Barang',
      'Kuantiti Produksi',
      'Keterangan Produksi',
    ];

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Row(
              children: [
                pw.Image(
                  pw.MemoryImage(iconImage),
                  height: 72,
                  width: 72,
                ),
                pw.SizedBox(width: 1 * PdfPageFormat.mm),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Production Report',
                      style: pw.TextStyle(
                        fontSize: 15.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      _profile.companyName!,
                      style: const pw.TextStyle(
                        fontSize: 12.0,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      "${formateDateStart} - ${formateDateEnd}",
                      style: const pw.TextStyle(
                        fontSize: 10.0,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),

            ///
            /// PDF Table Create
            ///
            pw.Table.fromTextArray(
              headers: tableHeaders,
              data: newTableData,
              border: null,
              headerHeight: 25.0,
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 5.0,
              cellPadding: pw.EdgeInsets.only(top: 2.0, bottom: 2.0),
              cellStyle: pw.TextStyle(fontSize: 8),
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
              },
            ),
            pw.Divider(),
          ];
        },
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Text(
                _profile.companyName!,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Alamat: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    _profile.companyAddress!,
                  ),
                ],
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Email: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    _profile.companyEmail!,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // n += 1;
    return FileHandleApi.saveDocument(
        name: 'my_production_report.pdf', pdf: pdf);
  }
}
