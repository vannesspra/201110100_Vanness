import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:collection/collection.dart';
import 'package:example/models/color.dart';
import 'package:example/models/customer.dart';
import 'package:example/models/order.dart';
import 'package:example/models/product.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/models/sale.dart';
import 'package:example/routes/forms.dart';
import 'package:example/screens/customer_screen.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/order.dart';
import 'package:example/services/product.dart';
import 'package:example/services/sale.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class AddSaleModalContent extends StatefulWidget {
  static final GlobalKey<_AddSaleModalContentState> globalKey = GlobalKey();
  AddSaleModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddSaleModalContent> createState() => _AddSaleModalContentState();
}

class _AddSaleModalContentState extends State<AddSaleModalContent> {
  //List
  List<Order> orders = [];
  String extraDiscount = "0";
  Order selectedOrder = Order();
  List<AutoSuggestBoxItem> order_items = <AutoSuggestBoxItem>[];
  List paymentType = ["Tunai", "Kredit"];
  List taxType = ["Ya", "Tidak"];

  List<Sale>? existingSale;

  //Late
  late Future saleFuture;

  //Service
  ProductService _productService = ProductService();
  CustomerServices _customerServices = CustomerServices();
  OrderService _orderService = OrderService();
  SaleService _saleService = SaleService();

  //Time
  DateTime saleDate = DateTime.now();
  DateTime saleDeadline = DateTime.now();
  final now = DateTime.now();

  final _saleCodeController = TextEditingController();
  final _discountController = TextEditingController();
  final _orderController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedPaymentType = "";
  String _selectedTax = "";

  String? _orderCode = "";

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  //Checkbox
  bool checked_order = false;
  bool checked_deliver = false;
  bool checked_done = false;

  getOrders() async {
    order_items = [];
    var response = await _saleService.getSaleAvailOrder();
    orders = response.data;
    orders.forEach((element) {
      order_items.add(AutoSuggestBoxItem(
          value: element.orderCode, label: element.orderCode!));
    });
  }

  getDateDelivery(BuildContext context, String orderCode) async {
    print("QMK");
    List<Order> detailOrders;
    OrderService _orderService = OrderService();
    var response = await _orderService.getOrderByCode(orderCode);
    detailOrders = response.data;

    detailOrders.forEach((element) {
      element.delivery!.deliveryDate;
      setState(() {
        saleDate = DateTime.parse(element.delivery!.deliveryDate!);
      });
    });
  }

  getSaleDeadline(BuildContext context, String orderCode) async {
    print("BABOOSKA");
    List<Order> detailOrders;
    OrderService _orderService = OrderService();
    var response = await _orderService.getOrderByCode(orderCode);
    detailOrders = response.data;

    detailOrders.forEach((element) {
      element.delivery!.deliveryDate;
      setState(() {
        saleDeadline = DateTime.parse(element.delivery!.deliveryDate!)
            .add(Duration(days: int.parse(element.customer!.paymentTerm!)));
      });
    });
  }

  getExtraDiscounts(String orderCode) async {
    OrderService _orderService = OrderService();

    var response = await _orderService.getOrderByCode(orderCode);
    List<Order> detailOrders = response.data;
    List<int> priceList = [];
    Customer _customer = Customer();
    detailOrders.forEach((element) {
      _customer = element.customer!;
      int totalPrice =
          int.tryParse(element.qty!)! * int.tryParse(element.price!)!;

      int _discountOne =
          (totalPrice * (int.parse(element.customer!.discountOne!) / 100))
              .round();
      int _discountTwo = ((totalPrice - _discountOne) *
              (int.parse(element.customer!.discountTwo!) / 100))
          .round();
      totalPrice = (totalPrice - _discountOne) - _discountTwo;
      priceList.add(totalPrice);
    });
    print("TOTAL PRICE: ${priceList.sum}");
    if (_customer.extraDiscounts != null) {
      _customer.extraDiscounts!.forEach((element) {
        if (priceList.sum > int.parse(element.amountPaid!)) {
          setState(() {
            extraDiscount = element.discount!;
          });
        }
      });
    }
    print("DISKON: ${extraDiscount}");
  }

  createSale() async {
    print("TESTING");
    var response = await _saleService.postSale(
        saleCode: _saleCodeController.text,
        orderCode: _orderCode,
        saleDate: saleDate,
        saleDeadline: saleDeadline,
        paymentType: selectedOrder.customer?.paymentType,
        paymentTerm: selectedOrder.customer?.paymentTerm ?? "0",
        discountOne: selectedOrder.customer?.discountOne!,
        discountTwo: selectedOrder.customer?.discountTwo!,
        extraDiscount: extraDiscount,
        tax: selectedOrder.customer?.tax!,
        saleDesc: _descController.text);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        saleFuture = getSale();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;

      getOrders();
    });
  }

  getSale() async {
    var response = await _saleService.getSales();
    existingSale = response.data;
    _saleCodeController.text = "INV/ACC/${(formatDate(now, [
          mm,
          yy
        ]).toString())}/${(existingSale!.length + 1).toString().padLeft(5, "0")}";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrders();

    saleFuture = getSale();
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
            Container(child: const Text("Kode"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
                child: FutureBuilder(
              future: saleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      controller: _saleCodeController,
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
            Container(child: const Text("Sales Order"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: AutoSuggestBox(
                clearButtonEnabled: false,
                onSelected: (value) {
                  print(value.value);
                  setState(() {
                    _orderCode = value.value.toString();
                    orders.forEach((element) {
                      if (element.orderCode == _orderCode) {
                        selectedOrder = element;
                      }
                    });
                    getSaleDeadline(context, _orderCode!);
                    getDateDelivery(context, _orderCode!);
                    getExtraDiscounts(_orderCode!);
                  });
                },
                controller: _orderController,
                placeholder: "Pesanan / Order",
                items: order_items,
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
        if (_orderCode != "")
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
                  // onChanged: (value) => setState(() => saleDeadline = value),
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
          height: 5,
        ),
      ],
    );
  }
}
