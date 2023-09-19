import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/services/report/pdf_materialSpending_report_api.dart';
import 'package:intl/intl.dart';
import 'package:example/models/material_spending.dart';
import 'package:example/models/product_color.dart';
import 'package:example/widgets/bahanbaku/add_material_purchase.dart';
import 'package:example/widgets/bahanbaku/add_material_spending.dart';
import 'package:im_animations/im_animations.dart';
import 'package:example/services/material_spending.dart';
import 'package:example/widgets/deliver_order_widget.dart';
import 'package:example/widgets/order/add_order_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as FlutterMaterial;
import 'package:url_launcher/link.dart';
import 'package:example/services/file_handle_api.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/material.dart';

import '../widgets/product/add_product_modal_content.dart';

List<MaterialSpending>? backupMaterialSpendings;
List<MaterialSpending>? materialSpendings;
List<MaterialSpending>? materialSpendings2;
List<MaterialSpending>? detailMaterialSpendings;
List<MaterialSpending>? searchedMaterialSpendings;
List selectedOrder = [];

Future<List<MaterialSpending>> getMaterialSpendingsDetail(
    {required String materialSpendingCode}) async {
  MaterialSpendingService _materialPurchaseService = MaterialSpendingService();
  var response = await _materialPurchaseService
      .getMaterialSpendingByCode(materialSpendingCode);
  List<MaterialSpending> _materialSpendings = response.data;
  return _materialSpendings;
}

class MaterialSpendingPage extends StatefulWidget {
  static final GlobalKey<_MaterialSpendingPageState> globalKey = GlobalKey();
  int? deliveryId;
  MaterialSpendingPage({Key? key, this.deliveryId}) : super(key: globalKey);

  @override
  State<MaterialSpendingPage> createState() => _MaterialSpendingPageState();
}

