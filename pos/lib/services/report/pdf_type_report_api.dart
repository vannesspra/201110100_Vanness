import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:email_validator/email_validator.dart';
import 'package:example/models/product_type.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/product_type.dart';
import 'package:example/services/type.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfTypeReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<ProductType> _types = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    TypeService _typeService = TypeService();
    List<List> newTableData = [];

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _typeService.getTypes();
    _types = res3.data;

    void tableData(ProductType type) {
      newTableData.add([
        type.typeCode,
        type.typeName,
        type.typeDesc == null ? "No Desc" : type.typeDesc,
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Kode Tipe":
          _types.forEach((type) {
            if (type.typeCode!.contains(value.toString())) {
              tableData(type);
            }
          });
          break;
        case "Tipe":
          _types.forEach((type) {
            if (type.typeName!.contains(value.toString())) {
              tableData(type);
            }
          });
          break;
        default:
      }
    } else {
      _types.forEach((type) {
        tableData(type);
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode Tipe',
      'Tipe',
      'Deskripsi',
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
                      'Type Report',
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
              headerHeight: 10.0,
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
    return FileHandleApi.saveDocument(name: 'my_type_report.pdf', pdf: pdf);
  }
}
