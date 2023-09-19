import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/models/product_color.dart';
import 'package:example/screens/fabricatingMaterial_screen.dart';
import 'package:example/widgets/order/edit_order_modal_content.dart';
import 'package:im_animations/im_animations.dart';
import 'package:example/services/order.dart';
import 'package:example/widgets/deliver_order_widget.dart';
import 'package:example/widgets/order/add_order_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:url_launcher/link.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_order_report_api.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../models/product.dart';
import '../models/order.dart';

import '../widgets/product/add_product_modal_content.dart';

List<Order>? backupOrders;
List<Order>? orders;
List<Order>? detailOrders;
List<Order>? searchedOrders;
List selectedOrder = [];

Future<String> checker(BuildContext context, String orderCode) async {
  OrderService _orderService = OrderService();
  var response = await _orderService.checkOrderValid(orderCode: orderCode);

  return response.status!;
}

showDetailOrder(BuildContext context, String orderCode) async {
  OrderService _orderService = OrderService();

  var response = await _orderService.getOrderByCode(orderCode);

  detailOrders = response.data;

  List<Widget> list = [];
  detailOrders!.forEach((element) {
    if (element.product != null) {
      list.add(Padding(
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
                  Text(element.name!)
                ],
              ),
              Row(
                children: [
                  Text(
                    "Kuantiti : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(element.qty!)
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
    } else if (element.material != null) {
      list.add(Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Bahan Baku : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(element.name!)
                ],
              ),
              Row(
                children: [
                  Text(
                    "Kuantiti : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(element.qty!)
                ],
              ),
              element.deliveryId == null
                  ? int.tryParse(element.material!.materialQty!)! -
                              int.tryParse(element.qty!)! <
                          0
                      ? InfoBar(
                          title: Text("Kuantiti bahan baku tidak mencukupi"),
                          severity: InfoBarSeverity.error,
                          isLong: true,
                        )
                      : InfoBar(
                          title: Text("Kuantiti bahan baku mencukupi"),
                          severity: InfoBarSeverity.success,
                          isLong: true,
                        )
                  : Container()
            ],
          ),
        ),
      ));
    } else if (element.fabricatingMaterial != null) {
      list.add(Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Barang 1/2 Jadi : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(element.name!)
                ],
              ),
              Row(
                children: [
                  Text(
                    "Kuantiti : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(element.qty!)
                ],
              ),
              element.deliveryId == null
                  ? int.tryParse(element.fabricatingMaterial!
                                  .fabricatingMaterialQty!)! -
                              int.tryParse(element.qty!)! <
                          0
                      ? InfoBar(
                          title:
                              Text("Kuantiti barang 1/2 jadi tidak mencukupi"),
                          severity: InfoBarSeverity.error,
                          isLong: true,
                        )
                      : InfoBar(
                          title: Text("Kuantiti barang 1/2 jadi mencukupi"),
                          severity: InfoBarSeverity.success,
                          isLong: true,
                        )
                  : Container()
            ],
          ),
        ),
      ));
    }
  });
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Daftar Produk'),
      content: ScaffoldPage.scrollable(children: list),
      actions: [
        FilledButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    ),
  );
}

