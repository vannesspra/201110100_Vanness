import 'dart:math';

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
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/pdf_suratJalan_api.dart';

class DeliveryDetail extends StatefulWidget {
  static final GlobalKey<_DeliveryDetailState> globalKey = GlobalKey();
  final String deliveryId;
  DeliveryDetail({Key? key, required this.deliveryId}) : super(key: globalKey);

  @override
  State<DeliveryDetail> createState() => _DeliveryDetailState();
}

class _DeliveryDetailState extends State<DeliveryDetail> {
  //List
  List<Order> _orders = <Order>[];
  List<Widget> detailWidget = [];
  List<String> detailOrderCode = [];

  List<Order> detailOrders = [];
  List<Widget> detailList = [];

  //Service
  DeliveryService _deliveryService = DeliveryService();

  //Time
  DateTime requestedDeliveryDate = DateTime.now();

  final _orderCodeController = TextEditingController();
  final _productController = TextEditingController();
  final _customerController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();

  showDetailOrder(BuildContext context, String orderCode) async {
    OrderService _orderService = OrderService();

    var response = await _orderService.getOrderByCode(orderCode);

    detailOrders = response.data;
    detailList = [];
    detailOrders.forEach((element) {
      detailList.add(Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Produk : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(element.name ?? "")
                ],
              ),
              Row(
                children: [
                  Text(
                    "Kuantiti : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(element.qty ?? "")
                ],
              ),
            ],
          ),
        ),
      ));
    });
  }

  int hal = 0;
  int hal2 = 0;

  getOrders(BuildContext context) async {
    var response = await _deliveryService.getDeliveryOrder(widget.deliveryId);
    print("SENTOLOP: ${response.data}");
    _orders = response.data;

    detailWidget = [];
    detailOrderCode = [];

    _orders.forEach((element) {
      hal += 1;
      detailWidget.add(createDetailWidget(element, hal));
      detailOrderCode.add(element.orderCode!);
    });
  }

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
                FilledButton(
                    child: const Text('Cetak Surat Jalan'),
                    onPressed: () async {
                      // Navigator.pop(context);
                      _orders.forEach((element) async {
                        hal2 += 1;
                        final pdfFile = await PdfSuratJalanApi.generate(
                            element.orderCode!, hal2);
                        await FileHandleApi.openFile(pdfFile);
                      });
                      hal2 = 0;
                        // final pdfFile = await PdfSuratJalanApi.generate(
                        //     detailOrderCode, hal2);
                        // await FileHandleApi.openFile(pdfFile);
                    }),
                SizedBox(
                  height: 15,
                ),
                Column(
                  children: detailWidget,
                )
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

  createDetailWidget(Order _order, int hal) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Nomor Pesanan"), width: 100),
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
            Container(
                child: const Text("Tanggal\nPermintaan\nPengiriman"),
                width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
                child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: DatePicker(
                selected: DateTime.parse(_order.requestedDeliveryDate ?? ""),
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
                Container(child: const Text("Nama\nPelanggan"), width: 100),
                Container(
                  child: const Text(":"),
                  width: 10,
                ),
                Expanded(
                  child: TextBox(
                    enabled: false,
                    placeholder: _order.customer?.customerName,
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
                Container(child: const Text("Keterangan"), width: 100),
                Container(
                  child: const Text(":"),
                  width: 10,
                ),
                Expanded(
                  child: TextBox(
                    enabled: false,
                    controller: _descController,
                    placeholder: _order.orderDesc,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text("Daftar Produk"),
            FutureBuilder(
                future: showDetailOrder(context, _order.orderCode!),
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
                }),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Divider(),
        SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
