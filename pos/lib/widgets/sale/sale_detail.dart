import 'dart:math';
import 'package:example/models/sale.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'package:example/models/color.dart';
import 'package:example/models/customer.dart';
import 'package:example/models/order.dart';
import 'package:example/models/product.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/routes/forms.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/delivery.dart';
import 'package:example/services/order.dart';
import 'package:example/services/product.dart';
import 'package:example/services/sale.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class SaleDetail extends StatefulWidget {
  static final GlobalKey<_SaleDetailState> globalKey = GlobalKey();
  final String saleId;
  final Sale sale;
  SaleDetail({Key? key, required this.saleId, required this.sale})
      : super(key: globalKey);

  @override
  State<SaleDetail> createState() => _SaleDetailState();
}

class _SaleDetailState extends State<SaleDetail> {
  //List
  Order _order = Order();
  List<Order> detailOrders = [];
  List<Widget> detailList = [];

  //Service
  SaleService _saleService = SaleService();

  //Time
  DateTime requestedDeliveryDate = DateTime.now();
  DateTime saleDate = DateTime.now();
  DateTime saleDeadline = DateTime.now();

  final _orderCodeController = TextEditingController();
  final _productController = TextEditingController();
  final _customerController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();

  showDetailOrder(BuildContext context, String orderCode) async {
    final oCcy = NumberFormat("#,##0", "en_US");
    OrderService _orderService = OrderService();

    var response = await _orderService.getOrderByCode(orderCode);

    detailOrders = response.data;
    detailList = [];
    print("KUNTIL ${detailOrders}");
    List<int> priceList = [];
    String _totalPaid = "";
    int _extraDiskon = 0;
    detailOrders.forEach((element) {
      // if (element.product != null) {
      int totalPrice =
          int.tryParse(element.qty!)! * int.tryParse(element.price!)!;

      int _discountOne =
          (totalPrice * (int.parse(widget.sale.discountOnePercentage!) / 100))
              .round();
      int _discountTwo = ((totalPrice - _discountOne) *
              (int.parse(widget.sale.discountTwoPercentage!) / 100))
          .round();
      totalPrice = (totalPrice - _discountOne) - _discountTwo;
      priceList.add(totalPrice);
      detailList.add(Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Barang : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(element.name!)
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Harga : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Rp. ${oCcy.format(int.tryParse(element.price!))}")
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Kuantiti : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(element.qty!)
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Diskon 1(${widget.sale.discountOnePercentage!}%) : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Rp. ${oCcy.format(_discountOne)}")
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Diskon 2(${widget.sale.discountTwoPercentage!}%) : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Rp. ${oCcy.format(_discountTwo)}")
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Jumlah : ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text("Rp. ${oCcy.format(totalPrice)}",
                      style: TextStyle(fontSize: 15))
                ],
              ),
              element.deliveryId == null
                  ? int.tryParse(element.product!.productQty!)! -
                              int.tryParse(element.qty!)! <
                          0
                      ? InfoBar(
                          title: Text("Kuantiti produk tidak mencukupi"),
                          severity: InfoBarSeverity.error,
                          isLong: true,
                        )
                      : InfoBar(
                          title: Text("Kuantiti produk mencukupi"),
                          severity: InfoBarSeverity.success,
                          isLong: true,
                        )
                  : Container()
            ],
          ),
        ),
      ));
    });
    _extraDiskon =
        (priceList.sum * int.parse(widget.sale.extraDiscountPercentage!) / 100)
            .round();
    detailList.add(Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Net Sub-Total : ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                "Rp. ${oCcy.format(priceList.sum)}",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Extra Diskon (${widget.sale.extraDiscountPercentage}%) : ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                "Rp. ${oCcy.format(_extraDiskon)}",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Net Total : ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                "Rp. ${oCcy.format(priceList.sum - _extraDiskon)}",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ],
      ),
    ));
  }

  getOrders(BuildContext context) async {
    print("KUNTIL");
    var response = await _saleService.getSaleOrder(widget.saleId);
    _order = response.data;
    print("KUNTIL:${response.data}");
    requestedDeliveryDate = DateTime.parse(_order.requestedDeliveryDate!);
    saleDate = DateTime.parse(_order.delivery!.deliveryDate!);
    saleDeadline =
        saleDate.add(Duration(days: int.parse(_order.customer!.paymentTerm!)));
  }

  // getDateDelivery(BuildContext context, String orderCode) async {
  //   print("QMK");
  //   List<Order> detailOrders;
  //   OrderService _orderService = OrderService();
  //   var response = await _orderService.getOrderByCode(orderCode);
  //   detailOrders = response.data;

  //   detailOrders.forEach((element) {
  //     element.delivery!.deliveryDate;
  //     setState(() {
  //       saleDate = DateTime.parse(element.delivery!.deliveryDate!);
  //     });
  //   });
  // }

  // getSaleDeadline(BuildContext context, String orderCode) async {
  //   print("BABOOSKA");
  //   List<Order> detailOrders;
  //   OrderService _orderService = OrderService();
  //   var response = await _orderService.getOrderByCode(orderCode);
  //   detailOrders = response.data;

  //   detailOrders.forEach((element) {
  //     element.delivery!.deliveryDate;
  //     setState(() {
  //       saleDeadline = DateTime.parse(element.delivery!.deliveryDate!)
  //           .add(Duration(days: int.parse(element.customer!.paymentTerm!)));
  //     });
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getOrders(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget child;

          if (snapshot.connectionState == ConnectionState.done) {
            child = ScaffoldPage.scrollable(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(child: const Text("Kode"), width: 100),
                    Container(
                      child: const Text(":"),
                      width: 10,
                    ),
                    Expanded(
                      child: TextBox(
                        enabled: false,
                        controller: _orderCodeController,
                        placeholder: _order.orderCode,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(child: const Text("Tanggal"), width: 100),
                    Container(
                      child: const Text(":"),
                      width: 10,
                    ),
                    Expanded(
                        child: Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: DatePicker(
                        selected: saleDate,
                        onChanged: null,
                      ),
                    )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child: const Text("Tanggal\nPermintaan Pengiriman"),
                        width: 100),
                    Container(
                      child: const Text(":"),
                      width: 10,
                    ),
                    Expanded(
                        child: Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: DatePicker(
                        selected: requestedDeliveryDate,
                        onChanged: null,
                      ),
                    )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: const Text("Nama\nPelanggan/Customer"),
                            width: 100),
                        Container(
                          child: const Text(":"),
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: TextBox(
                              enabled: false,
                              placeholder: _order.customer!.customerName,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(child: const Text("Jatuh Tempo"), width: 100),
                        Container(
                          child: const Text(":"),
                          width: 10,
                        ),
                        Expanded(
                            child: Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: DatePicker(
                            selected: saleDeadline,
                            onChanged: null,
                          ),
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(child: const Text("Keterangan"), width: 100),
                        Container(
                          child: const Text(":"),
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: TextBox(
                              enabled: false,
                              controller: _descController,
                              placeholder: _order.orderDesc,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Daftar Produk"),
                    FutureBuilder(
                        future: showDetailOrder(context, _order.orderCode!),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          Widget child;
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            child = Column(
                              children: detailList,
                            );
                          } else {
                            child = const Center(
                              heightFactor: 10,
                              child: ProgressRing(),
                            );
                          }
                          return child;
                        }),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            );
          } else {
            child = const Center(
              heightFactor: 10,
              child: ProgressRing(),
            );
          }
          return child;
        });
  }
}
