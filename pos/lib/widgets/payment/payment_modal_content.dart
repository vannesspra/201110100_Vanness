import 'dart:math';
import 'package:example/models/sale.dart';
import 'package:example/screens/home.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:date_format/date_format.dart';
import 'package:example/models/color.dart';
import 'package:example/models/customer.dart';
import 'package:example/models/order.dart';
import 'package:example/models/payment.dart';
import 'package:example/models/product.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/models/sale.dart';
import 'package:example/routes/forms.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/order.dart';
import 'package:example/services/payment.dart';
import 'package:example/services/product.dart';
import 'package:example/services/sale.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class PaymentModalContent extends StatefulWidget {
  final String saleId;
  final Sale sale;
  final bool? isPay;

  static final GlobalKey<_PaymentModalContentState> globalKey = GlobalKey();
  PaymentModalContent(
      {Key? key, required this.saleId, required this.sale, this.isPay})
      : super(key: globalKey);

  @override
  State<PaymentModalContent> createState() => _PaymentModalContentState();
}

class _PaymentModalContentState extends State<PaymentModalContent> {
  //List
  List<Payment>? existingPayments;
  Order _order = Order();
  List<Order> detailOrders = [];
  List<Widget> detailList = [];

  //Late
  late Future paymentsFuture;

  //Service
  PaymentService _paymentService = PaymentService();
  SaleService _saleService = SaleService();

  //Time
  DateTime paymentDate = DateTime.now();
  final now = DateTime.now();

  final _paymentCodeController = TextEditingController();
  final _descController = TextEditingController();

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  createPayment() async {
    print("PANTEQ");
    var response = await _paymentService.postPayment(
        paymentCode: _paymentCodeController.text,
        paymentDate: paymentDate,
        saleId: widget.saleId,
        paymentDesc: _descController.text);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        paymentsFuture = getPayments();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message ?? "";
      _messageStatusOpen = true;
    });
  }

  getPayments() async {
    var response = await _paymentService.getPayments();
    existingPayments = response.data;
    _paymentCodeController.text = "BP/ACC/${(formatDate(now, [
          mm,
          yy
        ]).toString())}/${(existingPayments!.length + 1).toString().padLeft(5, "0")}";
  }

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
    return _order;
  }

  late Future orderFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    paymentsFuture = getPayments();
    orderFuture = getOrders(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      children: [
        if (_messageStatusOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: InfoBar(
              onClose: () {
                setState(() {
                  _messageStatusOpen = false;
                });
              },
              title: Text(_messageTitle),
              content: Text(_messageContent),
              severity: _messageStatus,
              isLong: true,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("No.\nTransaksi"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
                child: FutureBuilder(
              future: paymentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      controller: _paymentCodeController,
                      enabled: false,
                    ),
                    width: 200,
                  );
                } else {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: const ProgressBar(),
                    width: 200,
                  );
                }
              },
            )),
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
                selected: paymentDate,
                onChanged: (value) => setState(() => paymentDate = value),
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
              child: TextBox(
                controller: _descController,
                placeholder: "Keterangan",
                maxLines: 2,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Text("Daftar Produk"),
        FutureBuilder(
            future: orderFuture,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return FutureBuilder(
                    future: showDetailOrder(context, snapshot.data.orderCode!),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      Widget child;
                      if (snapshot.connectionState == ConnectionState.done) {
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
                    });
              } else {
                return const Center(
                  heightFactor: 10,
                  child: ProgressRing(),
                );
              }
            })
      ],
    );
  }
}
