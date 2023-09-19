import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:example/models/delivery.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/delivery_screen.dart';
import 'package:example/services/delivery.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfDeliveryReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Delivery> _deliveries = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    DeliveryService _delvieryService = DeliveryService();
    List<List> newTableData = [];
    DateTime? _date;
    String _formateDate = "";
    String formateDateStart = formatDate(dateStart, [dd, " ", MM, " ", yyyy]);
    String formateDateEnd = formatDate(dateEnd, [dd, " ", MM, " ", yyyy]);

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _delvieryService.getDeliveries();
    _deliveries = res3.data;

    void tableData(Delivery del) {
      newTableData.add([
        del.deliveryCode,
        del.deliveryDate!.substring(0, 10),
        del.carPlatNumber,
        del.senderName,
        del.deliveryDesc == null ? "No Desc" : del.deliveryDesc,
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Kode Pengiriman":
          _deliveries.forEach((delivery) {
            if (delivery.deliveryCode!.contains(value.toString())) {
              tableData(delivery);
            }
          });
          break;
        case "Nomor Plat Mobil":
          _deliveries.forEach((delivery) {
            if (delivery.carPlatNumber!.contains(value.toString())) {
              tableData(delivery);
            }
          });
          break;
        case "Nama Pengirim":
          _deliveries.forEach((delivery) {
            if (delivery.senderName!.contains(value.toString())) {
              tableData(delivery);
            }
          });
          break;
        default:
      }
    } else {
      print("Date Start $dateStart");
      print("Date End $dateEnd");
      _deliveries.forEach((delivery) {
        _formateDate = delivery.deliveryDate!.substring(0, 10);
        _date = DateTime.parse(_formateDate);

        if ((_date!.isAtSameMomentAs(dateStart) ||
                _date!.isAtSameMomentAs(dateEnd)) ||
            (_date!.isBefore(dateEnd) && _date!.isAfter(dateStart))) {
          tableData(delivery);
        }
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode Pengiriman',
      'Tanggal Pengiriman',
      'Nomor Plat Mobil',
      'Nama Pengirim',
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
                      'Delivery Report',
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
    return FileHandleApi.saveDocument(name: 'my_delivery_report.pdf', pdf: pdf);
  }
}
