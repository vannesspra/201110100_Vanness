import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:example/models/material_spending.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/material_spending.dart';
import 'package:example/services/material_spending.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfMaterialSpendingReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<MaterialSpending> _materialSpendings = [];
    List<MaterialSpending> _materialLength = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    MaterialSpendingService _materialSpendingService =
        MaterialSpendingService();
    List<List> newTableData = [];
    DateTime? _date;
    String _formateDate = "";
    String formateDateStart = formatDate(dateStart, [dd, " ", MM, " ", yyyy]);
    String formateDateEnd = formatDate(dateEnd, [dd, " ", MM, " ", yyyy]);

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _materialSpendingService.getMaterialSpendings();
    _materialSpendings = res3.data;
    var res4 = await _materialSpendingService.getMaterialSpendingGrouped();
    _materialLength = res4.data;

    int inc = 0;

    void tableData(MaterialSpending mat_i, MaterialSpending mat_j) {
      if (mat_i.materialSpendingCode == mat_j.materialSpendingCode) {
        inc += 1;
        if (inc == 1) {
          newTableData.add([
            mat_j.materialSpendingCode,
            "- ${mat_j.material?.materialName ?? mat_j.fabricatingMaterial?.fabricatingMaterialName}",
            "- ${mat_j.materialSpendingQty} (${mat_j.material?.materialUnit ?? mat_j.fabricatingMaterial?.fabricatingMaterialUnit ?? "Pcs"})",
            mat_j.materialSpendingDate!.substring(0, 10)
          ]);
        } else {
          newTableData.add([
            "",
            "- ${mat_j.material?.materialName ?? mat_j.fabricatingMaterial?.fabricatingMaterialName}",
            "- ${mat_j.materialSpendingQty} (${mat_j.material?.materialUnit ?? mat_j.fabricatingMaterial?.fabricatingMaterialUnit ?? "Pcs"})",
            ""
          ]);
        }
      } else {
        inc = 0;
      }
    }

    // if (value.isNotEmpty) {
    //   print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

    //   switch (filter) {
    //     case "Kode Pengeluaran Barang":
    //       _materialSpendings.forEach((MaterialSpending) {
    //         if (MaterialSpending.materialSpendingCode!
    //             .contains(value.toString())) {
    //           tableData(MaterialSpending);
    //         }
    //       });
    //       break;
    //     case "Barang":
    //       _materialSpendings.forEach((MaterialSpending) {
    //         if (MaterialSpending.material != null &&
    //                 MaterialSpending.material!.materialName!
    //                     .toLowerCase()
    //                     .contains(value.toLowerCase().toString()) ||
    //             MaterialSpending.fabricatingMaterial != null &&
    //                 MaterialSpending
    //                     .fabricatingMaterial!.fabricatingMaterialName!
    //                     .toLowerCase()
    //                     .contains(value.toLowerCase().toString())) {
    //           tableData(MaterialSpending);
    //         }
    //       });
    //       break;
    //     default:
    //   }
    // } else {

    //   for (int i = 0; i < _materialLength.length; i++) {
    //     for (int j = 0; j < _materialSpendings.length; j++) {
    //       _formateDate =
    //           _materialLength[i].materialSpendingDate!.substring(0, 10);
    //       _date = DateTime.parse(_formateDate);
    //       if ((_date.isAtSameMomentAs(dateStart) ||
    //               _date.isAtSameMomentAs(dateEnd)) ||
    //           (_date.isBefore(dateEnd) && _date.isAfter(dateStart))) {
    //       if (_materialLength[i].materialSpendingCode ==
    //           _materialSpendings[j].materialSpendingCode) {
    //         inc += 1;
    //         if (inc == 1) {
    //           newTableData.add([
    //             _materialSpendings[j].materialSpendingCode,
    //             "- ${_materialSpendings[j].material?.materialName ?? _materialSpendings[j].fabricatingMaterial?.fabricatingMaterialName}",
    //             "- ${_materialSpendings[j].materialSpendingQty}",
    //             _materialSpendings[j].materialSpendingDate!.substring(0, 10)
    //           ]);
    //         } else {
    //           newTableData.add([
    //             "",
    //             "- ${_materialSpendings[j].material?.materialName ?? _materialSpendings[j].fabricatingMaterial?.fabricatingMaterialName}",
    //             "- ${_materialSpendings[j].materialSpendingQty}",
    //             ""
    //           ]);
    //         }
    //       } else {
    //         inc = 0;
    //       }
    //     }
    //     }
    //   }
    // }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    for (int i = 0; i < _materialLength.length; i++) {
      for (int j = 0; j < _materialSpendings.length; j++) {
        if (value.isNotEmpty) {
          print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());
          switch (filter) {
            case "Kode Pengeluaran Barang":
              if (_materialSpendings[j]
                  .materialSpendingCode!
                  .toLowerCase()
                  .contains(value.toString().toLowerCase())) {
                tableData(_materialLength[i], _materialSpendings[j]);
              }
              break;
            // case "Barang":
            //   if (_materialSpendings[j].material != null &&
            //           _materialSpendings[j].material!.materialName!
            //               .toLowerCase()
            //               .contains(value.toLowerCase().toString()) ||
            //       _materialSpendings[j].fabricatingMaterial != null &&
            //           _materialSpendings[j]
            //               .fabricatingMaterial!.fabricatingMaterialName!
            //               .toLowerCase()
            //               .contains(value.toLowerCase().toString())) {
            //     tableData(_materialLength[i], _materialSpendings[j]);
            //   }
            //   break;
            default:
          }
        } else {
          _formateDate =
              _materialLength[i].materialSpendingDate!.substring(0, 10);
          _date = DateTime.parse(_formateDate);
          if ((_date.isAtSameMomentAs(dateStart) ||
                  _date.isAtSameMomentAs(dateEnd)) ||
              (_date.isBefore(dateEnd) && _date.isAfter(dateStart))) {
            tableData(_materialLength[i], _materialSpendings[j]);
          }
        }
      }
    }

    final tableHeaders = [
      'Kode Pengeluaran',
      'Barang',
      'Kuantiti Pengeluaran',
      'Tanggal Pengeluaran',
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
                      'Material Spending Report',
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
        name: 'my_materialSpending_report.pdf', pdf: pdf);
  }
}
