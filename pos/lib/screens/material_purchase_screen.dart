import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:example/models/material_purchase.dart';
import 'package:example/models/product_color.dart';
import 'package:example/widgets/bahanbaku/add_material_purchase.dart';
import 'package:im_animations/im_animations.dart';
import 'package:example/services/material_purchase.dart';
import 'package:example/widgets/deliver_order_widget.dart';
import 'package:example/widgets/order/add_order_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as FlutterMaterial;
import 'package:url_launcher/link.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_material_purchase_report_api.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/material.dart';

import '../widgets/product/add_product_modal_content.dart';

List<MaterialPurchase>? backupMaterialPurchases;
List<MaterialPurchase>? materialPurchases;
List<MaterialPurchase>? materialPurchases2;
List<MaterialPurchase>? materialPurchases3;

List<MaterialPurchase>? detailMaterialPurchases;
List<MaterialPurchase>? searchedMaterialPurchases;
List selectedOrder = [];

Future<List<MaterialPurchase>> getMaterialPurchasesDetail(
    {required String materialPurchaseCode}) async {
  MaterialPurchaseService _materialPurchaseService = MaterialPurchaseService();
  var response = await _materialPurchaseService
      .getMaterialPurchaseByCode(materialPurchaseCode);
  List<MaterialPurchase> _materialPurchases = response.data;
  return _materialPurchases;
}

// showDetailOrder(BuildContext context, String materialPurchaseCode) async {
//   MaterialPurchaseService _materialPurchaseService = MaterialPurchaseService();

//   var response = await _materialPurchaseService
//       .getMaterialPurchaseByCode(materialPurchaseCode);

//   detailMaterialPurchases = response.data;

//   List<Widget> list = [];
//   detailMaterialPurchases!.forEach((element) {
//     list.add(Padding(
//       padding: const EdgeInsets.only(bottom: 5),
//       child: Card(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   "Material : ",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(element.material!.materialName!)
//               ],
//             ),
//             Row(
//               children: [
//                 Text(
//                   "Kuantiti : ",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(element.materialPurchaseQty!)
//               ],
//             ),
//             element.deliveryId == null
//                 ? int.tryParse(element.product!.productQty!)! -
//                             int.tryParse(element.qty!)! <
//                         0
//                     ? InfoBar(
//                         title: Text("Kuantiti produk tidak mencukupi"),
//                         severity: InfoBarSeverity.error,
//                         isLong: true,
//                       )
//                     : InfoBar(
//                         title: Text("Kuantiti produk mencukupi"),
//                         severity: InfoBarSeverity.success,
//                         isLong: true,
//                       )
//                 : Container()
//           ],
//         ),
//       ),
//     ));
//   });
//   final result = await showDialog<String>(
//     context: context,
//     builder: (context) => ContentDialog(
//       constraints: const BoxConstraints(maxWidth: 500),
//       title: const Text('Daftar Produk'),
//       content: ScaffoldPage.scrollable(children: list),
//       actions: [
//         FilledButton(
//             child: const Text('Ok'),
//             onPressed: () {
//               Navigator.pop(context);
//             }),
//       ],
//     ),
//   );
// }

class MaterialPurchasePage extends StatefulWidget {
  static final GlobalKey<_MaterialPurchasePageState> globalKey = GlobalKey();
  int? deliveryId;
  MaterialPurchasePage({Key? key, this.deliveryId}) : super(key: globalKey);

  @override
  State<MaterialPurchasePage> createState() => _MaterialPurchasePageState();
}

