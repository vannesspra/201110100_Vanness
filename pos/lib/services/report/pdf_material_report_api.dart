import 'dart:io';
import 'package:example/models/material.dart';
import 'package:example/models/profile.dart';
import 'package:example/services/material.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfMaterialReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Material> _materials = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    MaterialService _materialService = MaterialService();
    List<List> newTableData = [];
    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _materialService.getMaterials();
    _materials = res3.data;

    void tableData(Material mat) {
      newTableData.add([
        mat.materialCode,
        mat.materialName,
        mat.color == null ? "No Color" : mat.color!.colorName,
        mat.materialUnit,
        mat.materialQty,
        mat.materialMinimumStock,
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Kode Bahan Baku":
          _materials.forEach((material) {
            if (material.materialCode!.contains(value.toString())) {
              tableData(material);
            }
          });
          break;
        case "Nama Bahan Baku":
          _materials.forEach((material) {
            if (material.materialName!.contains(value.toString())) {
              tableData(material);
            }
          });
          break;
        case "Warna Bahan Baku":
          _materials.forEach((material) {
            if (material.color != null &&
                material.color!.colorName!
                    .toLowerCase()
                    .contains(value.toString().toLowerCase())) {
              tableData(material);
            }
          });
          break;
        case "Satuan Unit":
          _materials.forEach((material) {
            if (material.materialUnit!.contains(value.toString())) {
              tableData(material);
            }
          });
          break;
        case "Stok":
          _materials.forEach((material) {
            if (material.materialQty!.contains(value.toString())) {
              tableData(material);
            }
          });
          break;
        default:
      }
    } else {
      _materials.forEach((material) {
        tableData(material);
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode Bahan Baku',
      'Nama Bahan Baku',
      'Warna Bahan Baku',
      'Satuan Unit',
      'Stok',
      'Stock Minimum',
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
                      'Material Report',
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
                6: pw.Alignment.center,
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
    return FileHandleApi.saveDocument(name: 'my_material_report.pdf', pdf: pdf);
  }
}
