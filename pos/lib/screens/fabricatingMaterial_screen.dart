import 'dart:math';

import 'package:example/models/material.dart';
import 'package:example/services/fabricatingMaterial.dart';
import 'package:example/widgets/bahanbaku/edit_fabricatingMaterial_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as FlutterMaterial;
import 'package:url_launcher/link.dart';

import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_fabMaterial_report_api.dart';

import '../models/fabricatingMaterial.dart';
import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../services/material.dart';

import '../widgets/bahanbaku/add_fabricatingMaterial_modal_content.dart';

List<FabricatingMaterial>? backupFabricatingMaterials;
List<FabricatingMaterial>? fabricatingMaterials;
List<FabricatingMaterial>? searchedFabricatingMaterial;

class FabricatingMaterialPage extends StatefulWidget {
  static final GlobalKey<_FabricatingMaterialPageState> globalKey = GlobalKey();
  FabricatingMaterialPage({Key? key}) : super(key: globalKey);

  @override
  State<FabricatingMaterialPage> createState() =>
      _FabricatingMaterialPageState();
}

class _FabricatingMaterialPageState extends State<FabricatingMaterialPage>
    with PageMixin {
  bool selected = true;
  String? comboboxValue;

  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();
  String? message;
  String? status;
  late FlutterMaterial.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  removedMaterial({required int fabricatingMaterialId}) async {
    var response = await _fabricatingMaterialService.removeFabricatingMaterial(
        fabricatingMaterialId: fabricatingMaterialId);
    var message = response.message;
    print(message);
  }

  showRemoveMaterialModal(int fabricatingMaterialId) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Barang Setengah Jadi'),
        content:
            Text("Apakah anda yakin akan menghapus Barang Setengah Jadi ini?"),
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
                await removedMaterial(
                    fabricatingMaterialId: fabricatingMaterialId);
                setState(() {
                  fabricatingMaterialFuture = getFabricatingMaterials();
                });
                Navigator.pop(context, 'User deleted file');
              }),
        ],
      ),
    );
  }

  showAddBahanBakuModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Bahan Setengah Jadi'),
        content: AddFabricatingMaterialModalContent(),
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
                  AddFabricatingMaterialModalContent.globalKey.currentState!
                      .postBarangSetengahJadi();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  showEditMaterialModal(
      {required int fabricatingMaterialId,
      required String fabricatingMaterialCode,
      required String fabricatingMaterialName,
      required String fabricatingMaterialUnit,
      required String fabricatingMaterialMinimumStock,
      required String fabricatingMaterialQty,
      required int? colorId,
      required String fabricatingMaterialPrice}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Ubah Bahan Setengah Jadi'),
        content: EditFabricatingMaterialModalContent(
          fabricatingMaterialId: fabricatingMaterialId,
          fabricatingMaterialCode: fabricatingMaterialCode,
          fabricatingMaterialName: fabricatingMaterialName,
          colorId: colorId,
          fabricatingMaterialUnit: fabricatingMaterialUnit,
          fabricatingMaterialMinimumStock: fabricatingMaterialMinimumStock,
          fabricatingMaterialQty: fabricatingMaterialQty,
          fabricatingMaterialPrice: fabricatingMaterialPrice,
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
              onPressed: () async {
                await EditFabricatingMaterialModalContent
                    .globalKey.currentState!
                    .updateMaterial();
                setState(() {
                  fabricatingMaterialFuture = getFabricatingMaterials();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  late Future fabricatingMaterialFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = [
    "Kode Barang Setengah Jadi",
    "Nama Barang Setengah Jadi",
    "Warna",
    "Satuan Unit",
    "Stock"
  ];

  getFabricatingMaterials() async {
    var response = await _fabricatingMaterialService.getFabricatingMaterials();
    fabricatingMaterials = response.data;
    backupFabricatingMaterials = fabricatingMaterials;
    print("Get to View Barang Setengah Jadi: ${fabricatingMaterials}");
    fabricatingMaterials?.forEach((element) {
      print(element.fabricatingMaterialName);
    });
    _data = DataTable();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fabricatingMaterialFuture = getFabricatingMaterials();
    setState(() {});
  }

  String val = "";

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Bahan Setengah Jadi'),
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
                            fabricatingMaterialFuture =
                                getFabricatingMaterials();
                          });
                          print("---Searched---");

                          fabricatingMaterials!.forEach((element) {
                            print(element.fabricatingMaterialName);
                          });
                        } else {
                          if (selectedFilter == "Kode Barang Setengah Jadi") {
                            setState(() {
                              fabricatingMaterials = backupFabricatingMaterials;
                              fabricatingMaterials = fabricatingMaterials!
                                  .where((fabMat) => fabMat
                                      .fabricatingMaterialCode!
                                      .contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched---");

                              fabricatingMaterials!.forEach((element) {
                                print(element.fabricatingMaterialCode);
                              });
                            });
                          } else if (selectedFilter ==
                              "Nama Barang Setengah Jadi") {
                            setState(() {
                              fabricatingMaterials = backupFabricatingMaterials;
                              fabricatingMaterials = fabricatingMaterials!
                                  .where((fabMat) => fabMat
                                      .fabricatingMaterialName!
                                      .contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched---");
                              fabricatingMaterials!.forEach((element) {
                                print(element.fabricatingMaterialCode);
                              });
                            });
                          } else if (selectedFilter == "Warna") {
                            setState(() {
                              fabricatingMaterials = backupFabricatingMaterials;
                              fabricatingMaterials =
                                  fabricatingMaterials!.where((fabMat) {
                                if (fabMat.color != null) {
                                  return fabMat.color!.colorName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return fabMat.fabricatingMaterialCode!
                                    .contains(value);
                              }).toList();
                              _data = DataTable();
                              print("---Searched---");
                              fabricatingMaterials!.forEach((element) {
                                print(element.color!.colorName);
                              });
                            });
                          } else if (selectedFilter == "Satuan Unit") {
                            setState(() {
                              fabricatingMaterials = backupFabricatingMaterials;
                              fabricatingMaterials = fabricatingMaterials!
                                  .where((fabMat) => fabMat
                                      .fabricatingMaterialUnit!
                                      .contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched---");

                              fabricatingMaterials!.forEach((element) {
                                print(element.fabricatingMaterialUnit);
                              });
                            });
                          } else if (selectedFilter == "Stock") {
                            setState(() {
                              fabricatingMaterials = backupFabricatingMaterials;
                              fabricatingMaterials = fabricatingMaterials!
                                  .where((fabMat) => fabMat
                                      .fabricatingMaterialQty!
                                      .contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched---");

                              fabricatingMaterials!.forEach((element) {
                                print(element.fabricatingMaterialQty);
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
              ],
            ),
            Container(
                child: Button(
              child: const Text("Tambah Bahan Setengah Jadi"),
              onPressed: (() async {
                await showAddBahanBakuModal(context);
                setState(() {
                  fabricatingMaterialFuture = getFabricatingMaterials();
                });
              }),
              style: ButtonStyle(
                  padding: ButtonState.all(const EdgeInsets.only(
                      top: 10, bottom: 10, right: 15, left: 15))),
            ))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: fabricatingMaterialFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = FlutterMaterial.PaginatedDataTable(
                  columns: const [
                    FlutterMaterial.DataColumn(
                        label: Text('Kode Barang Setengah Jadi')),
                    FlutterMaterial.DataColumn(
                        label: Text('Nama Barang Setengah Jadi')),
                    FlutterMaterial.DataColumn(
                        label: Text('Warna Barang Setengah Jadi')),
                    FlutterMaterial.DataColumn(label: Text('Satuan Unit')),
                    FlutterMaterial.DataColumn(label: Text('Stock')),
                    FlutterMaterial.DataColumn(label: Text('Stock Minimum')),
                    FlutterMaterial.DataColumn(label: Text('Aksi'))
                  ],
                  source: () {
                    return _data;
                  }(),
                  columnSpacing: 80,
                  horizontalMargin: 30,
                  rowsPerPage: 12,
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
              final laporanPdfFile =
                  await PdfFabricatingMaterialReportApi.generate(
                      filter: selectedFilter, value: val);
              await FileHandleApi.openFile(laporanPdfFile);
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
  final List<Map<String, dynamic>> _data = List.generate(
      fabricatingMaterials?.length ?? 500,
      (index) => {
            "id": fabricatingMaterials?[index].fabricatingMaterialId,
            "fabricatingMaterialCode":
                fabricatingMaterials?[index].fabricatingMaterialCode,
            "fabricatingMaterialName":
                fabricatingMaterials?[index].fabricatingMaterialName,
            "fabricatingMaterialQty":
                fabricatingMaterials?[index].fabricatingMaterialQty,
            "fabricatingMaterialMinimumStock":
                fabricatingMaterials?[index].fabricatingMaterialMinimumStock,
            "fabricatingMaterialUnit":
                fabricatingMaterials?[index].fabricatingMaterialUnit,
            "fabricatingMaterialPrice":
                fabricatingMaterials?[index].fabricatingMaterialPrice,
            "color": fabricatingMaterials?[index].color?.colorName ?? "-",
            "colorId": fabricatingMaterials?[index].color?.colorId,
          });

  @override
  FlutterMaterial.DataRow? getRow(int index) {
    return FlutterMaterial.DataRow(cells: [
      FlutterMaterial.DataCell(
          Text(_data[index]['fabricatingMaterialCode'].toString())),
      FlutterMaterial.DataCell(
          Text(_data[index]['fabricatingMaterialName'].toString())),
      FlutterMaterial.DataCell(Text(_data[index]['color'].toString())),
      FlutterMaterial.DataCell(
          Text(_data[index]['fabricatingMaterialUnit'].toString())),
      FlutterMaterial.DataCell(
          Text(_data[index]['fabricatingMaterialQty'].toString())),
      FlutterMaterial.DataCell(
          Text(_data[index]['fabricatingMaterialMinimumStock'].toString())),
      FlutterMaterial.DataCell(FlutterMaterial.Row(
        children: [
          IconButton(
              onPressed: () {
                FabricatingMaterialPage.globalKey.currentState!
                    .showEditMaterialModal(
                  fabricatingMaterialId: _data[index]['id'],
                  fabricatingMaterialCode: _data[index]
                      ['fabricatingMaterialCode'],
                  fabricatingMaterialName: _data[index]
                      ['fabricatingMaterialName'],
                  colorId: _data[index]['colorId'],
                  fabricatingMaterialUnit: _data[index]
                      ['fabricatingMaterialUnit'],
                  fabricatingMaterialQty: _data[index]
                      ['fabricatingMaterialQty'],
                  fabricatingMaterialMinimumStock: _data[index]
                      ['fabricatingMaterialMinimumStock'],
                  fabricatingMaterialPrice: _data[index]
                      ['fabricatingMaterialPrice'],
                );
              },
              icon: const Icon(FluentIcons.edit, size: 24.0)),
          IconButton(
              onPressed: () {
                FabricatingMaterialPage.globalKey.currentState!
                    .showRemoveMaterialModal(_data[index]['id']);
              },
              icon: const Icon(FluentIcons.delete, size: 24.0))
        ],
      ))
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
