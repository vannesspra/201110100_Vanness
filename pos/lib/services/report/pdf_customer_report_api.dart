import 'dart:io';
import 'package:example/models/customer.dart';
import 'package:example/models/material.dart';
import 'package:example/models/profile.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/material.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfCustomerReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Customer> _customers = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    CustomerServices _customerService = CustomerServices();
    List<List> newTableData = [];
    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _customerService.getCustomer();
    _customers = res3.data;

    void tableData(Customer cus) {
      newTableData.add([
        cus.customerCode,
        cus.customerName,
        cus.customerAddress,
        cus.customerPhoneNumber,
        cus.customerEmail,
        cus.customerContactPerson,
        cus.discountOne,
        cus.discountTwo,
        cus.paymentType,
        cus.paymentTerm,
        cus.tax
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Kode Pelanggan":
          _customers.forEach((customer) {
            if (customer.customerCode!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(customer);
            }
          });
          break;
        case "Nama Pelanggan":
          _customers.forEach((customer) {
            if (customer.customerName!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(customer);
            }
          });
          break;
        case "Alamat Pelanggan":
          _customers.forEach((customer) {
            if (customer.customerAddress!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(customer);
            }
          });
          break;
        case "No. Telp Pelanggan":
          _customers.forEach((customer) {
            if (customer.customerPhoneNumber!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(customer);
            }
          });
          break;
        case "Email Pelanggan":
          _customers.forEach((customer) {
            if (customer.customerEmail!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(customer);
            }
          });
          break;
        case "Kontak Person Pelanggan":
          _customers.forEach((customer) {
            if (customer.customerContactPerson!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(customer);
            }
          });
          break;
        case "Jenis Pembayaran":
          _customers.forEach((customer) {
            if (customer.paymentType!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(customer);
            }
          });
          break;
        case "PPN":
          _customers.forEach((customer) {
            if (customer.tax!
                .toLowerCase()
                .contains(value.toString().toLowerCase())) {
              tableData(customer);
            }
          });
          break;
        default:
      }
    } else {
      _customers.forEach((customer) {
        tableData(customer);
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode',
      'Nama',
      'Alamat',
      'No. Telp',
      'Email',
      'Kontak Person',
      'Disc 1',
      'Disc 2',
      'Jenis Pembayaran',
      'Jangka Waktu',
      'PPN',
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
                      'Customer Report',
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
              headerHeight: 25.0,
              border: null,
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 5.6),
              headerAlignment: pw.Alignment.center,
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 5.0,
              cellPadding: pw.EdgeInsets.only(top: 2.0, bottom: 2.0),
              cellStyle: pw.TextStyle(fontSize: 5.6),
              cellAlignments: {
                0: pw.Alignment.center,
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
