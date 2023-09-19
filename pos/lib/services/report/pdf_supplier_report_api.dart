import 'dart:io';
import 'package:example/models/customer.dart';
import 'package:example/models/material.dart';
import 'package:example/models/profile.dart';
import 'package:example/models/supplier.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/material.dart';
import 'package:example/services/profile.dart';
import 'package:example/services/supplier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfSupplierReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Supplier> _suppliers = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    SupplierServices _supplierService = SupplierServices();
    List<List> newTableData = [];
    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _supplierService.getSupplier();
    _suppliers = res3.data;

    List item = [];

    void tableData(Supplier sup) {
      for (int i = 0; i < sup.supplierProducts!.length; i++) {
        item.add(sup.supplierProducts![i].material?.materialName ??
            sup.supplierProducts![i].fabricatingMaterial
                ?.fabricatingMaterialName ??
            sup.supplierProducts![i].product?.productName);
      }

      newTableData.add([
        sup.supplierCode,
        sup.supplierName,
        item.length == 1 ? item[0] : "-\t" + item.join('\n-\t'),
        sup.supplierAddress,
        sup.supplierPhoneNumber,
        sup.supplierEmail,
        sup.supplierContactPerson,
        sup.supplierTax,
        sup.paymentTerm ?? "-",
        sup.paymentType,
      ]);
      item = [];
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Kode Pemasok":
          _suppliers.forEach((supplier) {
            if (supplier.supplierCode!.contains(value.toString())) {
              tableData(supplier);
            }
          });
          break;
        case "Nama Pemasok":
          _suppliers.forEach((supplier) {
            if (supplier.supplierName!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(supplier);
            }
          });
          break;
        case "Alamat Pemasok":
          _suppliers.forEach((supplier) {
            if (supplier.supplierAddress!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(supplier);
            }
          });
          break;
        case "No. Telp Pemasok":
          _suppliers.forEach((supplier) {
            if (supplier.supplierPhoneNumber!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(supplier);
            }
          });
          break;
        case "Email Pemasok":
          _suppliers.forEach((supplier) {
            if (supplier.supplierEmail!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(supplier);
            }
          });
          break;
        case "Kontak Person Pemasok":
          _suppliers.forEach((supplier) {
            if (supplier.supplierContactPerson!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(supplier);
            }
          });
          break;
        case "Cash":
          _suppliers.forEach((supplier) {
            if (supplier.paymentType!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(supplier);
            }
          });
          break;
        case "Tax":
          _suppliers.forEach((supplier) {
            if (supplier.supplierTax!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(supplier);
            }
          });
          break;
        default:
      }
    } else {
      _suppliers.forEach((supplier) {
        tableData(supplier);
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode',
      'Nama',
      'Item',
      'Alamat',
      'No. Telp',
      'Email',
      'Kontak Person',
      'Tax',
      'Tenor',
      'Cash',
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
                      'Supplier Report',
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
            pw.SizedBox(
                height: 5 * PdfPageFormat.mm, width: 50 * PdfPageFormat.cm),
            // pw.Container(
            //   color: PdfColors.black,
            //   height: 5 * PdfPageFormat.mm,
            //     width: double.infinity),

            ///
            /// PDF Table Create
            ///
            pw.Table.fromTextArray(
              // cellPadding: pw.EdgeInsets.symmetric(horizontal: 10),
              tableWidth: pw.TableWidth.max,
              headers: tableHeaders,
              data: newTableData,
              border: null,
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 5.6),
              headerAlignment: pw.Alignment.center,
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30.0,
              cellStyle: pw.TextStyle(fontSize: 5.6),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.center,
                8: pw.Alignment.center,
                9: pw.Alignment.center,
                10: pw.Alignment.center,
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
    return FileHandleApi.saveDocument(name: 'my_customer_report.pdf', pdf: pdf);
  }
}
