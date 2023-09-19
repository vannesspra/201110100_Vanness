import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_product_report_api.dart';
import 'package:example/widgets/product/edit_product_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:url_launcher/link.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../services/product.dart';
import '../models/product.dart';

import '../widgets/product/add_product_modal_content.dart';

List<Product>? backupProducts;
List<Product>? products;
List<Product>? searchedProducts;

class ProductPage extends StatefulWidget {
  static final GlobalKey<_ProductPageState> globalKey = GlobalKey();
  ProductPage({Key? key}) : super(key: globalKey);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> with PageMixin {
  ProductService _productService = ProductService();
  late Material.DataTableSource _data;
  late Future productsFuture;
  bool selected = true;
  String? comboboxValue;

  String? message;
  String? status;

  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  removedProuct({required int productId, required BuildContext context}) async {
    var response = await _productService.removeProduct(productId: productId);
    var message = response.message;
    print(message);
  }

  getProucts() async {
    var response = await _productService.getProduct();
    products = response.data;
    backupProducts = products;
    print("Get to View Product: ${products}");
    products?.forEach((element) {
      // element.productColors?.forEach((element) {
      //   print(element.color!.colorName);
      // });
      print(element.color);
      print(element.type);
    });
    _data = DataTable();
  }

  showRemoveProductModal(int productId) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Produk'),
        content: Text("Apakah anda yakin akan menghapus produk ini?"),
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
                await removedProuct(productId: productId, context: context);
                setState(() {
                  productsFuture = getProucts();
                });
                Navigator.pop(context, 'User deleted file');
              }),
        ],
      ),
    );
  }

  showAddProductModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Item Produk'),
        content: AddProductModalContent(),
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
                  AddProductModalContent.globalKey.currentState!.postProduct();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  showEditProductModal({
    required int productId,
    required String productCode,
    required String productName,
    required String productPrice,
    required String productDesc,
    required String productMinimumStock,
    required String productQty,
    // required List<Color>? colors,
    required int? colorId,
    required int? typeId,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Ubah Produk'),
        content: EditProductModalContent(
          productId: productId,
          productCode: productCode,
          productName: productName,
          productDesc: productDesc,
          productMinimumStock: productMinimumStock,
          productPrice: productPrice,
          productQty: productQty,
          // colors: colors,
          colorId: colorId,
          typeId: typeId,
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
                await EditProductModalContent.globalKey.currentState!
                    .updateProduct();
                setState(() {
                  productsFuture = getProucts();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  String selectedFilter = "Cari Berdasarkan";
  List filterList = [
    "Kode Produk",
    "Nama Produk",
    "Jenis Produk",
    "Warna Produk",
    "Harga Produk",
    "Stok"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productsFuture = getProucts();
    setState(() {});
  }

  String val = "";

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Produk'),
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
                        print("======================" + value);
                        setState(() {
                          val = value;
                        });
                        if (value == "") {
                          print("Value Kosong");
                          setState(() {
                            productsFuture = getProucts();
                          });
                          print("---Searched Product---");
                          products!.forEach((element) {
                            print(element.productName);
                          });
                        } else {
                          if (selectedFilter == "Kode Produk") {
                            setState(() {
                              products = backupProducts;
                              products = products!
                                  .where((product) =>
                                      product.productCode!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              products!.forEach((element) {
                                print(element.productName);
                              });
                            });
                          } else if (selectedFilter == "Nama Produk") {
                            setState(() {
                              products = backupProducts;
                              products = products!
                                  .where((product) =>
                                      product.productName!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              products!.forEach((element) {
                                print(element.productName);
                              });
                            });
                          } else if (selectedFilter == "Jenis Produk") {
                            setState(() {
                              products = backupProducts;
                              products = products!
                                  .where((product) =>
                                      product.type!.typeName!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              products!.forEach((element) {
                                print(element.type!.typeName!);
                              });
                            });
                          } else if (selectedFilter == "Warna Produk") {
                            setState(() {
                              products = backupProducts;
                              products = products!
                                  .where((product) =>
                                      product.color!.colorName!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              products!.forEach((element) {
                                print(element.color!.colorName!);
                              });
                            });
                          } else if (selectedFilter == "Harga Produk") {
                            setState(() {
                              products = backupProducts;
                              products = products!
                                  .where((product) =>
                                      product.productPrice!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              products!.forEach((element) {
                                print(element.productPrice!);
                              });
                            });
                          } else if (selectedFilter == "Stok") {
                            setState(() {
                              products = backupProducts;
                              products = products!
                                  .where((product) =>
                                      product.productQty!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              products!.forEach((element) {
                                print(element.productQty!);
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
              child: const Text("Tambah Item Produk"),
              onPressed: (() async {
                await showAddProductModal(context);
                setState(() {
                  productsFuture = getProucts();
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
            future: productsFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    Material.DataColumn(label: Text('Kode Produk')),
                    Material.DataColumn(label: Text('Nama Produk')),
                    Material.DataColumn(label: Text('Tipe Produk')),
                    Material.DataColumn(label: Text('Warna Produk')),
                    Material.DataColumn(label: Text('Harga Produk')),
                    Material.DataColumn(label: Text('Stock')),
                    Material.DataColumn(label: Text('Stock Minimum')),
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
              final laporanPdfFile = await PdfProductReportApi.generate(
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

class DataTable extends Material.DataTableSource {
  List<Color> _colors = [];
  final List<Map<String, dynamic>> _data = List.generate(
      products?.length ?? 500,
      (index) => {
            "id": products?[index].productId,
            "productCode": products?[index].productCode,
            "productName": products?[index].productName,
            "type": products?[index].type?.typeName,
            "typeId": products?[index].type?.typeId,
            // "productColor": products?[index].productColors,
            "color": products?[index].color?.colorName,
            "colorId": products?[index].color?.colorId,
            "productPrice": products?[index].productPrice,
            "productQty": products?[index].productQty,
            "productMinimumStock": products?[index].productMinimumStock,
            "productDesc": products?[index].productDesc ?? " - ",
          });

  @override
  Material.DataRow? getRow(int index) {
    // String stringColors = "";
    // for (ProductColor productColor in _data[index]['productColor']) {
    //   if (stringColors.isEmpty) {
    //     stringColors = stringColors + "${productColor.color!.colorName!}";
    //   } else {
    //     stringColors = stringColors + ", ${productColor.color!.colorName!}";
    //   }
    // }
    // print(stringColors);
    return Material.DataRow(cells: [
      Material.DataCell(Text(_data[index]['productCode'].toString())),
      Material.DataCell(Text(_data[index]['productName'].toString())),
      Material.DataCell(Text(_data[index]['type'].toString())),
      Material.DataCell(Text(_data[index]['color'].toString())),
      Material.DataCell(Text(_data[index]['productPrice'].toString())),
      Material.DataCell(Text(_data[index]['productQty'].toString())),
      Material.DataCell(Text(_data[index]['productMinimumStock'].toString())),
      // Material.DataCell(Text(stringColors)),

      Material.DataCell(Text(_data[index]['productDesc'].toString())),
      Material.DataCell((StatefulBuilder(
        builder: (context, setState) {
          return Material.Row(
            children: [
              IconButton(
                  onPressed: () async {
                    // _colors = [];
                    // for (ProductColor productColor in _data[index]
                    //     ['productColor']) {
                    //   _colors.add(productColor.color!);
                    // }

                    ProductPage.globalKey.currentState!.showEditProductModal(
                        productId: _data[index]['id'],
                        productCode: _data[index]['productCode'],
                        productName: _data[index]['productName'],
                        productPrice: _data[index]['productPrice'],
                        productDesc: _data[index]['productDesc'],
                        productMinimumStock: _data[index]
                            ['productMinimumStock'],
                        productQty: _data[index]['productQty'],
                        // colors: _colors,
                        colorId: _data[index]['colorId'],
                        typeId: _data[index]['typeId']);
                  },
                  icon: const Icon(FluentIcons.edit, size: 24.0)),
              IconButton(
                  onPressed: () async {
                    await ProductPage.globalKey.currentState!
                        .showRemoveProductModal(_data[index]['id']);
                  },
                  icon: const Icon(FluentIcons.delete, size: 24.0))
            ],
          );
        },
      )))
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
