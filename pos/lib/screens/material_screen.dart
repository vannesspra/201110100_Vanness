import 'dart:math';

import 'package:example/models/material.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_material_report_api.dart';
import 'package:example/widgets/bahanbaku/edit_material_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as FlutterMaterial;
import 'package:url_launcher/link.dart';

import '../models/material.dart';
import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../services/material.dart';

import '../widgets/bahanbaku/add_material_modal_content.dart';

List<Material>? backupMaterials;
List<Material>? materials;
List<Material>? searchedMaterial;

class BahanBakuPage extends StatefulWidget {
  static final GlobalKey<_BahanBakuPageState> globalKey = GlobalKey();
  BahanBakuPage({Key? key}) : super(key: globalKey);

  @override
  State<BahanBakuPage> createState() => _BahanBakuPageState();
}

class _BahanBakuPageState extends State<BahanBakuPage> with PageMixin {
  bool selected = true;
  String? comboboxValue;
  MaterialService _materialService = MaterialService();
  String? message;
  String? status;
  late FlutterMaterial.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  removedMaterial({required int materialId}) async {
    var response =
        await _materialService.removeMaterial(materialId: materialId);
    var message = response.message;
    print(message);
  }

  showRemoveMaterialModal(int materialId) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Bahan Baku'),
        content: Text("Apakah anda yakin akan menghapus Bahan Baku ini?"),
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
                await removedMaterial(materialId: materialId);
                setState(() {
                  materialFuture = getMaterials();
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
        title: const Text('Tambah Bahan Baku'),
        content: AddBahanBakuModalContent(),
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
                  AddBahanBakuModalContent.globalKey.currentState!
                      .postBahanBaku();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  showEditMaterialModal(
      {required int materialId,
      required String materialCode,
      required String materialName,
      required String materialUnit,
      required String materialMinimumStock,
      required String materialQty,
      required int? colorId,
      required String materialPrice}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Ubah Bahan Baku'),
        content: EditBahanBakuModalContent(
          materialId: materialId,
          materialCode: materialCode,
          materialName: materialName,
          colorId: colorId,
          materialUnit: materialUnit,
          materialMinimumStock: materialMinimumStock,
          materialQty: materialQty,
          materialPrice: materialPrice,
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
                await EditBahanBakuModalContent.globalKey.currentState!
                    .updateMaterial();
                setState(() {
                  materialFuture = getMaterials();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  late Future materialFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = [
    "Kode Bahan Baku",
    "Nama Bahan Baku",
    "Warna Bahan Baku",
    "Satuan Unit",
    "Stok"
  ];

  getMaterials() async {
    var response = await _materialService.getMaterials();
    materials = response.data;
    backupMaterials = materials;
    print("Get to View Bahan Baku: ${materials}");
    materials?.forEach((element) {
      print(element.materialName);
    });
    _data = DataTable();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    materialFuture = getMaterials();
    setState(() {});
  }

  String val = "";

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Bahan Baku'),
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
                            materialFuture = getMaterials();
                          });
                          print("---Searched Product---");
                          materials!.forEach((element) {
                            print(element.materialName);
                          });
                        } else {
                          if (selectedFilter == "Kode Bahan Baku") {
                            setState(() {
                              materials = backupMaterials;
                              materials = materials!
                                  .where((material) =>
                                      material.materialCode!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              materials!.forEach((element) {
                                print(element.materialCode);
                              });
                            });
                          } else if (selectedFilter == "Nama Bahan Baku") {
                            setState(() {
                              materials = backupMaterials;
                              materials = materials!
                                  .where((material) =>
                                      material.materialName!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              materials!.forEach((element) {
                                print(element.materialName);
                              });
                            });
                          } else if (selectedFilter == "Warna Bahan Baku") {
                            setState(() {
                              materials = backupMaterials;
                              materials = materials!.where((material) {
                                if (material.color != null) {
                                  return material.color!.colorName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return material.materialName!
                                    .toLowerCase()
                                    .contains(value.toLowerCase());
                              }).toList();

                              print(materials);
                              _data = DataTable();
                              print("---Searched Product---");
                              materials!.forEach((element) {
                                if (element.color != null &&
                                    element.color!.colorName!
                                        .toLowerCase()
                                        .contains(value.toLowerCase())) {
                                  print("+++++" + element.color!.colorName!);
                                }
                              });
                            });
                          } else if (selectedFilter == "Satuan Unit") {
                            setState(() {
                              materials = backupMaterials;
                              materials = materials!
                                  .where((material) =>
                                      material.materialUnit!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              materials!.forEach((element) {
                                print(element.materialUnit);
                              });
                            });
                          } else if (selectedFilter == "Stok") {
                            setState(() {
                              materials = backupMaterials;
                              materials = materials!
                                  .where((material) =>
                                      material.materialQty!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              materials!.forEach((element) {
                                print(element.materialQty);
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
              child: const Text("Tambah Bahan Baku"),
              onPressed: (() async {
                await showAddBahanBakuModal(context);
                setState(() {
                  materialFuture = getMaterials();
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
          future: materialFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget child;
            if (snapshot.connectionState == ConnectionState.done) {
              child = FlutterMaterial.PaginatedDataTable(
                columns: const [
                  FlutterMaterial.DataColumn(label: Text('Kode Bahan Baku')),
                  FlutterMaterial.DataColumn(label: Text('Nama Bahan Baku')),
                  FlutterMaterial.DataColumn(label: Text('Warna Bahan Baku')),
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
          },
        ),
        Container(
          child: Button(
            child: const Text("Laporan"),
            onPressed: () async {
              final laporanPdfFile = await PdfMaterialReportApi.generate(
                  filter: selectedFilter, value: val);
              await FileHandleApi.openFile(laporanPdfFile);
              // Navigator.pop(context);
            },
            style: ButtonStyle(
                padding: ButtonState.all(const EdgeInsets.only(
                    top: 10, bottom: 10, right: 15, left: 15))),
          ),
        ),
      ],
    );
  }
}

class DataTable extends FlutterMaterial.DataTableSource {
  final List<Map<String, dynamic>> _data = List.generate(
      materials?.length ?? 500,
      (index) => {
            "id": materials?[index].materialId,
            "materialCode": materials?[index].materialCode,
            "materialName": materials?[index].materialName,
            "materialQty": materials?[index].materialQty,
            "materialMinimumStock": materials?[index].materialMinimumStock,
            "materialUnit": materials?[index].materialUnit,
            "materialPrice": materials?[index].materialPrice,
            "color": materials?[index].color?.colorName ?? "-",
            "colorId": materials?[index].color?.colorId,
          });

  @override
  FlutterMaterial.DataRow? getRow(int index) {
    return FlutterMaterial.DataRow(cells: [
      FlutterMaterial.DataCell(Text(_data[index]['materialCode'].toString())),
      FlutterMaterial.DataCell(Text(_data[index]['materialName'].toString())),
      FlutterMaterial.DataCell(Text(_data[index]['color'].toString())),
      FlutterMaterial.DataCell(Text(_data[index]['materialUnit'].toString())),
      FlutterMaterial.DataCell(Text(_data[index]['materialQty'].toString())),
      FlutterMaterial.DataCell(
          Text(_data[index]['materialMinimumStock'].toString())),
      FlutterMaterial.DataCell(FlutterMaterial.Row(
        children: [
          IconButton(
              onPressed: () {
                BahanBakuPage.globalKey.currentState!.showEditMaterialModal(
                  materialId: _data[index]['id'],
                  materialCode: _data[index]['materialCode'],
                  materialName: _data[index]['materialName'],
                  colorId: _data[index]['colorId'],
                  materialUnit: _data[index]['materialUnit'],
                  materialQty: _data[index]['materialQty'],
                  materialMinimumStock: _data[index]['materialMinimumStock'],
                  materialPrice: _data[index]['materialPrice'],
                );
              },
              icon: const Icon(FluentIcons.edit, size: 24.0)),
          IconButton(
              onPressed: () {
                BahanBakuPage.globalKey.currentState!
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
