import 'dart:io';
import 'package:example/models/order.dart';
import 'package:example/models/profile.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/models/sale.dart';
import 'package:example/services/profile.dart';
import 'package:example/services/sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class PdfInvoiceApi {
  static Future<File> generate(String saleId) async {
    final pdf = pw.Document();
    final oCcy = NumberFormat("#,##0", "en_US");

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Order> _orders = [];
    List<Sale> _sales = [];
    Sale _sale = Sale();
    Profile _profile = Profile();
    SaleService _saleService = SaleService();
    ProfileService _profileService = ProfileService();
    List<List> newTableData = [];
    List<List> newTableData2 = [];

    int _extraDiskon = 0;
    String? formateDate;

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res = await _saleService.getSaleOrders(saleId);
    var res2 = await _saleService.getSales();
    _orders = res.data;
    _sales = res2.data;
    _sales.forEach(
      (element) {
        if (element.saleId == int.parse(saleId)) {
          _sale = element;
        }
      },
    );

    print("TEST : $_orders");
    List<int> priceList = [];
    _orders.forEach((order) {
      int totalPrice = int.tryParse(order.qty!)! * int.tryParse(order.price!)!;
      int _discountOne =
          (totalPrice * (int.parse(_sale.discountOnePercentage!) / 100))
              .round();
      int _discountTwo = ((totalPrice - _discountOne) *
              (int.parse(_sale.discountTwoPercentage!) / 100))
          .round();

      priceList.add((totalPrice - _discountOne) - _discountTwo);
      newTableData.add([
        order.name,
        "${oCcy.format(int.tryParse(order.qty!))}  ${order.material?.materialUnit ?? order.fabricatingMaterial?.fabricatingMaterialUnit ?? "Pcs"}",
        "Rp. ${oCcy.format(int.tryParse(order.price!))}",
        "Rp. ${oCcy.format(_discountOne)}",
        "Rp. ${oCcy.format(_discountTwo)}",
        "Rp. ${oCcy.format((totalPrice - _discountOne) - _discountTwo)}",
      ]);
    });

    newTableData2.add([
      _orders[0].orderCode,
      _orders[0].orderDate!.substring(0, 10),
      _orders[0].customer!.customerCode,
      'Term ${_orders[0].customer!.paymentTerm} Days',
    ]);

    _extraDiskon =
        (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
            .round();

    final tableHeaders2 = [
      'No. Order',
      'Tgl Order',
      'No. Id Customer',
      'Tempo Pembayaran',
    ];
    final tableHeaders = [
      'Produk',
      'Qty',
      'Harga @',
      'Disc 1',
      'Disc 2',
      'Total',
    ];

    // final tableHeaders2 = [
    //   'Produk',
    //   'Kuantiti',
    //   'Harga',
    //   'Diskon 1',
    //   'Diskon 2',
    //   'Total',
    // ];

    final tableData = [
      [
        'Coffee',
        '7',
        '\$ 5',
        '1 %',
        '\$ 35',
      ],
      [
        'Blue Berries',
        '5',
        '\$ 10',
        '2 %',
        '\$ 50',
      ],
      [
        'Water',
        '1',
        '\$ 3',
        '1.5 %',
        '\$ 3',
      ],
      [
        'Apple',
        '6',
        '\$ 8',
        '2 %',
        '\$ 48',
      ],
      [
        'Lunch',
        '3',
        '\$ 90',
        '12 %',
        '\$ 270',
      ],
      [
        'Drinks',
        '2',
        '\$ 15',
        '0.5 %',
        '\$ 30',
      ],
      [
        'Lemon',
        '4',
        '\$ 7',
        '0.5 %',
        '\$ 28',
      ],
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
                      'INVOICE',
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
                      'No. Invoice \t: ' + _sales[0].saleCode!,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
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
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
                5: pw.Alignment.centerLeft,
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
                                'Tanggal Jatuh Tempo : ' +
                                    '${_sale.saleDeadline!.split("T")[0]}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                            ),
                          ],
                        ),
                        pw.Divider(),
                        pw.Text(
                          '- Tidak menerima Komplain atas tagihan yang diterima melebihi 7 hari dari tanggal Invoice diterima oleh Customer\n- Tagihan dianggap lunas apabila pembayaran, sudah diterima di Rekening PT. ARENA CAHAYA CEMPAKA\n- Pembayaran harus dilakukan dengan "Full Amount" biaya Bank akibat transfer ditanggung oleh Customer.',
                          style: pw.TextStyle(fontSize: 7),
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(flex: 1),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Total Harga',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              'Rp. ${oCcy.format(priceList.sum)}',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'PPN 11%',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ),
                            _orders[0].customer!.tax == "Ya"
                                ? pw.Text(
                                    'Rp. ${oCcy.format(priceList.sum * 0.11)}',
                                    style: pw.TextStyle(fontSize: 10),
                                  )
                                : pw.Text('Rp. ${oCcy.format(0)}',
                                    style: pw.TextStyle(fontSize: 10))
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Total Harga',
                                style: pw.TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            _orders[0].customer!.tax == "Ya"
                                ? pw.Text(
                                    'Rp. ${oCcy.format(priceList.sum + (priceList.sum * 0.11))}',
                                    style: pw.TextStyle(fontSize: 10))
                                : pw.Text(
                                    'Rp. ${oCcy.format(priceList.sum)}',
                                    style: pw.TextStyle(fontSize: 10),
                                  )
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Extra Diskon (${_sale.extraDiscountPercentage}%)',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              'Rp. ${oCcy.format(_extraDiskon)}',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'TOTAL HARGA',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            _orders[0].customer!.tax == "Ya"
                                ? pw.Text(
                                    'Rp. ${oCcy.format((priceList.sum + (priceList.sum * 0.11)) - _extraDiskon)}',
                                    style: pw.TextStyle(fontSize: 10),
                                  )
                                : pw.Text(
                                    'Rp. ${oCcy.format(priceList.sum - _extraDiskon)}',
                                    style: pw.TextStyle(fontSize: 10),
                                  )
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.black),
                        // pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        // pw.Container(height: 1, color: PdfColors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Divider(),
                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                pw.Text(
                  'Atas nama ' + _profile.companyName!,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 8.0),
                ),
                pw.SizedBox(height: 50),
                pw.Divider(indent: 400),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
              ],
            )
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

    return FileHandleApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }
}
