import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:example/models/material_purchase.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/material_purchase_screen.dart';
import 'package:example/services/material_purchase.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfMaterialPurchaseReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<MaterialPurchase> _materialPurchases = [];
    List<MaterialPurchase> _materialLength = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    MaterialPurchaseService _materialPurchaseService =
        MaterialPurchaseService();
    List<List> newTableData = [];
    DateTime? _date;
    String _formateDate = "";
    String formateDateStart = formatDate(dateStart, [dd, " ", MM, " ", yyyy]);
    String formateDateEnd = formatDate(dateEnd, [dd, " ", MM, " ", yyyy]);

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _materialPurchaseService.getMaterialPurchases();
    _materialPurchases = res3.data;
    var res4 = await _materialPurchaseService.getMaterialPurchaseGrouped();
    _materialLength = res4.data;
    int inc = 0;

    void tableData(MaterialPurchase mat_i, MaterialPurchase mat_j) {
      if (mat_i.materialPurchaseCode == mat_j.materialPurchaseCode) {
        inc += 1;
        if (inc == 1) {
          newTableData.add([
            mat_j.materialPurchaseCode,
            mat_j.supplier!.supplierName,
            "- ${mat_j.product?.productName ?? mat_j.fabricatingMaterial?.fabricatingMaterialName ?? mat_j.material?.materialName}",
            "- ${mat_j.materialPurchaseQty} (${mat_j.material?.materialUnit ?? mat_j.fabricatingMaterial?.fabricatingMaterialUnit})",
            mat_j.materialPurchaseDate!.substring(0, 10),
          ]);
        } else {
          newTableData.add([
            "",
            "",
            "- ${mat_j.product?.productName ?? mat_j.fabricatingMaterial?.fabricatingMaterialName ?? mat_j.material?.materialName}",
            "- ${mat_j.materialPurchaseQty} (${mat_j.material?.materialUnit ?? mat_j.fabricatingMaterial?.fabricatingMaterialUnit ?? "Pcs"})",
            ""
          ]);
        }
      } else {
        inc = 0;
      }
    }

    for (int i = 0; i < _materialLength.length; i++) {
      for (int j = 0; j < _materialPurchases.length; j++) {
        if (value.isNotEmpty) {
          print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());
          switch (filter) {
            case "Kode Pembelian":
              if (_materialPurchases[j]
                  .materialPurchaseCode!
                  .toLowerCase()
                  .contains(value.toString().toLowerCase())) {
                tableData(_materialLength[i], _materialPurchases[j]);
              }
              break;
            case "Pemasok":
              if (_materialPurchases[j]
                  .supplier!
                  .supplierName!
                  .toLowerCase()
                  .contains(value.toString().toLowerCase())) {
                tableData(_materialLength[i], _materialPurchases[j]);
              }
              break;
            //   case "Barang":
            //   if (_materialPurchases[j].material != null &&
            //           _materialPurchases[j].material!.materialName!
            //               .toLowerCase()
            //               .contains(value.toLowerCase().toString()) ||
            //       _materialPurchases[j].fabricatingMaterial != null &&
            //           _materialPurchases[j]
            //               .fabricatingMaterial!.fabricatingMaterialName!
            //               .toLowerCase()
            //               .contains(value.toLowerCase().toString())) {
            //     tableData(_materialLength[i], _materialPurchases[j]);
            //   }
            // break;
            default:
          }
        } else {
          _formateDate =
              _materialLength[i].materialPurchaseDate!.substring(0, 10);
          _date = DateTime.parse(_formateDate);
          if ((_date.isAtSameMomentAs(dateStart) ||
                  _date.isAtSameMomentAs(dateEnd)) ||
              (_date.isBefore(dateEnd) && _date.isAfter(dateStart))) {
            tableData(_materialLength[i], _materialPurchases[j]);
          }
        }
      }
    }

    final tableHeaders = [
      'Kode Pembelian',
      'Pemasok',
      'Barang',
      'Kuantiti Pembelian',
      'Tanggal Pembelian',
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
                      'Material Purchase Report',
                      style: pw.TextStyle(
                        fontSize: 17.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      _profile.companyName!,
                      style: const pw.TextStyle(
                        fontSize: 15.0,
                        color: PdfColors.grey700,
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
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
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
        name: 'my_materialPurchase_report.pdf', pdf: pdf);
  }
}
