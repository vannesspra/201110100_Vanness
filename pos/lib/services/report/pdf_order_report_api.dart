import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:example/models/order.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/sales_order.dart';
import 'package:example/services/order.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfOrderReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
    required String check,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Order> _orders = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    OrderService _orderService = OrderService();
    List<List> newTableData = [];
    String formateDateStart = formatDate(dateStart, [dd, " ", MM, " ", yyyy]);
    String formateDateEnd = formatDate(dateEnd, [dd, " ", MM, " ", yyyy]);

    int _totalDisc;
    DateTime? _date;
    String _formateDate = "";

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _orderService.getOrdersGrouped();
    _orders = res3.data;

    void tableData(Order ord) {
      newTableData.add([
        ord.orderCode,
        ord.customer!.customerName,
        ord.orderDate!.substring(0, 10),
        ord.requestedDeliveryDate!.substring(0, 10),
        ord.orderDesc == null ? "No Desc" : ord.orderDesc,
        ord.orderStatus,
        ord.delivery == null
            ? "Belum dikirm"
            : ord.delivery!.deliveryDate!.substring(0, 10),
      ]);
    }

    if (dateStart != null && dateEnd != null) {
      switch (check) {
        case "Sudah dikirim":
          print("Date Start $dateStart");
          print("Date End $dateEnd");
          _orders.forEach((order) {
            _formateDate = order.orderDate!.substring(0, 10);
            _date = DateTime.parse(_formateDate);

            if ((order.delivery != null) &&
                ((_date!.isAtSameMomentAs(dateStart) ||
                        _date!.isAtSameMomentAs(dateEnd)) ||
                    (_date!.isBefore(dateEnd) && _date!.isAfter(dateStart)))) {
              tableData(order);
            }
          });
          break;

        case "Belum dikirim":
          print("Date Start $dateStart");
          print("Date End $dateEnd");
          _orders.forEach((order) {
            _formateDate = order.orderDate!.substring(0, 10);
            _date = DateTime.parse(_formateDate);
            if ((order.delivery == null) &&
                ((_date!.isAtSameMomentAs(dateStart) ||
                        _date!.isAtSameMomentAs(dateEnd)) ||
                    (_date!.isBefore(dateEnd) && _date!.isAfter(dateStart)))) {
              tableData(order);
            }
          });
          break;
        default:
      }
    } else if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (check) {
        case "Sudah dikirim":
          switch (filter) {
            case "Kode Pesanan":
              _orders.forEach((order) {
                if (order.delivery != null &&
                    order.orderCode!.contains(value.toString())) {
                  tableData(order);
                }
                // else if (order.deliveryId == null &&
                //     order.orderCode!.contains(value.toString())) {
                //   tableData(order);
                // }
              });
              break;
            case "Pelanggan":
              _orders.forEach((order) {
                if (order.delivery != null &&
                    order.customer!.customerName!
                        .toLowerCase()
                        .contains(value.toLowerCase())) {
                  tableData(order);
                }
                // else if (order.deliveryId == null &&
                //     order.customer!.customerName!
                //         .toLowerCase()
                //         .contains(value.toLowerCase())) {
                //   tableData(order);
                // }
              });
              break;
            default:
          }
          break;
        case "Belum dikirim":
          switch (filter) {
            case "Kode Pesanan":
              _orders.forEach((order) {
                if (order.delivery == null &&
                    order.orderCode!.contains(value.toString())) {
                  tableData(order);
                }
                // else if (order.deliveryId == null &&
                //     order.orderCode!.contains(value.toString())) {
                //   tableData(order);
                // }
              });
              break;
            case "Pelanggan":
              _orders.forEach((order) {
                if (order.delivery == null &&
                    order.customer!.customerName!
                        .toLowerCase()
                        .contains(value.toLowerCase())) {
                  tableData(order);
                }
                // else if (order.deliveryId == null &&
                //     order.customer!.customerName!
                //         .toLowerCase()
                //         .contains(value.toLowerCase())) {
                //   tableData(order);
                // }
              });
              break;
            default:
          }
          break;
        default:
      }
    } else if (check.isNotEmpty) {
      switch (check) {
        case "Sudah dikirim":
          _orders.forEach((order) {
            if (order.delivery != null) {
              tableData(order);
            }
          });
          break;
        case "Belum dikirim":
          _orders.forEach((order) {
            if (order.delivery == null) {
              tableData(order);
            }
          });
          break;
        default:
          _orders.forEach((order) {
            tableData(order);
          });
      }
    } else {
      _orders.forEach((order) {
        tableData(order);
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode Sales Order',
      'Pelanggan',
      'Tanggal Pesan',
      'Tanggal Permintaan',
      'Deskripsi',
      'Status',
      'Tanggal kirim',
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
                      'Sales Order Report',
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
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellPadding: pw.EdgeInsets.only(top: 2.0, bottom: 2.0),
              cellHeight: 5.0,
              cellStyle: pw.TextStyle(fontSize: 7),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
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
    return FileHandleApi.saveDocument(name: 'my_order_report.pdf', pdf: pdf);
  }
}
