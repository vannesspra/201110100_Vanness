import 'dart:math';

import 'package:example/models/customer.dart';
import 'package:example/models/product_color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_customer_report_api.dart';
import 'package:example/widgets/customer/add_customer_modal_content.dart';
import 'package:example/widgets/customer/edit_customer_modal_content.dart';
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

List<Customer>? backupCustomers;
List<Customer>? customers;
List<Customer>? searchedCustomers;

class CustomerPage extends StatefulWidget {
  static final GlobalKey<_CustomerPageState> globalKey = GlobalKey();
  CustomerPage({Key? key}) : super(key: globalKey);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> with PageMixin {
  bool selected = true;
  String? comboboxValue;
  CustomerServices _customerService = CustomerServices();
  String? message;
  String? status;
  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  removedCustomer({required int customerId}) async {
    var response =
        await _customerService.removeCustomer(customerId: customerId);
    var message = response.message;
    print(message);
  }

  showRemoveCustomerModal(int customerId) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Pelanggan'),
        content: Text("Apakah anda yakin akan menghapus pelanggan ini?"),
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
                await removedCustomer(customerId: customerId);
                setState(() {
                  customersFuture = getCustomers();
                });
                Navigator.pop(context, 'User deleted file');
              }),
        ],
      ),
    );
  }

  showAddCustomerModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Pelanggan/Customer'),
        content: AddCustomerModalContent(),
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
                AddCustomerModalContent.globalKey.currentState!.postCustomer();
              }),
        ],
      ),
    );
    setState(() {});
  }

  showEditCustomerModal({
    required int customerId,
    required String customerCode,
    required String customerName,
    required String customerAddress,
    required String customerPhoneNumber,
    required String customerEmail,
    required String customerContactPerson,
    required String discountOne,
    required String discountTwo,
    required String paymentType,
    required String paymentTerm,
    required String tax,
    required List<Map<String, String>> extraDiscounts,
  }) async {
    print(extraDiscounts);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Ubah Pelanggan/Customer'),
        content: EditCustomerModalContent(
          customerId: customerId,
          customerCode: customerCode,
          customerName: customerName,
          customerAddress: customerAddress,
          customerPhoneNumber: customerPhoneNumber,
          customerContactPerson: customerContactPerson,
          customerEmail: customerEmail,
          discountOne: discountOne,
          discountTwo: discountTwo,
          paymentType: paymentType,
          paymentTerm: paymentTerm,
          tax: tax,
          extraDiscounts: extraDiscounts,
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
                await EditCustomerModalContent.globalKey.currentState!
                    .updateCustomer();
                setState(() {
                  customersFuture = getCustomers();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  late Future customersFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = [
    "Kode Pelanggan",
    "Nama Pelanggan",
    "Alamat Pelanggan",
    "No. Telp Pelanggan",
    "Email Pelanggan",
    "Kontak Person Pelanggan",
    "Jenis Pembayaran",
    "PPN"
  ];

  getCustomers() async {
    var response = await _customerService.getCustomer();
    customers = response.data;
    backupCustomers = customers;
    print("Get to View Customer: ${customers}");
    customers?.forEach((element) {
      print(element.customerName);
    });
    _data = DataTable();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customersFuture = getCustomers();
  }

  String val = "";

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Pelanggan / Customer'),
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
                            customersFuture = getCustomers();
                          });
                          print("---Searched Product---");
                          customers!.forEach((element) {
                            print(element.customerName);
                          });
                        } else {
                          if (selectedFilter == "Kode Pelanggan") {
                            setState(() {
                              customers = backupCustomers;
                              customers = customers!
                                  .where((customer) =>
                                      customer.customerCode!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              customers!.forEach((element) {
                                print(element.customerName);
                              });
                            });
                          } else if (selectedFilter == "Nama Pelanggan") {
                            setState(() {
                              customers = backupCustomers;
                              customers = customers!
                                  .where((customer) => customer.customerName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              customers!.forEach((element) {
                                print(element.customerName);
                              });
                            });
                          } else if (selectedFilter == "Alamat Pelanggan") {
                            setState(() {
                              customers = backupCustomers;
                              customers = customers!
                                  .where((customer) => customer.customerAddress!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              customers!.forEach((element) {
                                print(element.customerAddress);
                              });
                            });
                          } else if (selectedFilter == "No. Telp Pelanggan") {
                            setState(() {
                              customers = backupCustomers;
                              customers = customers!
                                  .where((customer) => customer
                                      .customerPhoneNumber!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              customers!.forEach((element) {
                                print(element.customerPhoneNumber);
                              });
                            });
                          } else if (selectedFilter == "Email Pelanggan") {
                            setState(() {
                              customers = backupCustomers;
                              customers = customers!
                                  .where((customer) => customer.customerEmail!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              customers!.forEach((element) {
                                print(element.customerEmail);
                              });
                            });
                          } else if (selectedFilter ==
                              "Kontak Person Pelanggan") {
                            setState(() {
                              customers = backupCustomers;
                              customers = customers!
                                  .where((customer) => customer
                                      .customerContactPerson!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              customers!.forEach((element) {
                                print(element.customerContactPerson);
                              });
                            });
                          } else if (selectedFilter == "Jenis Pembayaran") {
                            setState(() {
                              customers = backupCustomers;
                              customers = customers!
                                  .where((customer) => customer.paymentType!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              customers!.forEach((element) {
                                print(element.paymentType);
                              });
                            });
                          } else if (selectedFilter == "PPN") {
                            setState(() {
                              customers = backupCustomers;
                              customers = customers!
                                  .where((customer) => customer.tax!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              customers!.forEach((element) {
                                print(element.tax);
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
              child: const Text("Tambah Pelanggan / Customer"),
              onPressed: (() async {
                await showAddCustomerModal(context);
                setState(() {
                  customersFuture = getCustomers();
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
            future: customersFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    // Material.DataColumn(label: Text('Id Pelanggan')),
                    Material.DataColumn(label: Text('Kode Pelanggan')),
                    Material.DataColumn(label: Text('Nama Pelanggan')),
                    Material.DataColumn(label: Text('Alamat Pelanggan')),
                    Material.DataColumn(label: Text('No. Telp Pelanggan')),
                    Material.DataColumn(label: Text('Email Pelanggan')),
                    Material.DataColumn(label: Text('Kontak Person Pelanggan')),

                    Material.DataColumn(label: Text('Diskon 1')),
                    Material.DataColumn(label: Text('Diskon 2')),
                    Material.DataColumn(label: Text('Jenis Pembayaran')),
                    Material.DataColumn(label: Text('Jangka Waktu')),
                    Material.DataColumn(label: Text('PPN')),
                    // Material.DataColumn(
                    //     label: Text('Diskon Tambahan')),
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
              final laporanPdfFile = await PdfCustomerReportApi.generate(
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
      customers?.length ?? 500,
      (index) => {
            "id": customers?[index].customerId,
            "customerCode": customers?[index].customerCode,
            "customerName": customers?[index].customerName,
            "customerAddress": customers?[index].customerAddress,
            "customerPhoneNumber": customers?[index].customerPhoneNumber,
            "customerEmail": customers?[index].customerEmail,
            "customerContactPerson": customers?[index].customerContactPerson,
            "discountOne": customers?[index].discountOne,
            "discountTwo": customers?[index].discountTwo,
            "paymentType": customers?[index].paymentType,
            "paymentTerm": customers?[index].paymentTerm,
            "tax": customers?[index].tax,
            "extraDiscounts": customers?[index].extraDiscounts
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(Text(_data[index]['customerCode'].toString())),
      Material.DataCell(Text(_data[index]['customerName'].toString())),
      Material.DataCell(Text(_data[index]['customerAddress'].toString())),
      Material.DataCell(Text(_data[index]['customerPhoneNumber'].toString())),
      Material.DataCell(Text(_data[index]['customerEmail'].toString())),
      Material.DataCell(Text(_data[index]['customerContactPerson'].toString())),
      Material.DataCell(Text(_data[index]['discountOne'].toString())),
      Material.DataCell(Text(_data[index]['discountTwo'].toString())),
      Material.DataCell(Text(_data[index]['paymentType'].toString())),
      Material.DataCell(Text(_data[index]['paymentTerm'].toString())),
      Material.DataCell(Text(_data[index]['tax'].toString())),
      // Material.DataCell(Text(_data[index]['extraDiscounts'].toString())),
      Material.DataCell(Material.Row(
        children: [
          IconButton(
              onPressed: () {
                List<Map<String, String>> _extraDiscounts = [];
                for (ExtraDiscounts extraDiscount in _data[index]
                    ['extraDiscounts']) {
                  _extraDiscounts.add({
                    "amountPaid": extraDiscount.amountPaid!,
                    "discount": extraDiscount.discount!,
                    "edited": "true"
                  });
                }
                CustomerPage.globalKey.currentState!.showEditCustomerModal(
                    customerId: _data[index]['id'],
                    customerCode: _data[index]['customerCode'],
                    customerName: _data[index]['customerName'],
                    customerAddress: _data[index]['customerAddress'],
                    customerPhoneNumber: _data[index]['customerPhoneNumber'],
                    customerEmail: _data[index]['customerEmail'],
                    customerContactPerson: _data[index]
                        ['customerContactPerson'],
                    discountOne: _data[index]['discountOne'] ?? "",
                    discountTwo: _data[index]['discountTwo'] ?? "",
                    paymentType: _data[index]['paymentType'],
                    paymentTerm: _data[index]['paymentTerm'] ?? "",
                    tax: _data[index]['tax'],
                    extraDiscounts: _extraDiscounts);
              },
              icon: const Icon(FluentIcons.edit, size: 24.0)),
          IconButton(
              onPressed: () {
                CustomerPage.globalKey.currentState!
                    .showRemoveCustomerModal(_data[index]['id']);
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
