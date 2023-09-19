import 'dart:io';
import 'package:example/models/order.dart';
import 'package:example/models/profile.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/models/sale.dart';
import 'package:example/services/order.dart';
import 'package:example/services/profile.dart';
import 'package:example/services/sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class PdfSuratJalanApi {
  static Future<File> generate(String orderCode, int hal) async {
    final pdf = pw.Document();
    final oCcy = NumberFormat("#,##0", "en_US");

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Order> _orders = [];
    Profile _profile = Profile();
    OrderService _orderService = OrderService();
    ProfileService _profileService = ProfileService();
    List<List> newTableData = [];
    List<List> newTableData2 = [];
    List<List<Order>> _listOfOrders = [];

    String? formateDate;

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;

    var res = await _orderService.getOrderByCode(orderCode);
    _orders = res.data;
    // var res = await _orderService.getOrderByCode(orderCode);
    //   _orders = res.data;
    // _listOfOrders.add(_orders);
    print("TESTingg : $orderCode");
    print("TESTinggggggggggggggg : $_orders");
    List<int> priceList = [];
    _orders.forEach((order) {
      newTableData.add([
        order.name,
        oCcy.format(int.tryParse(order.qty!)),
        order.material?.materialUnit ??
            order.fabricatingMaterial?.fabricatingMaterialUnit ??
            "Pcs",
      ]);
    });

    newTableData2.add([
      _orders[0].orderCode,
      _orders[0].orderDate!.substring(0, 10),
      _orders[0].customer!.customerCode,
      'Term ${_orders[0].customer!.paymentTerm} Days',
    ]);

    final tableHeaders = [
      'Produk',
      'Qty',
      'Satuan',
    ];

    final tableHeaders2 = [
      'No. Order',
      'Tgl Order',
      'No. Id Customer',
      'Tempo Pembayaran',
    ];

    pdf.addPage(
      pw.MultiPage(
        // header: (context) {
        //   return pw.Text(
        //     'Flutter Approach',
        //     style: pw.TextStyle(
        //       fontWeight: pw.FontWeight.bold,
        //       fontSize: 15.0,
        //     ),
        //   );
        // },
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
                      'SURAT JALAN',
                      style: pw.TextStyle(
                        fontSize: 17.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      _profile.companyName!,
                      style: const pw.TextStyle(
                        fontSize: 12.0,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Office : ' + _profile.companyAddress!,
                      style: const pw.TextStyle(
                        fontSize: 10.0,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Phone : ' + _profile.companyPhoneNumber!,
                      style: const pw.TextStyle(
                        fontSize: 10.0,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'No. Delivery \t: ' + _orders[0].delivery!.deliveryCode!,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Tanggal \t: ' + DateTime.now().toString().split(" ")[0],
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    // pw.Text(
                    //   _orders[0].customer!.customerName!,
                    //   style: pw.TextStyle(
                    //     fontSize: 15.5,
                    //     fontWeight: pw.FontWeight.bold,
                    //   ),
                    // ),
                    // pw.Text(
                    //   _orders[0].customer!.customerEmail!,
                    // ),
                    // pw.Text(
                    //   DateTime.now().toString(),
                    // ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CUSTOMER : ',
                    style: pw.TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  pw.Text(
                    _orders[0].customer!.customerName!,
                    style: pw.TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    _orders[0].customer!.customerAddress! +
                        ', ' +
                        _orders[0].customer!.customerPhoneNumber!,
                    style: pw.TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ]),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),
            pw.Table.fromTextArray(
              headers: tableHeaders2,
              data: newTableData2,
              headerStyle: pw.TextStyle(fontSize: 8),
              border: const pw.TableBorder(
                top: pw.BorderSide(),
                right: pw.BorderSide(),
                left: pw.BorderSide(),
                bottom: pw.BorderSide(),
                verticalInside: pw.BorderSide(),
              ),
              cellHeight: 5.0,
              cellStyle: pw.TextStyle(fontSize: 7),
              cellPadding: pw.EdgeInsets.only(top: 1.0, bottom: 1.0),
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
            ),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),

            ///
            /// PDF Table Create
            ///
            pw.Table.fromTextArray(
              headers: tableHeaders,
              data: newTableData,
              border: const pw.TableBorder(
                top: pw.BorderSide(),
                right: pw.BorderSide(),
                left: pw.BorderSide(),
                bottom: pw.BorderSide(),
                verticalInside: pw.BorderSide(),
              ),
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                  border: pw.TableBorder(bottom: pw.BorderSide())),
              cellHeight: 25.0,
              cellStyle: pw.TextStyle(fontSize: 8),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
              },
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Catatan : \n' +
                                    'Tidak menerima komplain setelah lebih 5 hari diterima',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(flex: 1),
                ],
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Atas nama \n' + _profile.companyName!,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8.0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(flex: 1),
                ],
              ),
            ),
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                mainAxisSize: pw.MainAxisSize.min,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Transporter   \t:',
                                    style: pw.TextStyle(fontSize: 8.0),
                                  ),
                                  pw.SizedBox(height: 5),
                                  pw.Text(
                                    'No. Kendaraan \t:',
                                    style: pw.TextStyle(fontSize: 8.0),
                                  ),
                                  pw.SizedBox(height: 5),
                                  pw.Text(
                                    'Dimuat oleh   \t:',
                                    style: pw.TextStyle(fontSize: 8.0),
                                  ),
                                  pw.SizedBox(height: 5),
                                  pw.Text(
                                    'Dicek oleh    \t:',
                                    style: pw.TextStyle(fontSize: 8.0),
                                  ),
                                  pw.SizedBox(height: 5),
                                  pw.Text(
                                    'Disetujui \t:',
                                    style: pw.TextStyle(fontSize: 8.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(flex: 1),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Expanded(
                              child: pw.Column(children: [
                                pw.Text('Pengemudi',
                                    style: pw.TextStyle(fontSize: 8.0),
                                    textAlign: pw.TextAlign.center),
                                pw.SizedBox(height: 50),
                                pw.Text('__________',
                                    style: pw.TextStyle(fontSize: 8.0),
                                    textAlign: pw.TextAlign.center),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(flex: 1),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Expanded(
                              child: pw.Column(children: [
                                pw.Text(
                                    'Barang diatas diterima dalam keadaaan baik dan sesuai order',
                                    style: pw.TextStyle(fontSize: 8.0),
                                    textAlign: pw.TextAlign.left),
                                pw.SizedBox(height: 40),
                                pw.Text('________________',
                                    style: pw.TextStyle(fontSize: 8.0),
                                    textAlign: pw.TextAlign.left),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(flex: 1),
                ],
              ),
            ),

            pw.SizedBox(height: 1 * PdfPageFormat.mm),
          ];
        },
        // footer: (context) {
        //   return pw.Column(
        //     mainAxisSize: pw.MainAxisSize.min,
        //     crossAxisAlignment: pw.CrossAxisAlignment.end,
        //     children: [
        //       pw.Divider(),
        //       pw.SizedBox(height: 2 * PdfPageFormat.mm),
        //       pw.Text(
        //         'Atas nama ' + _profile.companyName!,
        //         style:
        //             pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.0),
        //       ),
        //       pw.SizedBox(height: 50),
        //       pw.Divider(indent: 400),
        //       pw.SizedBox(height: 1 * PdfPageFormat.mm),
        //     ],
        //   );
        // },
      ),
    );

    return FileHandleApi.saveDocument(
        name: 'my_suratJalan($hal).pdf', pdf: pdf);
  }
}
