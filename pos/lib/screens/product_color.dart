import 'dart:math';

import 'package:example/models/product_color.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:url_launcher/link.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../services/color.dart';
import '../models/color.dart';

import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_color_report_api.dart';

import '../widgets/product/add_color_product_modal_content.dart';
import '../widgets/product/edit_color_product_modal_content.dart';

List<Color>? backupColors;
List<Color>? colors;
List<Color>? searchedColors;

class ColorPage extends StatefulWidget {
  static final GlobalKey<_ColorPageState> globalKey = GlobalKey();
  ColorPage({Key? key}) : super(key: globalKey);

  @override
  State<ColorPage> createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> with PageMixin {
  bool selected = true;
  String? comboboxValue;
  ColorService _colorService = ColorService();
  String? message;
  String? status;
  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  removedColor({required int colorId}) async {
    var response = await _colorService.removeColor(colorId: colorId);
    var message = response.message;
    print(message);
  }

  showRemoveColorModal(int colorId) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text("Hapus warna data produk"),
        content: Text("Apakah anda yakin akan menghapus warna ini?"),
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
                await removedColor(colorId: colorId);
                setState(() {
                  colorsFuture = getColors();
                });
                Navigator.pop(context, 'User deleted file');
              })
        ],
      ),
    );
  }

  showAddColorModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Warna'),
        content: AddColorModalContent(),
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
                  AddColorModalContent.globalKey.currentState!.postColor();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  showEditColorModal({
    required int colorId,
    required String colorCode,
    required String colorName,
    required String colorDesc,
  }) async {
    final result = await showDialog<String>(
        context: context,
        builder: (context) => ContentDialog(
              constraints: const BoxConstraints(maxWidth: 500),
              title: const Text("Ubah Warna"),
              content: EditColorModalContent(
                colorId: colorId,
                colorCode: colorCode,
                colorName: colorName,
                colorDesc: colorDesc,
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
                      await EditColorModalContent.globalKey.currentState!
                          .updateColor();
                      setState(() {
                        colorsFuture = getColors();
                      });
                    }),
              ],
            ));
    setState(() {});
  }

  late Future colorsFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Kode Warna", "Warna"];

  getColors() async {
    var response = await _colorService.getColors();
    colors = response.data;
    backupColors = colors;
    print("Get to View Color: ${colors}");
    _data = DataTable();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    colorsFuture = getColors();
    setState(() {});
  }

  String val = "";

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Warna'),
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
                            colorsFuture = getColors();
                          });
                          print("---Searched Color---");
                          colors!.forEach((element) {
                            print(element.colorName);
                          });
                        } else {
                          if (selectedFilter == "Kode Warna") {
                            setState(() {
                              colors = backupColors;
                              colors = colors!
                                  .where((color) =>
                                      color.colorCode!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Color---");
                              colors!.forEach((element) {
                                print(element.colorCode);
                              });
                            });
                          } else if (selectedFilter == "Warna") {
                            setState(() {
                              setState(() {
                                colors = backupColors;
                                colors = colors!
                                    .where((color) =>
                                        color.colorName!.contains(value))
                                    .toList();
                                _data = DataTable();
                                print("---Searched Color---");
                                colors!.forEach((element) {
                                  print(element.colorName);
                                });
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
              child: const Text("Tambah Warna"),
              onPressed: (() async {
                await showAddColorModal(context);
                colorsFuture = getColors();
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
            future: colorsFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    Material.DataColumn(label: Text('Kode Warna')),
                    Material.DataColumn(label: Text('Warna Produk')),
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
              final laporanPdfFile = await PdfColorReportApi.generate(
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
      colors?.length ?? 500,
      (index) => {
            "id": colors?[index].colorId,
            "colorCode": colors?[index].colorCode,
            "colorName": colors?[index].colorName,
            "colorDesc": colors?[index].colorDesc ?? "-",
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(Text(_data[index]['colorCode'].toString())),
      Material.DataCell(Text(_data[index]['colorName'].toString())),
      Material.DataCell(Text(_data[index]['colorDesc'].toString())),
      Material.DataCell(Material.Row(
        children: [
          IconButton(
              onPressed: () {
                ColorPage.globalKey.currentState!.showEditColorModal(
                    colorId: _data[index]['id'],
                    colorCode: _data[index]['colorCode'],
                    colorName: _data[index]['colorName'],
                    colorDesc: _data[index]['colorDesc']);
              },
              icon: const Icon(FluentIcons.edit, size: 24.0)),
          IconButton(
              onPressed: () {
                ColorPage.globalKey.currentState!
                    .showRemoveColorModal(_data[index]['id']);
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
