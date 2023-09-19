import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/production.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_production_report_api.dart';
import 'package:example/services/production.dart';
import 'package:example/widgets/product/add_production_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import '../widgets/page.dart';

List<Production>? backupProductions;
List<Production>? productions2;
List<Production>? productions;
List<Production>? detailProductions;
List<Production>? searchedProductions;
List<Production>? productionsArr = [];
List selectedOrder = [];

bool isToday = false;

Future<List<Production>> getProductionDetail(
    {required String productionCode}) async {
  ProductionService _productionService = ProductionService();
  var response = await _productionService.getProductionByCode(productionCode);
  List<Production> _productions = response.data;
  return _productions;
}

class ProductionPage extends StatefulWidget {
  static final GlobalKey<_ProductionPageState> globalKey = GlobalKey();
  ProductionPage({Key? key}) : super(key: globalKey);

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> with PageMixin {
  bool selected = true;
  DateTime? _dateTimeStart;
  DateTime? _dateTimeEnd;
  DateTime? _dateStart;
  DateTime? _dateEnd;
  DateTime? _dateProduction;

  String _formateDateStart = "";
  String _formateDateEnd = "";
  String _formateDate = "";

  String? comboboxValue;
  ProductionService _productionService = ProductionService();
  String? message;
  String? status;
  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  FlyoutController buttonController = FlyoutController();
  FlyoutController getOrderDetailController = FlyoutController();

  removeProduction({required String productionCode}) async {
    var response = await _productionService.deleteProduction(
        productionCode: productionCode);
    var message = response.message;
    print(message);
  }

  showRemoveProductionModal(String productionCode) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Produksi'),
        content: Text("Apakah anda yakin akan menghapus produksi ini?"),
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
                await removeProduction(productionCode: productionCode);
                setState(() {
                  productionsFuture = getProductions();
                });
                Navigator.pop(context, 'User deleted file');
              }),
        ],
      ),
    );
  }

  showAddProductionModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Hasil Produksi'),
        content: AddProductionModalContent(),
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
                  AddProductionModalContent.globalKey.currentState!
                      .createProduction();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  late Future productionsFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = [
    "Nomor Produksi",
    "Barang",
    "Jenis Barang",
    "Kuantiti Produksi"
  ];

  getProductions() async {
    var response = await _productionService.getProductionGrouped();
    productions = response.data;

    // productionsArr = [];
    // final int today = DateTime.now().day;
    // final int thisMonth = DateTime.now().month;
    // final int thisYear = DateTime.now().year;
    // String? convertmonth;

    // convertmonth = convertMonthFunc(thisMonth);
    // var time = "${today} ${convertmonth} ${thisYear}";
    // response.data['productions']['data'].forEach((data) {
    //   //TODO
    //   var array = Production.fromJson(data);
    //   if (_dateTime == null) {
    //     if (dateFormatter(array.productionDate!) == time.toString()) {
    //       productionsArr!.add(array);
    //     }
    //   } else if (_dateTime != null) {
    //     var dateDay = '';
    //     if (_dateTime.toString().split(' ')[0].split('-')[2].startsWith('0')) {
    //       dateDay =
    //           _dateTime.toString().split(' ')[0].split('-')[2].split('0')[1];
    //     } else {
    //       dateDay = _dateTime.toString().split(' ')[0].split('-')[2];
    //     }
    //     var dateMonth = convertMonthFunc(
    //         int.parse(_dateTime.toString().split(' ')[0].split('-')[1]));
    //     var dateYear = _dateTime.toString().split(' ')[0].split('-')[0];
    //     var _finalDateTime = "${dateDay} ${dateMonth} ${dateYear}";
    //     if (dateFormatter(array.productionDate!) == _finalDateTime.toString()) {
    //       productionsArr!.add(array);
    //     }
    //     print("final:" + _finalDateTime);
    //   }

    //   //  if (dateFormatter(array.saleDate!) == time.toString()) {
    //   //     setState(() {
    //   //       sales.add(array);
    //   //     });
    //   //   }
    //   //   print("iniiiiiiiiiiiii:"+"${dateFormatter(array.saleDate!) == time.toString()}");
    //   //   print(dateFormatter(array.saleDate!));
    //   //   print(time);
    //   //   print(array.saleDate!);
    // });
    backupProductions = productions;
    print("Get to View Production: ${productions}");
    _data = DataTable(context: context);
    // setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productionsFuture = getProductions();
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
      header: const PageHeader(
        title: Text('Produksi'),
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
                            productionsFuture = getProductions();
                          });
                          print("---Searched Product---");
                          // products!.forEach((element) {
                          //   print(element.productName);
                          // });
                        } else {
                          if (selectedFilter == "Nomor Produksi") {
                            setState(() {
                              productions = backupProductions;
                              productions = productions!
                                  .where((production) => production
                                      .productionCode!
                                      .contains(value))
                                  .toList();
                              _data = DataTable(context: context);
                              print("---Searched Product---");
                              productions!.forEach((element) {
                                print(element.productionCode);
                              });
                            });
                          } else if (selectedFilter == "Barang") {
                            setState(() {
                              productions = backupProductions;
                              productions2 = backupProductions;
                              productions = productions!.where((production) {
                                if (production.product != null) {
                                  return production.product!.productName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return production.productionCode!
                                    .contains(value);
                              }).toList();
                              productions2 = productions2!.where((production) {
                                if (production.fabricatingMaterial != null) {
                                  return production.fabricatingMaterial!
                                      .fabricatingMaterialName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return production.productionCode!
                                    .contains(value);
                              }).toList();
                              productions!.addAll(productions2!);
                              // print(productions);
                              _data = DataTable(context: context);
                              print("---Searched Product---");
                              productions!.forEach((element) {
                                print(element);
                                // print(element.fabricatingMaterial!
                                //     .fabricatingMaterialName);
                              });
                            });
                            // } else if (selectedFilter == "Barang") {
                            //   setState(() {
                            //     productions = backupProductions;
                            //     productions = productions!
                            //         .where((production) => production
                            //             .fabricatingMaterial!
                            //             .fabricatingMaterialName!
                            //             .contains(value))
                            //         .toList();
                            //     _data = DataTable(context: context);
                            //     print("---Searched Product---");
                            //     productions!.forEach((element) {
                            //       print(element.fabricatingMaterial!
                            //           .fabricatingMaterialName);
                            //     });
                            //   });
                          } else if (selectedFilter == "Jenis Barang") {
                            setState(() {
                              productions = backupProductions;
                              productions = productions!.where((production) {
                                if (production.product != null) {
                                  return production.product!.type!.typeName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return production.productionCode!
                                    .contains(value);
                              }).toList();
                              _data = DataTable(context: context);
                              print("---Searched Product---");
                              productions!.forEach((element) {
                                print(element.product!.type!.typeName);
                              });
                            });
                          } else if (selectedFilter == "Kuantiti Produksi") {
                            setState(() {
                              productions = backupProductions;
                              productions = productions!
                                  .where((production) =>
                                      production.productionQty!.contains(value))
                                  .toList();
                              _data = DataTable(context: context);
                              print("---Searched Product---");
                              productions!.forEach((element) {
                                print(element.productionQty);
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
                        _formateDateEnd =
                            formatDate(_dateTimeEnd!, [yyyy, '-', mm, '-', dd]);
                        _formateDateStart = formatDate(
                            _dateTimeStart!, [yyyy, '-', mm, '-', dd]);

                        _dateStart = DateTime.parse(_formateDateStart);
                        _dateEnd = DateTime.parse(_formateDateEnd);

                        dateEnd = _dateEnd;
                        dateStart = _dateStart;

                        productions = backupProductions;
                        productions = productions!.where((production) {
                          _formateDate =
                              production.productionDate!.substring(0, 10);
                          _dateProduction = DateTime.parse(_formateDate);

                          return (_dateProduction!
                                      .isAtSameMomentAs(_dateStart!) ||
                                  _dateProduction!
                                      .isAtSameMomentAs(_dateEnd!)) ||
                              (_dateProduction!.isBefore(_dateEnd!) &&
                                  _dateProduction!.isAfter(_dateStart!));
                        }).toList();
                        _data = DataTable(context: context);
                        print("Date Production: $_dateProduction");
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
                        productionsFuture = getProductions();
                      });
                    })
              ],
            ),
            Container(
                child: Button(
              child: const Text("Tambah Produksi"),
              onPressed: (() async {
                await showAddProductionModal(context);
                setState(() {
                  productionsFuture = getProductions();
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
          future: productionsFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget child;
            if (snapshot.connectionState == ConnectionState.done) {
              if (productions!.isEmpty || productions == null) {
                child = const Center(
                  heightFactor: 10,
                  child: Text("Tidak Ada Produk Yang Di Produksi"),
                );
              } else {
                child = Material.PaginatedDataTable(
                  columns: const [
                    Material.DataColumn(label: Text('Nomor Produksi')),
                    Material.DataColumn(label: Text('Tanggal Produksi')),
                    Material.DataColumn(label: Text('Barang')),
                    Material.DataColumn(label: Text('Jenis Barang')),
                    Material.DataColumn(label: Text('Kuantiti Produksi')),
                    Material.DataColumn(label: Text('Keterangan Produksi')),
                    Material.DataColumn(label: Text('Aksi')),
                  ],
                  source: () {
                    return _data;
                  }(),
                  columnSpacing: 80,
                  horizontalMargin: 30,
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
          },
        ),
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
                final laporanPdfFile = await PdfProductionReportApi.generate(
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

class DataTable extends Material.DataTableSource {
  final BuildContext context;
  DataTable({required this.context});
  final List<Map<String, dynamic>> _data = List.generate(
      productions?.length ?? 500,
      (index) => {
            "id": productions?[index].productionId,
            "productionCode": productions?[index].productionCode,
            "productionDate": productions?[index].productionDate,
            "productionDesc": productions?[index].productionDesc ?? "-",
            "productionQty": productions?[index].productionQty,
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(
        Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data[index]['productionCode'].toString()),
        ),
      ),
      Material.DataCell(
        Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(dateFormatter(_data[index]['productionDate'])),
        ),
      ),
      Material.DataCell(
        Padding(
          padding: const EdgeInsets.only(right: 80),
          child: FutureBuilder(
            future: getProductionDetail(
                productionCode: _data[index]['productionCode']),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                List<Production> _productions = snapshot.data;

                child = SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (Production production in _productions)
                        Text(
                            "${production.product?.productName ?? production.fabricatingMaterial?.fabricatingMaterialName}")
                    ],
                  ),
                );
              } else {
                child = Container();
              }
              return child;
            },
          ),
        ),
      ),
      Material.DataCell(
        Padding(
          padding: const EdgeInsets.only(right: 80),
          child: FutureBuilder(
            future: getProductionDetail(
                productionCode: _data[index]['productionCode']),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                List<Production> _productions = snapshot.data;

                child = SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (Production production in _productions)
                        Text("${production.product?.type?.typeName ?? "-"}")
                    ],
                  ),
                );
              } else {
                child = Container();
              }
              return child;
            },
          ),
        ),
      ),
      Material.DataCell(Text(_data[index]['productionQty'].toString())),
      Material.DataCell(Text(_data[index]['productionDesc'].toString())),
      Material.DataCell(Material.Row(
        children: [
          IconButton(
              onPressed: () {
                ProductionPage.globalKey.currentState!
                    .showRemoveProductionModal(_data[index]['productionCode']);
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