class OrderPage extends StatefulWidget {
  static final GlobalKey<_OrderPageState> globalKey = GlobalKey();
  OrderPage({
    Key? key,
  }) : super(key: globalKey);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with PageMixin {
  bool checkedAll = false;
  bool filterIsDelivered = false;
  bool filterIsNotDelivered = true;

  bool barrierDismissible = true;
  bool dismissOnPointerMoveAway = false;
  bool dismissWithEsc = true;
  FlyoutPlacementMode placementMode = FlyoutPlacementMode.topCenter;

  DateTime? _dateTimeStart;
  DateTime? _dateTimeEnd;
  DateTime? _dateStart;
  DateTime? _dateEnd;
  DateTime? _date;

  String _formateDateStart = "";
  String _formateDateEnd = "";
  String _formateDate = "";

  bool selected = true;
  String? comboboxValue;
  OrderService _orderService = OrderService();
  String? message;
  String? status;

  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  FlyoutController buttonController = FlyoutController();
  FlyoutController getOrderDetailController = FlyoutController();

  showAddDeliveryModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Kirim Pesanan'),
        content: AddDeliveryModalContent(),
        actions: [
          Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Tambah'),
              onPressed: () {
                setState(() {
                  AddDeliveryModalContent.globalKey.currentState!
                      .postDelivery(selectedOrder);
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  showAddOrderModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Sales Order'),
        content: AddOrderModalContent(),
        actions: [
          Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Tambah'),
              onPressed: () {
                setState(() {
                  AddOrderModalContent.globalKey.currentState!.createOrder();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  showEditOrderModal(
    String orderCode,
    desc,
    requestedDeliveryDate,
    customerId,
    customerName,
    List<Map<String, dynamic>> selectedProducts,
  ) async {
    print("HELLO");
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Edit Sales Order'),
        content: EditOrderModalContent(
          orderCode: orderCode,
          desc: desc,
          requestedDeliveryDate: requestedDeliveryDate,
          customerId: customerId,
          customerName: customerName,
          selectedProducts: selectedProducts,
        ),
        actions: [
          Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Ubah'),
              onPressed: () {
                setState(() {
                  EditOrderModalContent.globalKey.currentState!.updateOrder();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  getOrders() async {
    var response = await _orderService.getOrdersGrouped();
    orders = response.data;
    backupOrders = orders;
    print("Get to View Product: ${orders!.length}");

    if (filterIsNotDelivered) {
      orders = backupOrders;
      orders = orders!.where((order) => order.deliveryId == null).toList();
    }

    _data = DataTable(context: context);
  }

  late Future orderFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Kode Pesanan", "Pelanggan"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orderFuture = getOrders();

    setState(() {});
  }

  String val = "";
  String cek = "";
  DateTime? dateStart;
  DateTime? dateEnd;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Sales Order'),
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      checked: filterIsDelivered,
                      onChanged: (value) {
                        print(cek);
                        setState(() {
                          cek = "Sudah dikirim";
                          print("Terkirim $cek");
                        });
                        setState(() {
                          filterIsDelivered = value!;
                          if (value != false) {
                            filterIsNotDelivered = !value;
                          }
                          if (filterIsDelivered) {
                            orders = backupOrders;
                            orders = orders!
                                .where((order) => order.deliveryId != null)
                                .toList();
                            _data = DataTable(context: context);
                          } else if (filterIsNotDelivered) {
                            orders = backupOrders;
                            orders = orders!
                                .where((order) => order.deliveryId == null)
                                .toList();
                            _data = DataTable(context: context);
                          } else {
                            setState(() {
                              orderFuture = getOrders();
                            });
                          }
                        });
                      },
                      content: Text("Sudah Dikirim"),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Checkbox(
                      checked: filterIsNotDelivered,
                      onChanged: (value) {
                        setState(() {
                          cek = "Belum dikirim";
                          print("Belum $cek");
                        });
                        setState(() {
                          filterIsNotDelivered = value!;
                          if (value != false) {
                            filterIsDelivered = !value;
                          }
                          if (filterIsNotDelivered == false &&
                              filterIsDelivered == false) {
                            setState(() {
                              cek = "";
                              print("tidak dua duanya $cek");
                              orderFuture = getOrders();
                            });
                          } else if (filterIsDelivered) {
                            orders = backupOrders;
                            orders = orders!
                                .where((order) => order.deliveryId != null)
                                .toList();
                            _data = DataTable(context: context);
                          } else if (filterIsNotDelivered) {
                            orders = backupOrders;
                            orders = orders!
                                .where((order) => order.deliveryId == null)
                                .toList();
                            _data = DataTable(context: context);
                          }
                        });
                      },
                      content: Text("Belum Dikirim"),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
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
                                orderFuture = getOrders();
                              });
                            } else if (filterIsDelivered == true) {
                              if (selectedFilter == "Kode Pesanan") {
                                setState(() {
                                  orders = backupOrders;
                                  orders = orders!.where((order) {
                                    if (order.deliveryId != null) {
                                      return order.orderCode!
                                          .contains(value.toString());
                                    }
                                    return filterIsNotDelivered;
                                  }).toList();
                                  _data = DataTable(context: context);
                                });
                              } else if (selectedFilter == "Pelanggan") {
                                setState(() {
                                  orders = backupOrders;
                                  orders = orders!.where((order) {
                                    if (order.deliveryId != null) {
                                      return order.customer!.customerName!
                                          .toLowerCase()
                                          .contains(value.toLowerCase());
                                    }
                                    return order.orderCode!.contains(value);
                                  }).toList();
                                  _data = DataTable(context: context);
                                });
                              } else {
                                setState(() {});
                              }
                            } else if (filterIsNotDelivered == true) {
                              if (selectedFilter == "Kode Pesanan") {
                                setState(() {
                                  orders = backupOrders;
                                  orders = orders!.where((order) {
                                    if (order.deliveryId == null) {
                                      return order.orderCode!
                                          .contains(value.toString());
                                    }
                                    return filterIsDelivered;
                                  }).toList();
                                  _data = DataTable(context: context);
                                });
                              } else if (selectedFilter == "Pelanggan") {
                                setState(() {
                                  orders = backupOrders;
                                  orders = orders!.where((order) {
                                    if (order.deliveryId == null) {
                                      return order.customer!.customerName!
                                          .toLowerCase()
                                          .contains(value.toLowerCase());
                                    }
                                    return order.orderCode!.contains(value);
                                  }).toList();
                                  _data = DataTable(context: context);
                                });
                              } else {
                                setState(() {});
                              }
                            } else {
                              setState(() {});
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
                        placeholder: Text("Cari Berdasarkan"),
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
                            _formateDateEnd = formatDate(
                                _dateTimeEnd!, [yyyy, '-', mm, '-', dd]);
                            _formateDateStart = formatDate(
                                _dateTimeStart!, [yyyy, '-', mm, '-', dd]);

                            _dateStart = DateTime.parse(_formateDateStart);
                            _dateEnd = DateTime.parse(_formateDateEnd);

                            dateEnd = _dateEnd;
                            dateStart = _dateStart;

                            if (filterIsDelivered == true) {
                              orders = backupOrders;
                              orders = orders!.where((order) {
                                _formateDate =
                                    order.orderDate!.substring(0, 10);
                                _date = DateTime.parse(_formateDate);

                                if (order.deliveryId != null) {
                                  return (_date!
                                              .isAtSameMomentAs(_dateStart!) ||
                                          _date!.isAtSameMomentAs(_dateEnd!)) ||
                                      (_date!.isBefore(_dateEnd!) &&
                                          _date!.isAfter(_dateStart!));
                                }
                                return filterIsNotDelivered;
                              }).toList();
                              _data = DataTable(context: context);
                              print("Date : $_date");
                            } else if (filterIsDelivered == false) {
                              orders = backupOrders;
                              orders = orders!.where((order) {
                                _formateDate =
                                    order.orderDate!.substring(0, 10);
                                _date = DateTime.parse(_formateDate);

                                if (order.deliveryId == null) {
                                  return (_date!
                                              .isAtSameMomentAs(_dateStart!) ||
                                          _date!.isAtSameMomentAs(_dateEnd!)) ||
                                      (_date!.isBefore(_dateEnd!) &&
                                          _date!.isAfter(_dateStart!));
                                }
                                return filterIsDelivered;
                              }).toList();
                              _data = DataTable(context: context);
                              print("Date : $_date");
                            }
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
                            _dateEnd = null;
                            _dateStart = null;
                            cek = "";
                            orderFuture = getOrders();
                          });
                        })
                  ],
                ),
              ],
            ),
            Container(
                child: Button(
              child: Text("Tambah Sales Order"),
              onPressed: (() async {
                await showAddOrderModal(context);
                setState(() {
                  orderFuture = getOrders();
                });
              }),
              style: ButtonStyle(
                  padding: ButtonState.all(EdgeInsets.only(
                      top: 10, bottom: 10, right: 15, left: 15))),
            ))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: orderFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                if (orders!.isEmpty || orders == null) {
                  child = const Center(
                    heightFactor: 10,
                    child: Text("Tidak Ada Data Pesanan"),
                  );
                } else {
                  child = Material.PaginatedDataTable(
                    header: FlyoutTarget(
                      controller: buttonController,
                      // [content] is the content of the flyout popup, opened when the user presses
                      // the button

                      child: Button(
                        child: const Text('Kirim Sales Order'),
                        onPressed: () async {
                          setState(() {});
                          if (selectedOrder.isEmpty) {
                            buttonController.showFlyout(
                                autoModeConfiguration: FlyoutAutoConfiguration(
                                  preferredMode: placementMode,
                                ),
                                barrierDismissible: barrierDismissible,
                                dismissOnPointerMoveAway:
                                    dismissOnPointerMoveAway,
                                dismissWithEsc: dismissWithEsc,
                                builder: (context) {
                                  return FlyoutContent(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tidak ada pesanan yang dipilih\npilih setidaknya satu(1) pesanan',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Button(
                                          child: const Text('Ok'),
                                          onPressed: Flyout.of(context).close,
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          } else {
                            await showAddDeliveryModal(context);
                            setState(() {
                              checkedAll = false;
                              selectedOrder = [];
                              orderFuture = getOrders();
                            });
                          }
                        },
                      ),
                    ),
                    horizontalMargin: 0,
                    columnSpacing: 10,
                    columns: [
                      Material.DataColumn(
                        label: filterIsDelivered
                            ? Text('')
                            : Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Checkbox(
                                  checked: checkedAll,
                                  onChanged: (isSelected) {
                                    setState(() {
                                      checkedAll = isSelected!;
                                      if (checkedAll) {
                                        orders!.forEach((element) {
                                          if (element.deliveryId == null) {
                                            selectedOrder
                                                .add(element.orderCode);
                                          }
                                        });
                                      } else {
                                        selectedOrder = [];
                                      }
                                      print("SELECTED ORDER");
                                      print(selectedOrder);
                                      _data = DataTable(context: context);
                                    });
                                  },
                                ),
                              ),
                      ),
                      Material.DataColumn(label: Text('Kode Sales Order')),
                      Material.DataColumn(label: Text('Pelanggan')),
                      Material.DataColumn(label: Text('Tanggal Pemesanan')),
                      Material.DataColumn(
                          label: Text('Tanggal Permintaan Pengiriman')),
                      Material.DataColumn(label: Text('Deskripsi')),
                      Material.DataColumn(label: Text('Status')),
                      Material.DataColumn(label: Text('Tanggal dikirim')),
                      Material.DataColumn(label: Text('Aksi')),
                    ],
                    source: () {
                      return _data;
                    }(),
                    rowsPerPage: 12,
                  );
                }
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
                final laporanPdfFile = await PdfOrderReportApi.generate(
                    check: cek,
                    filter: selectedFilter,
                    value: val,
                    dateEnd: dateEnd!,
                    dateStart: dateStart!);
                await FileHandleApi.openFile(laporanPdfFile);
              }
              ;
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
  int? deliveryId;
  DataTable({required this.context, this.deliveryId});
  final List<Map<String, dynamic>> _data = List.generate(
      orders?.length ?? 500,
      (index) => {
            "id": orders?[index].orderId,
            "orderCode": orders?[index].orderCode,
            "customerId": orders?[index].customer?.customerId,
            "customerName": orders?[index].customer?.customerName,
            "orderDate": orders?[index].orderDate,
            "requestedDeliveryDate": orders?[index].requestedDeliveryDate,
            "orderDesc": orders?[index].orderDesc ?? "-",
            "orderStatus": orders?[index].orderStatus,
            "deliveryDate": orders?[index].delivery?.deliveryDate ?? "-",
            "deliveryId": orders?[index].deliveryId
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(
      cells: [
        Material.DataCell(StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _data[index]['deliveryDate'] == "-"
                  ? Checkbox(
                      checked:
                          selectedOrder.contains(_data[index]['orderCode']),
                      onChanged: (isSelected) {
                        print(_data[index]['orderCode']);
                        setState(() {
                          final isAdding = isSelected != null && isSelected;
                          isAdding
                              ? selectedOrder.add(_data[index]['orderCode'])
                              : selectedOrder.remove(_data[index]['orderCode']);
                        });
                      },
                    )
                  : Checkbox(checked: true, onChanged: null),
            );
          },
        )),
        Material.DataCell(
          FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                String? data = snapshot.data;
                print(data);
                return Padding(
                    padding: const EdgeInsets.only(right: 80),
                    child: _data[index]['deliveryId'] == null
                        ? Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child:
                                    Text(_data[index]['orderCode'].toString()),
                              ),
                              data == "error"
                                  ? Icon(
                                      FluentIcons.product_warning,
                                      color: Colors.red,
                                    )
                                  : Text("")
                            ],
                          )
                        : Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child:
                                    Text(_data[index]['orderCode'].toString()),
                              ),
                              Icon(
                                FluentIcons.check_mark,
                                color: Colors.green,
                              )
                            ],
                          ));
              } else {
                return Padding(
                  padding: const EdgeInsets.only(right: 80),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(_data[index]['orderCode'].toString()),
                      ),
                    ],
                  ),
                );
              }
            },
            future: checker(context, _data[index]['orderCode']),
          ),
          onTap: () {
            print("Hello");
            showDetailOrder(context, _data[index]['orderCode']);
          },
        ),
        Material.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data[index]['customerName'].toString()),
        )),
        Material.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(dateFormatter(_data[index]['orderDate'])),
        )),
        Material.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(dateFormatter(_data[index]['requestedDeliveryDate'])),
        )),
        Material.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data[index]['orderDesc'].toString()),
        )),
        Material.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data[index]['orderStatus'].toString()),
        )),
        Material.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(dateFormatter(_data[index]['deliveryDate'])),
        )),
        if (_data[index]['orderStatus'] == "Belum dikirim")
          Material.DataCell(Material.Row(
            children: [
              IconButton(
                  onPressed: () async {
                    List<Map<String, dynamic>> _selectedProducts = [];

                    OrderService _orderService = OrderService();
                    List<Order> _detailOrders;
                    var response = await _orderService
                        .getOrderByCode(_data[index]['orderCode']);

                    detailOrders = response.data;
                    detailOrders!.forEach((element) {
                      if (element.productId != null) {
                        _selectedProducts.add({
                          "productId": element.productId,
                          "materialId": null,
                          "fabricatingMaterialId": null,
                          "qty": element.qty,
                          "price": element.price,
                          "name": element.name,
                          "label": element.name
                        });
                      } else if (element.fabricatingMaterialId != null) {
                        _selectedProducts.add({
                          "productId": null,
                          "materialId": null,
                          "fabricatingMaterialId":
                              element.fabricatingMaterialId,
                          "qty": element.qty,
                          "price": element.price,
                          "name": element.name,
                          "label": element.name
                        });
                      } else if (element.materialId != null) {
                        _selectedProducts.add({
                          "productId": null,
                          "materialId": element.materialId,
                          "fabricatingMaterialId": null,
                          "qty": element.qty,
                          "price": element.price,
                          "name": element.name,
                          "label": element.name
                        });
                      }
                    });
                    OrderPage.globalKey.currentState!.showEditOrderModal(
                        _data[index]['orderCode'],
                        _data[index]['orderDesc'],
                        _data[index]['requestedDeliveryDate'],
                        _data[index]['customerId'],
                        _data[index]['customerName'],
                        _selectedProducts);
                  },
                  icon: const Icon(FluentIcons.edit, size: 24.0)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(FluentIcons.delete, size: 24.0))
            ],
          ))
        else
          Material.DataCell(Text(''))
      ],
    );
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
