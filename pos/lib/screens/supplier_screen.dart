import 'package:example/models/material_spending.dart';
import 'package:example/models/supplier.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_supplier_report_api.dart';
import 'package:example/services/supplier.dart';
import 'package:example/widgets/supplier/add_supplier_modal_content.dart';
import 'package:example/widgets/supplier/edit_supplier_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import '../widgets/page.dart';

List<Supplier>? backupSuppliers;
List<Supplier>? suppliers;
List<Supplier>? searchedSuppliers;
List<Supplier> supplierPro = [];
List<Supplier>? supplierMat;
List<Supplier>? supplierFabMat;

class SupplierPage extends StatefulWidget {
  static final GlobalKey<_SupplierPageState> globalKey = GlobalKey();
  SupplierPage({Key? key}) : super(key: globalKey);

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> with PageMixin {
  SupplierServices _supplierService = SupplierServices();
  String? message;
  String? status;
  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  removedSupplier({required int supplierId}) async {
    var response =
        await _supplierService.removeSupplier(supplierId: supplierId);
    var message = response.message;
    print(message);
  }

  showRemoveSupplierModal(int supplierId) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Pemasok'),
        content: Text("Apakah anda yakin akan menghapus pemasok ini?"),
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
                await removedSupplier(supplierId: supplierId);
                setState(() {
                  suppliersFuture = getSuppliers();
                });
                Navigator.pop(context, 'User deleted file');
              }),
        ],
      ),
    );
  }

  showAddSupplierModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Daftar Supplier'),
        content: AddSupplierModalContent(),
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
                AddSupplierModalContent.globalKey.currentState!.postSupplier();
              }),
        ],
      ),
    );
    setState(() {});
  }

  showEditSupplierModal(
      {required int supplierId,
      required String supplierCode,
      required String supplierName,
      required String supplierAddress,
      required String supplierPhoneNumber,
      required String supplierEmail,
      required String supplierContactPerson,
      required String paymentType,
      required String paymentTerm,
      required String supplierTax,
      required List<Map<String, dynamic>> supplierProducts,
      required List<Map<String, dynamic>> supplierMaterials,
      required List<Map<String, dynamic>> supplierFabricatingMaterials}) async {
    print(supplierProducts);
    print(supplierMaterials);
    print(supplierFabricatingMaterials);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Ubah Daftar Supplier'),
        content: EditSupplierModalContent(
          supplierId: supplierId,
          supplierCode: supplierCode,
          supplierName: supplierName,
          supplierAddress: supplierAddress,
          supplierPhoneNumber: supplierPhoneNumber,
          supplierEmail: supplierEmail,
          supplierContactPerson: supplierContactPerson,
          paymentTerm: paymentTerm,
          paymentType: paymentType,
          supplierTax: supplierTax,
          supplierProducts: supplierProducts,
          supplierMaterials: supplierMaterials,
          supplierFabricatingMaterials: supplierFabricatingMaterials,
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
                await EditSupplierModalContent.globalKey.currentState!
                    .updateSupplier();
                setState(() {
                  suppliersFuture = getSuppliers();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  late Future suppliersFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = [
    "Kode Pemasok",
    "Nama Pemasok",
    "Alamat Pemasok",
    "No. Telp Pemasok",
    "Email Pemasok",
    "Kontak Person Pemasok",
    "Tax",
    "Cash"
  ];

  getSuppliers() async {
    var response = await _supplierService.getSupplier();
    suppliers = response.data;
    backupSuppliers = suppliers;
    print("Get to View Supplier: ${suppliers}");
    suppliers?.forEach((element) {
      // element.productColors?.forEach((element) {
      //   print(element.color!.colorName);
      // });
      print(element.supplierName);
    });
    _data = DataTable();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    suppliersFuture = getSuppliers();
  }

  String val = "";
  bool cond = false;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Daftar Supplier'),
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
                        print(value);
                        setState(() {
                          val = value;
                        });
                        if (value == "") {
                          print("Value Kosong");
                          setState(() {
                            suppliersFuture = getSuppliers();
                          });
                          print("---Searched Supplier---");
                          suppliers!.forEach((element) {
                            print(element.supplierName);
                          });
                        } else {
                          if (selectedFilter == "Kode Pemasok") {
                            setState(() {
                              suppliers = backupSuppliers;
                              suppliers = suppliers!
                                  .where((supplier) =>
                                      supplier.supplierCode!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Supplier---");
                              suppliers!.forEach((element) {
                                print(element.supplierName);
                              });
                            });
                          } else if (selectedFilter == "Nama Pemasok") {
                            setState(() {
                              suppliers = backupSuppliers;
                              suppliers = suppliers!
                                  .where((product) => product.supplierName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Supplier---");
                              suppliers!.forEach((element) {
                                print(element.supplierName);
                              });
                            });
                          } 
                          // else if (selectedFilter == "Item") {
                          //   setState(() {
                          //     suppliers = backupSuppliers;
                          //     for (int i = 0; i < suppliers!.length; i++){
                          //       if (suppliers![i].supplierProducts != null){
                          //         for (int j=0; j < suppliers![i].supplierProducts!.length; j++){
                          //           if(suppliers![i].supplierProducts![j].product != null && suppliers![i].supplierProducts![j].product!.productName!.contains(value)){
                          //             supplierPro.add(suppliers![i]);
                          //             // break;
                          //           }
                          //         }
                          //         // break;
                          //       }
                          //     }
                          //       // suppliers!.forEach((supplier) {
                          //       //   if (supplier.supplierProducts != null) {
                          //       //     supplier.supplierProducts!.forEach((type) {
                          //       //       if (type.product != null &&
                          //       //           type.product!.productName!
                          //       //               .contains(value)) {
                          //       //         // cond = true;
                          //       //         supplierPro.add(supplier);
                          //       //       }
                          //       //       // else if (type.material != null &&
                          //       //       //     type.material!.materialName!
                          //       //       //         .contains(value)) {
                          //       //       //   supplierPro.add(supplier);
                          //       //       // } else if (type.fabricatingMaterial !=
                          //       //       //         null &&
                          //       //       //     type.fabricatingMaterial!
                          //       //       //         .fabricatingMaterialName!
                          //       //       //         .contains(value)) {
                          //       //       //   supplierPro.add(supplier);
                          //       //       // }
                          //       //     });
                          //       //     // if (cond == true) {
                          //       //     //   supplierPro.add(supplier);
                          //       //     //   cond = false;
                          //       //     // }
                          //       //   }
                          //       // });
                          //     // suppliers = [];
                          //     print(supplierPro);
                          //     suppliers = supplierPro;
                          //     print(suppliers!.length);
                          //     _data = DataTable();
                          //     print("---Searched Supplier---");
                          //     // suppliers!.forEach((element) {
                          //     //   element.supplierProducts!.forEach((element) {
                          //     //     if (element.fabricatingMaterial != null) {
                          //     //       print(element.fabricatingMaterial!
                          //     //           .fabricatingMaterialName);
                          //     //     }
                          //     //   });
                          //     // });
                          //   });
                          // } 
                          else if (selectedFilter == "Alamat Pemasok") {
                            setState(() {
                              suppliers = backupSuppliers;
                              suppliers = suppliers!
                                  .where((product) => product.supplierAddress!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Supplier---");
                              suppliers!.forEach((element) {
                                print(element.supplierAddress);
                              });
                            });
                          } else if (selectedFilter == "No. Telp Pemasok") {
                            setState(() {
                              suppliers = backupSuppliers;
                              suppliers = suppliers!
                                  .where((product) => product
                                      .supplierPhoneNumber!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Supplier---");
                              suppliers!.forEach((element) {
                                print(element.supplierPhoneNumber);
                              });
                            });
                          } else if (selectedFilter == "Email Pemasok") {
                            setState(() {
                              suppliers = backupSuppliers;
                              suppliers = suppliers!
                                  .where((product) => product.supplierEmail!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Supplier---");
                              suppliers!.forEach((element) {
                                print(element.supplierEmail);
                              });
                            });
                          } else if (selectedFilter ==
                              "Kontak Person Pemasok") {
                            setState(() {
                              suppliers = backupSuppliers;
                              suppliers = suppliers!
                                  .where((product) => product
                                      .supplierContactPerson!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Supplier---");
                              suppliers!.forEach((element) {
                                print(element.supplierContactPerson);
                              });
                            });
                          } else if (selectedFilter == "Tax") {
                            setState(() {
                              suppliers = backupSuppliers;
                              suppliers = suppliers!
                                  .where((product) => product.supplierTax!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Supplier---");
                              suppliers!.forEach((element) {
                                print(element.supplierTax);
                              });
                            });
                          } else if (selectedFilter == "Cash") {
                            setState(() {
                              suppliers = backupSuppliers;
                              suppliers = suppliers!
                                  .where((product) => product.paymentType!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Supplier---");
                              suppliers!.forEach((element) {
                                print(element.paymentType);
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
              child: const Text("Tambah Supplier"),
              onPressed: (() async {
                await showAddSupplierModal(context);
                suppliersFuture = getSuppliers();
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
            future: suppliersFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    Material.DataColumn(label: Text('Kode Pemasok')),
                    Material.DataColumn(label: Text('Nama Pemasok')),
                    Material.DataColumn(label: Text('Item yg Dipasok')),
                    Material.DataColumn(label: Text('Alamat Pemasok')),
                    Material.DataColumn(label: Text('No. Telp Pemasok')),
                    Material.DataColumn(label: Text('Email Pemasok')),
                    Material.DataColumn(label: Text('Kontak Person Pemasok')),
                    Material.DataColumn(label: Text('Tax')),
                    Material.DataColumn(label: Text('Tenor')),
                    Material.DataColumn(label: Text('Cash')),
                    Material.DataColumn(label: Text('Aksi')),
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
              final laporanPdfFile = await PdfSupplierReportApi.generate(
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
  final List<Map<String, dynamic>> _data = List.generate(
      suppliers?.length ?? 500,
      (index) => {
            "id": suppliers?[index].supplierId,
            "supplierCode": suppliers?[index].supplierCode,
            "supplierName": suppliers?[index].supplierName,
            "supplierAddress": suppliers?[index].supplierAddress,
            "supplierPhoneNumber": suppliers?[index].supplierPhoneNumber,
            "supplierEmail": suppliers?[index].supplierEmail,
            "supplierContactPerson": suppliers?[index].supplierContactPerson,
            "supplierTax": suppliers?[index].supplierTax,
            "paymentTerm": suppliers?[index].paymentTerm ?? "-",
            "paymentType": suppliers?[index].paymentType,
            "supplierProducts": suppliers?[index].supplierProducts
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(Text(_data[index]['supplierCode'].toString())),
      Material.DataCell(Text(_data[index]['supplierName'].toString())),
      Material.DataCell(SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (SupplierProducts _suppProduct in _data[index]
                ['supplierProducts'])
              Text(
                  "- ${_suppProduct.material?.materialName ?? _suppProduct.fabricatingMaterial?.fabricatingMaterialName ?? _suppProduct.product?.productName}")
          ],
        ),
      )),
      Material.DataCell(Text(_data[index]['supplierAddress'].toString())),
      Material.DataCell(Text(_data[index]['supplierPhoneNumber'].toString())),
      Material.DataCell(Text(_data[index]['supplierEmail'].toString())),
      Material.DataCell(Text(_data[index]['supplierContactPerson'].toString())),
      Material.DataCell(Text(_data[index]['supplierTax'].toString())),
      Material.DataCell(Text(_data[index]['paymentTerm'].toString())),
      Material.DataCell(Text(_data[index]['paymentType'].toString())),
      Material.DataCell(Material.Row(
        children: [
          IconButton(
              onPressed: () {
                List<Map<String, dynamic>> _supplierProducts = [];
                List<Map<String, dynamic>> _supplierMaterials = [];
                List<Map<String, dynamic>> _supplierFabricatingMaterials = [];
                _data[index]['supplierProducts'].forEach((element) {
                  if (element.productId != null) {
                    _supplierProducts.add({
                      "productId": element.productId,
                      "materialId": null,
                      "fabricatingMaterialId": null,
                      "label": element.product.productName
                    });
                  }
                  if (element.materialId != null) {
                    _supplierMaterials.add({
                      "productId": null,
                      "materialId": element.materialId,
                      "fabricatingMaterialId": null,
                      "label": element.material.materialName
                    });
                  }

                  if (element.fabricatingMaterialId != null) {
                    _supplierFabricatingMaterials.add({
                      "productId": null,
                      "materialId": null,
                      "fabricatingMaterialId": element.fabricatingMaterialId,
                      "label":
                          element.fabricatingMaterial.fabricatingMaterialName
                    });
                  }
                });
                SupplierPage.globalKey.currentState!.showEditSupplierModal(
                    supplierId: _data[index]['id'],
                    supplierCode: _data[index]['supplierCode'],
                    supplierName: _data[index]['supplierName'],
                    supplierAddress: _data[index]['supplierAddress'],
                    supplierPhoneNumber: _data[index]['supplierPhoneNumber'],
                    supplierEmail: _data[index]['supplierEmail'],
                    supplierContactPerson: _data[index]
                        ['supplierContactPerson'],
                    supplierTax: _data[index]['supplierTax'],
                    paymentTerm: _data[index]['paymentTerm'],
                    paymentType: _data[index]['paymentType'],
                    supplierProducts: _supplierProducts,
                    supplierMaterials: _supplierMaterials,
                    supplierFabricatingMaterials:
                        _supplierFabricatingMaterials);
              },
              icon: const Icon(FluentIcons.edit, size: 24.0)),
          IconButton(
              onPressed: () {
                SupplierPage.globalKey.currentState!
                    .showRemoveSupplierModal(_data[index]['id']);
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