class _MaterialSpendingPageState extends State<MaterialSpendingPage>
    with PageMixin {
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
  MaterialSpendingService _materialSpendingService = MaterialSpendingService();
  String? message;
  String? status;

  late FlutterMaterial.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  FlyoutController buttonController = FlyoutController();
  FlyoutController getOrderDetailController = FlyoutController();

  removeSpending({required String materialSpendingCode}) async {
    var response = await _materialSpendingService.deleteSpending(
        materialSpendingCode: materialSpendingCode);
    var message = response.message;
    print(message);
  }

  showRemoveSpendingModal(String materialSpendingCode) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Produksi'),
        content: Text("Apakah anda yakin akan menghapus pengeluaran ini?"),
        actions: [
          Button(
            child: const Text('Tidak'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Ya'),
              onPressed: () async {
                await removeSpending(
                    materialSpendingCode: materialSpendingCode);
                setState(() {
                  materialSpendingFuture = getMaterialSpendings();
                });
                Navigator.pop(context, 'User deleted file');
              }),
        ],
      ),
    );
  }

  showAddDeliveryModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Pengeluaran Barang'),
        content: AddDeliveryModalContent(),
        actions: [
          Button(
            child: const Text("Batal"),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
            },
          ),
          FilledButton(
              child: const Text("Tambah"),
              onPressed: () {
                setState(() {
                  AddDeliveryModalContent.globalKey.currentState!
                      .postDelivery(selectedOrder);
                });
              })
        ],
      ),
    );
    setState(() {});
  }

  showAddMaterialSpendingModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Pengeluaran Bahan Produksi'),
        content: AddMaterialSpendingModalContent(),
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
                  AddMaterialSpendingModalContent.globalKey.currentState!
                      .createMaterialSpendings();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  getMaterialSpendings() async {
    var response = await _materialSpendingService.getMaterialSpendingGrouped();
    materialSpendings = response.data;
    backupMaterialSpendings = materialSpendings;

    _data = DataTable(context: context);
  }

  late Future materialSpendingFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Kode Pengeluaran Barang", "Barang"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    materialSpendingFuture = getMaterialSpendings();
    setState(() {});
  }

  String val = "";
  DateTime? dateStart;
  DateTime? dateEnd;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: const Text('Pengeluaran Bahan Produksi'),
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
                            materialSpendingFuture = getMaterialSpendings();
                          });
                        } else {
                          if (selectedFilter == "Kode Pengeluaran Barang") {
                            setState(() {
                              materialSpendings = backupMaterialSpendings;
                              materialSpendings = materialSpendings!
                                  .where((materialSpending) => materialSpending
                                      .materialSpendingCode!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable(context: context);
                            });
                          } else if (selectedFilter == "Barang") {
                            setState(() {
                              materialSpendings = backupMaterialSpendings;
                              materialSpendings2 = backupMaterialSpendings;
                              materialSpendings =
                                  materialSpendings!.where((materialSpending) {
                                if (materialSpending.material != null) {
                                  return materialSpending
                                      .material!.materialName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return materialSpending.materialSpendingCode!
                                    .contains(value);
                              }).toList();

                              materialSpendings2 =
                                  materialSpendings2!.where((materialSpending) {
                                if (materialSpending.fabricatingMaterial !=
                                    null) {
                                  return materialSpending.fabricatingMaterial!
                                      .fabricatingMaterialName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return materialSpending.materialSpendingCode!
                                    .contains(value);
                              }).toList();

                              materialSpendings!.addAll(materialSpendings2!);

                              print("---Searched Product---");
                              _data = DataTable(context: context);
                              materialSpendings!.forEach((element) {
                                print(element);
                              });
                            });
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
                  icon: const Icon(FlutterMaterial.Icons.date_range),
                  onPressed: () {
                    FlutterMaterial.showDateRangePicker(
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

                        materialSpendings = backupMaterialSpendings;
                        materialSpendings =
                            materialSpendings!.where((materialSpending) {
                          _formateDate = materialSpending.materialSpendingDate!
                              .substring(0, 10);
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
                    icon: const Icon(FlutterMaterial.Icons.refresh),
                    onPressed: () {
                      setState(() {
                        val = "";
                        _dateEnd = null;
                        _dateStart = null;
                        materialSpendingFuture = getMaterialSpendings();
                      });
                    })
              ],
            ),
            Container(
                child: Button(
              child: Text("Tambah Pengeluaran Bahan"),
              onPressed: (() async {
                await showAddMaterialSpendingModal(context);
                setState(() {
                  materialSpendingFuture = getMaterialSpendings();
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
            future: materialSpendingFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                if (materialSpendings!.isEmpty || materialSpendings == null) {
                  child = const Center(
                    heightFactor: 10,
                    child: Text("Tidak Ada Data Pengeluaran barang"),
                  );
                } else {
                  child = FlutterMaterial.PaginatedDataTable(
                    columnSpacing: 80,
                    horizontalMargin: 30,
                    columns: const [
                      FlutterMaterial.DataColumn(
                          label: Text('Kode pengeluaran barang')),
                      FlutterMaterial.DataColumn(label: Text('Barang')),
                      FlutterMaterial.DataColumn(
                          label: Text('Kuantiti pengeluaran')),
                      FlutterMaterial.DataColumn(
                          label: Text('Tanggal pengeluaran')),
                      FlutterMaterial.DataColumn(label: Text('Aksi'))
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
                          FlutterMaterial.Icons.warning,
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
                final laporanPdfFile =
                    await PdfMaterialSpendingReportApi.generate(
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

class DataTable extends FlutterMaterial.DataTableSource {
  final BuildContext context;
  DataTable({required this.context});
  final List<Map<String, dynamic>> _data = List.generate(
      materialSpendings?.length ?? 500,
      (index) => {
            "id": materialSpendings?[index].materialSpendingId,
            "materialSpendingCode":
                materialSpendings?[index].materialSpendingCode,
            "materialSpendingDate":
                materialSpendings?[index].materialSpendingDate,
          });

  @override
  FlutterMaterial.DataRow? getRow(int index) {
    return FlutterMaterial.DataRow(
      cells: [
        FlutterMaterial.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data[index]['materialSpendingCode'].toString()),
        )),
        FlutterMaterial.DataCell(
          Padding(
              padding: const EdgeInsets.only(right: 80),
              child: FutureBuilder(
                future: getMaterialSpendingsDetail(
                    materialSpendingCode: _data[index]['materialSpendingCode']),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  Widget child;
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<MaterialSpending> _materialSpendings = snapshot.data;

                    child = SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (MaterialSpending materialSpending
                              in _materialSpendings)
                            Text(
                                "- ${materialSpending.material?.materialName ?? materialSpending.fabricatingMaterial?.fabricatingMaterialName}")
                        ],
                      ),
                    );

                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     for (MaterialSpending materialSpending
                    //         in _materialSpendings)
                    //       Text(
                    //           "- ${materialSpending.material?.materialName ?? materialSpending.fabricatingMaterial?.fabricatingMaterialName}")
                    //   ],
                    // );
                  } else {
                    child = Container();
                  }
                  return child;
                },
              )),
        ),
        FlutterMaterial.DataCell(
          Padding(
              padding: const EdgeInsets.only(right: 80),
              child: FutureBuilder(
                future: getMaterialSpendingsDetail(
                    materialSpendingCode: _data[index]['materialSpendingCode']),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  Widget child;
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<MaterialSpending> _materialSpendings = snapshot.data;

                    child = SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (MaterialSpending materialSpending
                              in _materialSpendings)
                            Text(
                                "- ${materialSpending.materialSpendingQty!} (${materialSpending.material?.materialUnit ?? materialSpending.fabricatingMaterial?.fabricatingMaterialUnit ?? "Pcs"})")
                        ],
                      ),
                    );
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     for (MaterialSpending materialSpending
                    //         in _materialSpendings)
                    //       Text(
                    //           "- ${materialSpending.materialSpendingQty!} (${materialSpending.material?.materialUnit ?? materialSpending.fabricatingMaterial?.fabricatingMaterialUnit})")
                    //   ],
                    // );
                  } else {
                    child = Container();
                  }
                  return child;
                },
              )),
        ),
        FlutterMaterial.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(dateFormatter(_data[index]['materialSpendingDate'])),
        )),
        FlutterMaterial.DataCell(FlutterMaterial.Row(
          children: [
            IconButton(
                onPressed: () {
                  MaterialSpendingPage.globalKey.currentState!
                      .showRemoveSpendingModal(
                          _data[index]['materialSpendingCode']);
                },
                icon: const Icon(FluentIcons.delete, size: 24.0))
          ],
        ))
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
