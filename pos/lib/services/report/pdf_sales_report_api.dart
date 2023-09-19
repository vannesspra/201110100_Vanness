import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:example/models/sale.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/sales_screen.dart';
import 'package:example/services/sale.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfsalesReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Sale> _sales = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    SaleService _salesService = SaleService();
    List<List> newTableData = [];
    DateTime? _date;
    String _formateDate = "";
    int _totalDisc;
    String formateDateStart = formatDate(dateStart, [dd, " ", MM, " ", yyyy]);
    String formateDateEnd = formatDate(dateEnd, [dd, " ", MM, " ", yyyy]);

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _salesService.getSales();
    _sales = res3.data;

    void tableData(Sale sale) {
      _totalDisc = int.parse(sale.discountOnePercentage!) +
          int.parse(sale.discountTwoPercentage!) +
          int.parse(sale.extraDiscountPercentage!);
      newTableData.add([
        sale.saleCode,
        sale.saleDate!.substring(0, 10),
        sale.saleDeadline!.substring(0, 10),
        sale.paymentType,
        _totalDisc.toString(),
        sale.tax,
        sale.saleDesc == null ? "No Desc" : sale.saleDesc,
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Kode Penjualan":
          _sales.forEach((sales) {
            if (sales.saleCode!.contains(value.toString())) {
              tableData(sales);
            }
          });
          break;
        case "Pembayaran":
          _sales.forEach((sales) {
            if (sales.paymentType!.contains(value.toString())) {
              tableData(sales);
            }
          });
          break;
        case "Diskon":
          _sales.forEach((sales) {
            if (sales.discountOnePercentage!.contains(value.toString())) {
              tableData(sales);
            }
          });
          break;
        case "PPN":
          _sales.forEach((sales) {
            if (sales.tax!.contains(value.toString())) {
              tableData(sales);
            }
          });
          break;
        default:
      }
    } else {
      print("Date Start $dateStart");
      print("Date End $dateEnd");
      _sales.forEach((sales) {
        _formateDate = sales.saleDate!.substring(0, 10);
        _date = DateTime.parse(_formateDate);

        if ((_date!.isAtSameMomentAs(dateStart) ||
                _date!.isAtSameMomentAs(dateEnd)) ||
            (_date!.isBefore(dateEnd) && _date!.isAfter(dateStart))) {
          tableData(sales);
        }
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode Penjualan',
      'Tanggal Penjualan',
      'Jatuh Tempo',
      'Pembayaran',
      'Diskon',
      'PPN',
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
                      'Sales Report',
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
              headerHeight: 25.0,
              border: null,
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
    return FileHandleApi.saveDocument(name: 'my_sales_report.pdf', pdf: pdf);
  }
}
