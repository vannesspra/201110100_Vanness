import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:intl/intl.dart';
import 'package:example/models/color.dart';
import 'package:example/models/product_color.dart';
import 'package:example/services/adjustment.dart';
import 'package:example/widgets/adjustment/add_adjustment_modal_content.dart';
import 'package:example/widgets/product/edit_product_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as FlutterMaterial;
import 'package:url_launcher/link.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_adjustment_report_api.dart';

import '../models/material.dart';
import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../services/product.dart';
import '../models/product.dart';
import '../models/adjustment.dart';

import '../widgets/product/add_product_modal_content.dart';

List<Adjustment>? backupAdjustments;
List<Adjustment>? adjustments;
List<Adjustment>? adjustments2;
List<Adjustment>? adjustments3;

List<Adjustment>? searchedAdjustments;

class AdjustmentPage extends StatefulWidget {
  static final GlobalKey<_AdjustmentPageState> globalKey = GlobalKey();
  AdjustmentPage({Key? key}) : super(key: globalKey);

  @override
  State<AdjustmentPage> createState() => _AdjustmentPageState();
}

class _AdjustmentPageState extends State<AdjustmentPage> with PageMixin {
  ProductService _productService = ProductService();
  AdjustmentService _adjustmentService = AdjustmentService();
  late FlutterMaterial.DataTableSource _data;

  late Future adjustmentsFuture;
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

  String? message;
  String? status;

  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  getAdjustments() async {
    var response = await _adjustmentService.getAdjustments();
    adjustments = response.data;
    backupAdjustments = adjustments;
    adjustments?.forEach((element) {
      print(element.adjustmentCode);
    });
    _data = DataTable();
  }

  showAddAdjustmentModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Penyesuaian Inventory'),
        content: AddAdjustmentModalContent(),
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
                  AddAdjustmentModalContent.globalKey.currentState!
                      .postAdjustment();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  String selectedFilter = "Cari Berdasarkan";
  List filterList = [
    "Kode Penyesuaian",
    "Nama Item",
    "Kategori",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    adjustmentsFuture = getAdjustments();
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
        title: Text('Penyesuaian'),
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
                            adjustmentsFuture = getAdjustments();
                          });
                        } else {
                          if (selectedFilter == "Kode Penyesuaian") {
                            setState(() {
                              adjustments = backupAdjustments;
                              adjustments = adjustments!
                                  .where((adjustment) => adjustment
                                      .adjustmentCode!
                                      .contains(value))
                                  .toList();
                              _data = DataTable();
                            });
                          } else if (selectedFilter == "Nama Item") {
                            setState(() {
                              adjustments = backupAdjustments;
                              adjustments2 = backupAdjustments;
                              adjustments3 = backupAdjustments;

                              adjustments = adjustments!.where((adjustment) {
                                if (adjustment.product != null) {
                                  return adjustment.product!.productName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return adjustment.adjustmentCode!
                                    .contains(value);
                              }).toList();
                              _data = DataTable();
                              adjustments2 = adjustments2!.where((adjustment) {
                                if (adjustment.material != null) {
                                  return adjustment.material!.materialName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return adjustment.adjustmentCode!
                                    .contains(value);
                              }).toList();
                              adjustments!.addAll(adjustments2!);
                              _data = DataTable();
                              adjustments3 = adjustments3!.where((adjustment) {
                                if (adjustment.fabricatingMaterial != null) {
                                  return adjustment.fabricatingMaterial!
                                      .fabricatingMaterialName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase());
                                }
                                return adjustment.adjustmentCode!
                                    .contains(value);
                              }).toList();
                              adjustments!.addAll(adjustments3!);
                              _data = DataTable();
                              adjustments!.forEach((element) {
                                print(element);
                              });
                            });
                          } else if (selectedFilter == "Kategori") {
                            setState(() {
                              adjustments = backupAdjustments;
                              if ("bahan baku".contains(value.toLowerCase())) {
                                adjustments = adjustments!
                                    .where((adjusment) =>
                                        adjusment.material != null)
                                    .toList();
                              } else if ("produk"
                                  .contains(value.toLowerCase())) {
                                adjustments = adjustments!
                                    .where((adjusment) =>
                                        adjusment.product != null)
                                    .toList();
                              } else if ("barang 1/2 jadi"
                                  .contains(value.toLowerCase())) {
                                adjustments = adjustments!
                                    .where((adjusment) =>
                                        adjusment.fabricatingMaterial != null)
                                    .toList();
                              } else {
                                setState(() {
                                  adjustmentsFuture = getAdjustments();
                                });
                              }
                              _data = DataTable();
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

                        adjustments = backupAdjustments;
                        adjustments = adjustments!.where((adj) {
                          _formateDate = adj.adjustmentDate!.substring(0, 10);
                          _date = DateTime.parse(_formateDate);

                          return (_date!.isAtSameMomentAs(_dateStart!) ||
                                  _date!.isAtSameMomentAs(_dateEnd!)) ||
                              (_date!.isBefore(_dateEnd!) &&
                                  _date!.isAfter(_dateStart!));
                        }).toList();
                        _data = DataTable();
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
                        adjustmentsFuture = getAdjustments();
                      });
                    })
              ],
            ),
            Container(
                child: Button(
              child: const Text("Tambah Penyesuaian Inventory"),
              onPressed: (() async {
                await showAddAdjustmentModal(context);
                setState(() {
                  adjustmentsFuture = getAdjustments();
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
            future: adjustmentsFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = FlutterMaterial.PaginatedDataTable(
                  columns: const [
                    FlutterMaterial.DataColumn(label: Text('Kode Penyesuaian')),
                    FlutterMaterial.DataColumn(
                        label: Text('Tanggal Penyesuaian')),
                    FlutterMaterial.DataColumn(label: Text('Kategori')),
                    FlutterMaterial.DataColumn(label: Text('Nama Item')),
                    FlutterMaterial.DataColumn(label: Text('Kuantiti Sistem')),
                    FlutterMaterial.DataColumn(
                        label: Text('Kuantiti(Disesuaikan)')),
                    FlutterMaterial.DataColumn(label: Text('Alasan')),
                    FlutterMaterial.DataColumn(label: Text('Deskripsi')),
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
              if (_dateStart == null && _dateEnd == null) {
                showDialog<String>(
                  context: context,
                  builder: (context) => ContentDialog(
                    style: ContentDialogThemeData(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20)
                      )
                    ),
                    constraints: const BoxConstraints(maxWidth: 450),
                    title: Row(
                      children: [
                        const Icon(FlutterMaterial.Icons.warning, size: 35,),
                        Spacer(),
                        Text("Maaf, Tanggal Harus Dipilih !", textAlign: TextAlign.center,)
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
              }else{
                final laporanPdfFile = await PdfAdjusmentReportApi.generate(
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
  List<Color> _colors = [];
  final List<Map<String, dynamic>> _data = List.generate(
      adjustments?.length ?? 500,
      (index) => {
            "id": adjustments?[index].adjustmentId,
            "adjustmentCode": adjustments?[index].adjustmentCode,
            "adjustmentDate": adjustments?[index].adjustmentDate,
            "material": adjustments?[index].material,
            "product": adjustments?[index].product,
            "fabricatingMaterial": adjustments?[index].fabricatingMaterial,
            "formerQty": adjustments?[index].formerQty,
            "adjustedQty": adjustments?[index].adjustedQty,
            "adjustmentReason": adjustments?[index].adjustmentReason ?? " - ",
            "adjustmentDesc": adjustments?[index].adjustmentDesc ?? " - ",
          });

  @override
  FlutterMaterial.DataRow? getRow(int index) {
    var itemType = "Barang 1/2 Jadi";
    var itemName;
    if (_data[index]['material'] == null &&
        _data[index]['fabricatingMaterial'] == null) {
      itemType = "Produk";
      itemName = _data[index]['product'].productName;
    } else if (_data[index]['product'] == null &&
        _data[index]['fabricatingMaterial'] == null) {
      itemType = "Bahan Baku";
      itemName = _data[index]['material'].materialName;
    } else if (_data[index]['product'] == null &&
        _data[index]['material'] == null) {
      itemName = _data[index]['fabricatingMaterial'].fabricatingMaterialName;
    }

    return FlutterMaterial.DataRow(cells: [
      FlutterMaterial.DataCell(Text(_data[index]['adjustmentCode'].toString())),
      FlutterMaterial.DataCell(
          Text(dateFormatter(_data[index]['adjustmentDate']))),
      FlutterMaterial.DataCell(Text(itemType)),
      FlutterMaterial.DataCell(Text(itemName ?? "")),
      FlutterMaterial.DataCell(Text(_data[index]['formerQty'].toString())),
      FlutterMaterial.DataCell(Text(_data[index]['adjustedQty'].toString())),
      FlutterMaterial.DataCell(
          Text(_data[index]['adjustmentReason'].toString())),
      FlutterMaterial.DataCell(Text(_data[index]['adjustmentDesc'].toString())),
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
