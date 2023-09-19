import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:example/models/adjustment.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/adjustment_screen.dart';
import 'package:example/services/adjustment.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfAdjusmentReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Adjustment> _adjustments = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    AdjustmentService _adjustmentService = AdjustmentService();
    List<List> newTableData = [];
    DateTime? _date;
    String _formateDate = "";
    String formateDateStart = formatDate(dateStart, [dd, " ", MM, " ", yyyy]);
    String formateDateEnd = formatDate(dateEnd, [dd, " ", MM, " ", yyyy]);

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _adjustmentService.getAdjustments();
    _adjustments = res3.data;

    void tableData(Adjustment adj) {
      newTableData.add([
        adj.adjustmentCode,
        adj.adjustmentDate!.substring(0, 10),
        adj.material != null
            ? "Bahan Baku"
            : adj.product != null
                ? "Produk"
                : adj.fabricatingMaterial != null
                    ? "Barang 1/2 Jadi"
                    : "",
        adj.product?.productName ??
            adj.material?.materialName ??
            adj.fabricatingMaterial?.fabricatingMaterialName,
        adj.formerQty,
        adj.adjustedQty,
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Kode Penyesuain":
          _adjustments.forEach((adjustment) {
            if (adjustment.adjustmentCode!.contains(value.toString())) {
              tableData(adjustment);
            }
          });
          break;
        case "Nama Item":
          _adjustments.forEach((adjustment) {
            if (adjustment.material != null &&
                    adjustment.material!.materialName!
                        .toLowerCase()
                        .contains(value.toLowerCase().toString()) ||
                adjustment.fabricatingMaterial != null &&
                    adjustment.fabricatingMaterial!.fabricatingMaterialName!
                        .toLowerCase()
                        .contains(value.toLowerCase().toString()) ||
                adjustment.product != null &&
                    adjustment.product!.productName!
                        .toLowerCase()
                        .contains(value.toLowerCase())) {
              tableData(adjustment);
            }
          });
          break;
        case "Kategori":
          _adjustments.forEach((adjustment) {
            if (adjustment.material != null &&
                    "bahan baku".contains(value.toLowerCase()) ||
                adjustment.product != null &&
                    "produk".contains(value.toLowerCase()) ||
                adjustment.fabricatingMaterial != null &&
                    "barang 1/2 jadi".contains(value.toLowerCase())) {
              tableData(adjustment);
            }
          });
          break;
        default:
      }
    } else {
      print("Date Start $dateStart");
      print("Date End $dateEnd");
      _adjustments.forEach((adj) {
        _formateDate = adj.adjustmentDate!.substring(0, 10);
        _date = DateTime.parse(_formateDate);

        if ((_date!.isAtSameMomentAs(dateStart) ||
                _date!.isAtSameMomentAs(dateEnd)) ||
            (_date!.isBefore(dateEnd) && _date!.isAfter(dateStart))) {
          tableData(adj);
        }
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode Penyesuain',
      'Tanggal Penyesuaian',
      'Kategori',
      'Nama Item',
      'Kuantiti Sistem',
      'Kuantiti Disesuaikan',
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
                      'Adjustment Report',
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
              cellStyle: pw.TextStyle(fontSize: 8),
              cellPadding: pw.EdgeInsets.only(top: 2.0, bottom: 2.0),
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
        name: 'my_adjustment_report.pdf', pdf: pdf);
  }
}