class _MaterialPurchasePageState extends State<MaterialPurchasePage>
    with PageMixin {
  bool selected = true;
  String? comboboxValue;
  MaterialPurchaseService _materialPurchaseService = MaterialPurchaseService();
  String? message;
  String? status;

  DateTime? _dateTimeStart;
  DateTime? _dateTimeEnd;
  DateTime? _dateStart;
  DateTime? _dateEnd;
  DateTime? _date;

  String _formateDateStart = "";
  String _formateDateEnd = "";
  String _formateDate = "";

  late FlutterMaterial.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  FlyoutController buttonController = FlyoutController();
  FlyoutController getOrderDetailController = FlyoutController();

  removePurchase({required String materialPurchaseCode}) async {
    var response = await _materialPurchaseService.deletePurchase(
        materialPurchaseCode: materialPurchaseCode);
    var message = response.message;
    print(message);
  }

  showRemovePurchaseModal(String materialPurchaseCode) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Produksi'),
        content: Text("Apakah anda yakin akan menghapus pembelian ini?"),
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
                await removePurchase(
                    materialPurchaseCode: materialPurchaseCode);
                setState(() {
                  materialPurchaseFuture = getMaterialPurchases();
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
        title: const Text('Purchase'),
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

  showAddMaterialPurchaseModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Purchase Order'),
        content: AddMaterialPurchaseModalContent(),
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
                  AddMaterialPurchaseModalContent.globalKey.currentState!
                      .createMaterialPurchases();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  getMaterialPurchases() async {
    var response = await _materialPurchaseService.getMaterialPurchaseGrouped();
    materialPurchases = response.data;
    backupMaterialPurchases = materialPurchases;

    _data = DataTable(context: context);
  }

  late Future materialPurchaseFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Kode Pembelian", "Pemasok", "Barang"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    materialPurchaseFuture = getMaterialPurchases();
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
        title: const Text('Purchase'),
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
                            materialPurchaseFuture = getMaterialPurchases();
                          });
                        } else {
                          if (selectedFilter == "Kode Pembelian") {
                            setState(() {
                              materialPurchases = backupMaterialPurchases;
                              materialPurchases = materialPurchases!
                                  .where((purchase) => purchase
                                      .materialPurchaseCode!
                                      .contains(value))
                                  .toList();
                              _data = DataTable(context: context);
                            });
                          } else if (selectedFilter == "Pemasok") {
                            setState(() {
                              materialPurchases = backupMaterialPurchases;
                              materialPurchases = materialPurchases!
                                  .where((purchase) => purchase
                                      .supplier!.supplierName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable(context: context);
                            });
                          } else if (selectedFilter == "Barang") {
                            setState(() {
                              materialPurchases = backupMaterialPurchases;
                              materialPurchases2 = backupMaterialPurchases;
                              materialPurchases3 = backupMaterialPurchases;

                              materialPurchases =
                                  materialPurchases!.where((purchase) {
                                if (purchase.material != null) {
                                  return purchase.material!.materialName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return purchase.materialPurchaseCode!
                                    .contains(value);
                              }).toList();

                              materialPurchases2 =
                                  materialPurchases2!.where((purchase) {
                                if (purchase.fabricatingMaterial != null) {
                                  return purchase.fabricatingMaterial!
                                      .fabricatingMaterialName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return purchase.materialPurchaseCode!
                                    .contains(value);
                              }).toList();
                              materialPurchases!.addAll(materialPurchases2!);
                              _data = DataTable(context: context);

                              materialPurchases3 =
                                  materialPurchases3!.where((purchase) {
                                if (purchase.product != null) {
                                  return purchase.product!.productName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return purchase.materialPurchaseCode!
                                    .contains(value);
                              }).toList();

                              materialPurchases!.addAll(materialPurchases3!);
                              print("---Searched Product---");
                              _data = DataTable(context: context);
                              materialPurchases!.forEach((element) {
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

                        materialPurchases = backupMaterialPurchases;
                        materialPurchases =
                            materialPurchases!.where((purchase) {
                          _formateDate =
                              purchase.materialPurchaseDate!.substring(0, 10);
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
                        materialPurchaseFuture = getMaterialPurchases();
                      });
                    })
              ],
            ),
            Container(
                child: Button(
              child: Text("Tambah Purchase Order"),
              onPressed: (() async {
                await showAddMaterialPurchaseModal(context);
                setState(() {
                  materialPurchaseFuture = getMaterialPurchases();
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
            future: materialPurchaseFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                if (materialPurchases!.isEmpty || materialPurchases == null) {
                  child = const Center(
                    heightFactor: 10,
                    child: Text("Tidak Ada Data Pembelian"),
                  );
                } else {
                  child = FlutterMaterial.PaginatedDataTable(
                    columnSpacing: 80,
                    horizontalMargin: 30,
                    columns: const [
                      FlutterMaterial.DataColumn(label: Text('Kode pembelian')),
                      FlutterMaterial.DataColumn(label: Text('Pemasok')),
                      FlutterMaterial.DataColumn(label: Text('Barang')),
                      FlutterMaterial.DataColumn(
                          label: Text('Kuantiti pembelian')),
                      FlutterMaterial.DataColumn(
                          label: Text('Tanggal pembelian')),
                      FlutterMaterial.DataColumn(label: Text('Jumlah PPN')),
                      FlutterMaterial.DataColumn(label: Text('Nomor Faktur')),
                      FlutterMaterial.DataColumn(label: Text('Aksi')),
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
                    await PdfMaterialPurchaseReportApi.generate(
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
      materialPurchases?.length ?? 500,
      (index) => {
            "id": materialPurchases?[index].materialPurchaseId,
            "materialPurchaseCode":
                materialPurchases?[index].materialPurchaseCode,
            "supplier": materialPurchases?[index].supplier?.supplierName,
            "materialPurchaseDate":
                materialPurchases?[index].materialPurchaseDate,
            "taxInvoiceNumber":
                materialPurchases?[index].taxInvoiceNumber ?? "",
            "taxAmount": materialPurchases?[index].taxAmount ?? "",
            "taxInvoiceImg": materialPurchases?[index].taxInvoiceImg ?? "",
          });

  @override
  FlutterMaterial.DataRow? getRow(int index) {
    return FlutterMaterial.DataRow(
      cells: [
        FlutterMaterial.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data[index]['materialPurchaseCode'].toString()),
        )),
        FlutterMaterial.DataCell(
          Padding(
            padding: const EdgeInsets.only(right: 80),
            child: Text(_data[index]['supplier'].toString()),
            // child: FutureBuilder(
            //   future: getMaterialPurchasesDetail(
            //       materialPurchaseCode: _data[index]['materialPurchaseCode']),
            //   builder: (BuildContext context, AsyncSnapshot snapshot) {
            //     Widget child;
            //     if (snapshot.connectionState == ConnectionState.done) {
            //       List<MaterialPurchase> _materialPurchases = snapshot.data;

            //       child = SingleChildScrollView(
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             for (MaterialPurchase materialPurchase
            //                 in _materialPurchases)
            //               Text("- ${materialPurchase.supplier?.supplierName}")
            //           ],
            //         ),
            //       );
            //     } else {
            //       child = Container();
            //     }
            //     return child;
            //   },
            // )
          ),
        ),
        FlutterMaterial.DataCell(
          Padding(
              padding: const EdgeInsets.only(right: 80),
              child: FutureBuilder(
                future: getMaterialPurchasesDetail(
                    materialPurchaseCode: _data[index]['materialPurchaseCode']),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  Widget child;
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<MaterialPurchase> _materialPurchases = snapshot.data;

                    child = SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (MaterialPurchase materialPurchase
                              in _materialPurchases)
                            Text(
                                "- ${materialPurchase.material?.materialName ?? materialPurchase.product?.productName ?? materialPurchase.fabricatingMaterial?.fabricatingMaterialName}")
                        ],
                      ),
                    );
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
                future: getMaterialPurchasesDetail(
                    materialPurchaseCode: _data[index]['materialPurchaseCode']),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  Widget child;
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<MaterialPurchase> _materialPurchases = snapshot.data;

                    child = SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (MaterialPurchase materialPurchase
                              in _materialPurchases)
                            Text(
                                "- ${materialPurchase.materialPurchaseQty!} (${materialPurchase.material?.materialUnit ?? materialPurchase.fabricatingMaterial?.fabricatingMaterialUnit ?? "Pcs"})")
                        ],
                      ),
                    );
                  } else {
                    child = Container();
                  }
                  return child;
                },
              )),
        ),
        FlutterMaterial.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(dateFormatter(_data[index]['materialPurchaseDate'])),
        )),
        FlutterMaterial.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data[index]['taxAmount']),
        )),
        FlutterMaterial.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: TextButton(
            child: Text(_data[index]['taxInvoiceNumber']),
            onPressed: _data[index]['taxInvoiceImg'] == ""
                ? null
                : () {
                    openFullScreenImageModal(
                        context, _data[index]['taxInvoiceImg']);
                  },
          ),
        )),
        FlutterMaterial.DataCell(FlutterMaterial.Row(
          children: [
            IconButton(
                onPressed: () {
                  MaterialPurchasePage.globalKey.currentState!
                      .showRemovePurchaseModal(
                          _data[index]['materialPurchaseCode']);
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

  void openFullScreenImageModal(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      FlutterMaterial.MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenImageModal(imagePath: imagePath),
      ),
    );
  }
}

class FullScreenImageModal extends StatelessWidget {
  final String imagePath;

  const FullScreenImageModal({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return FlutterMaterial.Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: Center(
              child: Image.network("${dotenv.env['BASE_URL']}/${imagePath}"),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FlutterMaterial.IconButton(
              icon: Icon(FlutterMaterial.Icons.close),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
