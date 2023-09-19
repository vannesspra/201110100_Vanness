import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/models/order.dart';
import 'package:intl/intl.dart';
import 'package:example/models/customer.dart';
import 'package:example/models/delivery.dart';
import 'package:example/models/product_color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/delivery.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_delivery_report_api.dart';
import 'package:example/widgets/customer/add_customer_modal_content.dart';
import 'package:example/widgets/delivery/delivery_detail.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:url_launcher/link.dart';
import 'package:example/services/file_handle_api.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../services/product.dart';
import '../models/product.dart';

import '../widgets/product/add_product_modal_content.dart';

List<Delivery>? backupDeliveries;
List<Delivery>? deliveries;
List<Delivery>? searchedDeliveries;

showDeliveryDetail(BuildContext context, String deliveryId) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Detail Pesanan'),
      content: DeliveryDetail(
        deliveryId: deliveryId,
      ),
      actions: [
        Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context);
            }),
        FilledButton(
            child: const Text('OK'),
            onPressed: () async {
              Navigator.pop(context);
            }),
      ],
    ),
  );
}

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({Key? key}) : super(key: key);

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> with PageMixin {
  bool selected = true;
  DateTime? _dateTimeStart;
  DateTime? _dateTimeEnd;
  DateTime? _dateStart;
  DateTime? _dateEnd;
  DateTime? _date;

  String _formateDateStart = "";
  String _formateDateEnd = "";
  String _formateDate = "";

  String? comboboxValue;
  CustomerServices _customerService = CustomerServices();
  DeliveryService _deliveryService = DeliveryService();
  String? message;
  String? status;
  List<Order> _orders = <Order>[];
  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  // void showAddCustomerModal(BuildContext context) async {
  //   final result = await showDialog<String>(
  //     context: context,
  //     builder: (context) => ContentDialog(
  //       constraints: const BoxConstraints(maxWidth: 500),
  //       title: const Text('Tambah Produk Baru'),
  //       content: AddCustomerModalContent(),
  //       actions: [
  //         Button(
  //           child: const Text('Batal'),
  //           onPressed: () {
  //             Navigator.pop(context, 'User deleted file');
  //             // Delete file here
  //           },
  //         ),
  //         FilledButton(
  //             child: const Text('Tambah'),
  //             onPressed: () {
  //               AddCustomerModalContent.globalKey.currentState!.postCustomer();
  //             }),
  //       ],
  //     ),
  //   );
  //   setState(() {});
  // }

  late Future deliveriesFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Kode Pengiriman", "Nomor Plat Mobil", "Nama Pengirim"];

  getDeliveries() async {
    var response = await _deliveryService.getDeliveries();
    deliveries = response.data;
    backupDeliveries = deliveries;
    print("Get to View Product: ${deliveries}");

    _data = DataTable(context: context);
  }

  int hal = 0;

  // getOrders(BuildContext context) async {
  //   var response = await _deliveryService.getDeliveryOrder(widget.deliveryId);
  //   print("SENTOLOP: ${response.data}");
  //   _orders = response.data;
  //   // _orders.forEach((element) {
  //   //   hal += 1;
  //   // });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deliveriesFuture = getDeliveries();
  }

  String val = "";
  DateTime? dateStart;
  DateTime? dateEnd;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Delivery Order'),
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      onChanged: (value) {
                        setState(() {
                          val = value;
                        });
                        print(value);
                        if (value == "") {
                          print("Value Kosong");
                          setState(() {
                            deliveriesFuture = getDeliveries();
                          });
                        } else {
                          if (selectedFilter == "Kode Pengiriman") {
                            setState(() {
                              deliveries = backupDeliveries;
                              deliveries = deliveries!
                                  .where((delivery) =>
                                      delivery.deliveryCode!.contains(value))
                                  .toList();
                              _data = DataTable(context: context);
                              print("---Searched Product---");
                              deliveries!.forEach((element) {
                                print(element.deliveryCode);
                              });
                            });
                          } else if (selectedFilter == "Nomor Plat Mobil") {
                            setState(() {
                              deliveries = backupDeliveries;
                              deliveries = deliveries!
                                  .where((delivery) => delivery.carPlatNumber!
                                      .toLowerCase()
                                      .contains(value.toLowerCase().toString()))
                                  .toList();
                              _data = DataTable(context: context);
                              print("---Searched Product---");
                              deliveries!.forEach((element) {
                                print(element.carPlatNumber);
                              });
                            });
                          } else if (selectedFilter == "Nama Pengirim") {
                            setState(() {
                              deliveries = backupDeliveries;
                              deliveries = deliveries!
                                  .where((delivery) => delivery.senderName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable(context: context);
                              print("---Searched Product---");
                              deliveries!.forEach((element) {
                                print(element.senderName);
                              });
                            });
                          } else {
                            setState(() {});
                          }
                        }
                      },
                      controller: searchController,
                      placeholder: 'Search',
                      focusNode: searchFocusNode,
                    )),
                const SizedBox(
                  width: 10,
                ),
                ComboBox(
                    placeholder: const Text("Cari Berdasarkan"),
                    value: selectedFilter,
                    items: filterList.map((e) {
                      return ComboBoxItem(
                        child: Text(e),
                        value: e,
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        print(value);
                        selectedFilter = value.toString();
                        print(selectedFilter);
                      });
                    }),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon: const Icon(Material.Icons.date_range),
                  onPressed: () {
                    Material.showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099),
                    ).then((date) {
                      //tambahkan setState dan panggil variabel _dateTime.
                      setState(() {
                        _dateTimeStart = date?.start;
                        _dateTimeEnd = date?.end;

                        print("Start : $_dateTimeStart");
                        print("End : $_dateTimeEnd");
                        _formateDateEnd =
                            formatDate(_dateTimeEnd!, [yyyy, '-', mm, '-', dd]);
                        _formateDateStart = formatDate(
                            _dateTimeStart!, [yyyy, '-', mm, '-', dd]);

                        _dateStart = DateTime.parse(_formateDateStart);
                        _dateEnd = DateTime.parse(_formateDateEnd);

                        dateEnd = _dateEnd;
                        dateStart = _dateStart;

                        deliveries = backupDeliveries;
                        deliveries = deliveries!.where((delivery) {
                          _formateDate =
                              delivery.deliveryDate!.substring(0, 10);
                          _date = DateTime.parse(_formateDate);

                          return (_date!.isAtSameMomentAs(_dateStart!) ||
                                  _date!.isAtSameMomentAs(_dateEnd!)) ||
                              (_date!.isBefore(_dateEnd!) &&
                                  _date!.isAfter(_dateStart!));
                        }).toList();
                        _data = DataTable(context: context);
                        print("Date : $_date");
                      });
                    });
                    setState(() {});
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                    icon: const Icon(Material.Icons.refresh),
                    onPressed: () {
                      setState(() {
                        val = "";
                        dateEnd = null;
                        dateStart = null;
                        deliveriesFuture = getDeliveries();
                      });
                    })
              ],
            ),
            // Container(
            //     child: Button(
            //   child: const Text("Tambah Pelanggan"),
            //   onPressed: (() {
            //     showAddCustomerModal(context);
            //   }),
            //   style: ButtonStyle(
            //       padding: ButtonState.all(const EdgeInsets.only(
            //           top: 10, bottom: 10, right: 15, left: 15))),
            // ))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: deliveriesFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    // Material.DataColumn(label: Text('Id Pelanggan')),
                    Material.DataColumn(label: Text('Kode Pengiriman')),
                    Material.DataColumn(label: Text('Tanggal Pengiriman')),
                    Material.DataColumn(label: Text('Nomor Plat Mobil')),
                    Material.DataColumn(label: Text('Nama Pengirim')),
                    Material.DataColumn(label: Text('Deskripsi')),
                  ],
                  source: _data,
                  columnSpacing: 80,
                  horizontalMargin: 30,
                  rowsPerPage: 8,
                );
              } else {
                child = const Center(
                  heightFactor: 10,
                  child: ProgressRing(),
                );
              }
              return child;
            }),
        Container(
          child: Button(
            child: const Text("Laporan"),
            onPressed: () async {
              if (_dateStart == null && _dateEnd == null) {
                showDialog<String>(
                  context: context,
                  builder: (context) => ContentDialog(
                    style: ContentDialogThemeData(
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20))),
                    constraints: const BoxConstraints(maxWidth: 450),
                    title: Row(
                      children: [
                        const Icon(
                          Material.Icons.warning,
                          size: 35,
                        ),
                        Spacer(),
                        Text(
                          "Maaf, Tanggal Harus Dipilih !",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                    actions: [
                      Button(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                );
              } else {
                final laporanPdfFile = await PdfDeliveryReportApi.generate(
                    filter: selectedFilter,
                    value: val,
                    dateEnd: dateEnd!,
                    dateStart: dateStart!);
                await FileHandleApi.openFile(laporanPdfFile);
              }
            },
            style: ButtonStyle(
                padding: ButtonState.all(const EdgeInsets.only(
                    top: 10, bottom: 10, right: 15, left: 15))),
          ),
        )
      ],
    );
  }
}

class DataTable extends Material.DataTableSource {
  final BuildContext context;
  DataTable({required this.context});
  final List<Map<String, dynamic>> _data = List.generate(
      deliveries?.length ?? 500,
      (index) => {
            "id": deliveries?[index].deliveryId,
            "deliveryCode": deliveries?[index].deliveryCode,
            "deliveryDate": deliveries?[index].deliveryDate,
            "carPlatNumber": deliveries?[index].carPlatNumber,
            "senderName": deliveries?[index].senderName,
            "deliveryDesc": deliveries?[index].deliveryDesc ?? "-",
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(
        Text(_data[index]['deliveryCode'].toString()),
        onTap: () {
          showDeliveryDetail(context, _data[index]['id'].toString());
        },
      ),
      Material.DataCell(Text(dateFormatter(_data[index]['deliveryDate']))),
      Material.DataCell(Text(_data[index]['carPlatNumber'].toString())),
      Material.DataCell(Text(_data[index]['senderName'].toString())),
      Material.DataCell(Text(_data[index]['deliveryDesc'].toString())),
    ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _data.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
