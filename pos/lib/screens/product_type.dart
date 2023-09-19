import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:example/models/product_type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:url_launcher/link.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../services/type.dart';

import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_type_report_api.dart';

import '../widgets/product/add_type_product_modal_content.dart';
import '../widgets/product/edit_type_product_modal_content.dart';

List<ProductType>? backupTypes;
List<ProductType>? types;
List<ProductType>? searchedTypes;

class TypePage extends StatefulWidget {
  static final GlobalKey<_TypePageState> globalKey = GlobalKey();
  TypePage({Key? key}) : super(key: globalKey);

  @override
  State<TypePage> createState() => _TypePageState();
}

class _TypePageState extends State<TypePage> with PageMixin {
  bool selected = true;
  String? comboboxValue;
  TypeService _typeService = TypeService();
  String? message;
  String? status;
  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  removedType({required int typeId}) async {
    var response = await _typeService.removeType(typeId: typeId);
    var message = response.message;
    print(message);
  }

  showRemoveTypeModal(int typeId) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text("Hapus tipe data produk"),
        content: Text("Apakah anda yakin akan menghapus tipe ini?"),
        actions: [
          Button(
            child: const Text("Tidak"),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
            },
          ),
          FilledButton(
              child: const Text("Ya"),
              onPressed: () async {
                await removedType(typeId: typeId);
                setState(() {
                  typesFuture = getTypes();
                });
                Navigator.pop(context, 'User deleted file');
              })
        ],
      ),
    );
  }

  showAddTypeModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Jenis Produk'),
        content: AddTypeModalContent(),
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
                  AddTypeModalContent.globalKey.currentState!.postType();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  showEditTypeModal({
    required int typeId,
    required String typeCode,
    required String typeName,
    required String typeDesc,
  }) async {
    final result = await showDialog<String>(
        context: context,
        builder: (context) => ContentDialog(
              constraints: const BoxConstraints(maxWidth: 500),
              title: const Text("Ubah Jenis Produk"),
              content: EditTypeModalContent(
                typeId: typeId,
                typeCode: typeCode,
                typeName: typeName,
                typeDesc: typeDesc,
              ),
              actions: [
                Button(
                  child: const Text("Batal"),
                  onPressed: () {
                    Navigator.pop(context, 'User deleted file');
                  },
                ),
                FilledButton(
                    child: const Text("Ubah"),
                    onPressed: () async {
                      await EditTypeModalContent.globalKey.currentState!
                          .updateType();
                      setState(() {
                        typesFuture = getTypes();
                      });
                    }),
              ],
            ));
    setState(() {});
  }

  late Future typesFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Kode Tipe", "Tipe"];

  getTypes() async {
    var response = await _typeService.getTypes();
    types = response.data;
    backupTypes = types;
    print("Get to View Type: ${types}");
    _data = DataTable();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    typesFuture = getTypes();
    setState(() {});
  }

  String val = "";

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Jenis Produk'),
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
                            typesFuture = getTypes();
                          });
                          print("---Searched Types---");
                          types!.forEach((element) {
                            print(element.typeName);
                          });
                        } else {
                          if (selectedFilter == "Kode Tipe") {
                            setState(() {
                              types = backupTypes;
                              types = types!
                                  .where((types) =>
                                      types.typeCode!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Color---");
                              types!.forEach((element) {
                                print(element.typeCode);
                              });
                            });
                          } else if (selectedFilter == "Tipe") {
                            setState(() {
                              types = backupTypes;
                              types = types!
                                  .where((types) =>
                                      types.typeName!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Color---");
                              types!.forEach((element) {
                                print(element.typeName);
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
              child: const Text("Tambah Jenis Produk"),
              onPressed: (() async {
                await showAddTypeModal(context);
                typesFuture = getTypes();
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
            future: typesFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    Material.DataColumn(label: Text('Kode Tipe')),
                    Material.DataColumn(label: Text('Tipe Produk')),
                    Material.DataColumn(label: Text('Deskripsi')),
                    Material.DataColumn(label: Text('Aksi'))
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
              final laporanPdfFile = await PdfTypeReportApi.generate(
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

class DataTable extends Material.DataTableSource {
  final List<Map<String, dynamic>> _data = List.generate(
      types?.length ?? 500,
      (index) => {
            "id": types?[index].typeId,
            "typeCode": types?[index].typeCode,
            "typeName": types?[index].typeName,
            "typeDesc": types?[index].typeDesc ?? "-",
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(Text(_data[index]['typeCode'].toString())),
      Material.DataCell(Text(_data[index]['typeName'].toString())),
      Material.DataCell(Text(_data[index]['typeDesc'].toString())),
      Material.DataCell(Material.Row(
        children: [
          IconButton(
              onPressed: () {
                TypePage.globalKey.currentState!.showEditTypeModal(
                    typeId: _data[index]['id'],
                    typeCode: _data[index]['typeCode'],
                    typeName: _data[index]['typeName'],
                    typeDesc: _data[index]['typeDesc']);
              },
              icon: const Icon(FluentIcons.edit, size: 24.0)),
          IconButton(
              onPressed: () {
                TypePage.globalKey.currentState!
                    .showRemoveTypeModal(_data[index]['id']);
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
