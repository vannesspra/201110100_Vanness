import 'dart:io';
import 'package:example/models/order.dart';
import 'package:example/models/product.dart';
import 'package:example/models/profile.dart';
import 'package:example/models/sale.dart';
import 'package:example/services/product.dart';
import 'package:example/services/profile.dart';
import 'package:example/services/sale.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

// var n = 0;

class PdfProductReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
  }) async {
    final pdf = pw.Document();
    final oCcy = NumberFormat("#,##0", "en_US");

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<Order> _orders = [];
    List<Sale> _sales = [];
    List<Product> _products = [];
    // Sale _sale = Sale();
    Profile _profile = Profile();
    SaleService _saleService = SaleService();
    ProfileService _profileService = ProfileService();
    ProductService _productService = ProductService();
    List<List> newTableData = [];
    // int _extraDiskon = 0;
    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    // var res = await _saleService.getSaleOrders(saleId);
    var res2 = await _saleService.getSales();
    var res3 = await _productService.getProduct();
    // _orders = res.data;
    _sales = res2.data;
    _products = res3.data;
    // _sales.forEach(
    //   (element) {
    //     if (element.saleId == int.parse(saleId)) {
    //       _sale = element;
    //     }
    //   },
    // );
    print("TEST : $_orders");
    // List<int> priceList = [];
    // _orders.forEach((order) {
    //   int totalPrice = int.tryParse(order.qty!)! * int.tryParse(order.price!)!;
    //   int _discountOne =
    //       (totalPrice * (int.parse(_sale.discountOnePercentage!) / 100))
    //           .round();
    //   int _discountTwo = ((totalPrice - _discountOne) *
    //           (int.parse(_sale.discountTwoPercentage!) / 100))
    //       .round();

    //   priceList.add((totalPrice - _discountOne) - _discountTwo);
    //   newTableData.add([
    //     order.name,
    //     oCcy.format(int.tryParse(order.qty!)),
    //     order.price,
    //     oCcy.format(_discountOne),
    //     oCcy.format(_discountTwo),
    //     oCcy.format((totalPrice - _discountOne) - _discountTwo)
    //   ]);
    // });

    // _products.forEach((product) {
    //   newTableData.add([
    //     product.productCode,
    //     product.productName,
    //     product.type!.typeName,
    //     product.color!.colorName,
    //     product.productPrice,
    //     product.productQty,
    //     product.productMinimumStock,
    //     product.productDesc
    //   ]);
    // });
    // List<Product>? backupProducts;

    void tableData(Product pro) {
      newTableData.add([
        pro.productCode,
        pro.productName,
        pro.type!.typeName,
        pro.color!.colorName,
        pro.productPrice,
        pro.productQty,
        pro.productMinimumStock,
        pro.productDesc == null ? "No Desc" : pro.productDesc,
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Jenis Produk":
          _products.forEach((product) {
            if (product.type!.typeName!.contains(value.toString())) {
              tableData(product);
            }
          });
          break;
        case "Nama Produk":
          _products.forEach((product) {
            if (product.productName!.contains(value.toString())) {
              tableData(product);
            }
          });
          break;
        case "Kode Produk":
          _products.forEach((product) {
            if (product.productCode!.contains(value.toString())) {
              tableData(product);
            }
          });
          break;
        case "Warna Produk":
          _products.forEach((product) {
            if (product.color!.colorName!.contains(value.toString())) {
              tableData(product);
            }
          });
          break;
        case "Harga Produk":
          _products.forEach((product) {
            if (product.productPrice!.contains(value.toString())) {
              tableData(product);
            }
          });
          break;
        case "Stok":
          _products.forEach((product) {
            if (product.productQty!.contains(value.toString())) {
              tableData(product);
            }
          });
          break;
        default:
      }
    } else {
      _products.forEach((product) {
        tableData(product);
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Kode Produk',
      'Nama Produk',
      'Jenis Produk',
      'Warna Produk',
      'Harga Produk',
      'Stock',
      'Stock Minimun',
      'Deskripsi',
    ];

    // final tableData = [
    //   [
    //     'Coffee',
    //     '7',
    //     '\$ 5',
    //     '1 %',
    //     '\$ 35',
    //   ],
    //   [
    //     'Blue Berries',
    //     '5',
    //     '\$ 10',
    //     '2 %',
    //     '\$ 50',
    //   ],
    //   [
    //     'Water',
    //     '1',
    //     '\$ 3',
    //     '1.5 %',
    //     '\$ 3',
    //   ],
    //   [
    //     'Apple',
    //     '6',
    //     '\$ 8',
    //     '2 %',
    //     '\$ 48',
    //   ],
    //   [
    //     'Lunch',
    //     '3',
    //     '\$ 90',
    //     '12 %',
    //     '\$ 270',
    //   ],
    //   [
    //     'Drinks',
    //     '2',
    //     '\$ 15',
    //     '0.5 %',
    //     '\$ 30',
    //   ],
    //   [
    //     'Lemon',
    //     '4',
    //     '\$ 7',
    //     '0.5 %',
    //     '\$ 28',
    //   ],
    // ];

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
                      'Product Report',
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
                // pw.Column(
                //   mainAxisSize: pw.MainAxisSize.min,
                //   crossAxisAlignment: pw.CrossAxisAlignment.start,
                //   children: [
                //     pw.Text(
                //       _orders[0].customer!.customerName!,
                //       style: pw.TextStyle(
                //         fontSize: 15.5,
                //         fontWeight: pw.FontWeight.bold,
                //       ),
                //     ),
                //     pw.Text(
                //       _orders[0].customer!.customerEmail!,
                //     ),
                //     pw.Text(
                //       DateTime.now().toString(),
                //     ),
                //   ],
                // ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            // pw.Text(
            //   'Dear ${_orders[0].customer!.customerName!},\nLorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia, molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum numquam blanditiis harum quisquam eius sed odit fugiat iusto fuga praesentium optio, eaque rerum! Provident similique accusantium nemo autem. Veritatis obcaecati tenetur iure eius earum ut molestias architecto voluptate aliquam nihil, eveniet aliquid culpa officia aut! Impedit sit sunt quaerat, odit, tenetur error',
            //   textAlign: pw.TextAlign.justify,
            // ),
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
                7: pw.Alignment.center,
              },
            ),
            pw.Divider(),
            // pw.Container(
            //   alignment: pw.Alignment.centerRight,
            //   child: pw.Row(
            //     children: [
            //       pw.Spacer(flex: 6),
            //       pw.Expanded(
            //         flex: 4,
            //         child: pw.Column(
            //           crossAxisAlignment: pw.CrossAxisAlignment.start,
            //           children: [
            //             pw.Row(
            //               children: [
            //                 pw.Expanded(
            //                   child: pw.Text(
            //                     'Net Sub-total',
            //                     style: pw.TextStyle(
            //                       fontWeight: pw.FontWeight.bold,
            //                     ),
            //                   ),
            //                 ),
            //                 pw.Text(
            //                   'Rp. ${oCcy.format(priceList.sum)}',
            //                   style: pw.TextStyle(
            //                     fontWeight: pw.FontWeight.bold,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             pw.Row(
            //               children: [
            //                 pw.Expanded(
            //                   child: pw.Text(
            //                     'Extra Diskon(${_sale.extraDiscountPercentage}%)',
            //                     style: pw.TextStyle(
            //                       fontWeight: pw.FontWeight.bold,
            //                     ),
            //                   ),
            //                 ),
            //                 pw.Text(
            //                   'Rp. ${oCcy.format(_extraDiskon)}',
            //                   style: pw.TextStyle(
            //                     fontWeight: pw.FontWeight.bold,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             // pw.Row(
            //             //   children: [
            //             //     pw.Expanded(
            //             //       child: pw.Text(
            //             //         'Vat 19.5 %',
            //             //         style: pw.TextStyle(
            //             //           fontWeight: pw.FontWeight.bold,
            //             //         ),
            //             //       ),
            //             //     ),
            //             //     pw.Text(
            //             //       '\$ 90.48',
            //             //       style: pw.TextStyle(
            //             //         fontWeight: pw.FontWeight.bold,
            //             //       ),
            //             //     ),
            //             //   ],
            //             // ),
            //             pw.Divider(),
            //             pw.Row(
            //               children: [
            //                 pw.Expanded(
            //                   child: pw.Text(
            //                     'Total amount due',
            //                     style: pw.TextStyle(
            //                       fontSize: 14.0,
            //                       fontWeight: pw.FontWeight.bold,
            //                     ),
            //                   ),
            //                 ),
            //                 pw.Text(
            //                   'Rp. ${oCcy.format(priceList.sum - _extraDiskon)}',
            //                   style: pw.TextStyle(
            //                     fontWeight: pw.FontWeight.bold,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             pw.SizedBox(height: 2 * PdfPageFormat.mm),
            //             pw.Container(height: 1, color: PdfColors.grey400),
            //             pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
            //             pw.Container(height: 1, color: PdfColors.grey400),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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
    return FileHandleApi.saveDocument(name: 'my_product_report.pdf', pdf: pdf);
  }
}
