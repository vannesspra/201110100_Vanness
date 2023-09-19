import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/models/product_color.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/pdf_invoice_api.dart';
import 'package:example/widgets/customer/add_customer_modal_content.dart';
import 'package:example/widgets/delivery/delivery_detail.dart';
import 'package:example/widgets/payment/payment_modal_content.dart';
import 'package:example/widgets/sale/add_sale_modal_content.dart';
import 'package:example/widgets/sale/edit_sale_modal_content.dart';
import 'package:example/widgets/sale/sale_detail.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:url_launcher/link.dart';
import '../models/sale.dart';
import '../services/sale.dart';
import '../models/sponsor.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_sales_report_api.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';

List<Sale>? backupSales;
List<Sale>? sales;
List<Sale>? searchedSales;
bool isPay = false;

showPayment(BuildContext context, String saleId, Sale sale, status) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Bayar'),
      content: PaymentModalContent(
        saleId: saleId,
        sale: sale,
      ),
      actions: [
        Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context);
            }),
        FilledButton(
            child: isPay == false ? Text('Bayar') : Text('Sudah Dibayar'),
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (context) => ContentDialog(
                        constraints: const BoxConstraints(maxWidth: 300),
                        title: const Text("Konfirmasi Pembayaran"),
                        content: const Text(
                            'Apakah anda yakin melakukan pembayaran?'),
                        actions: [
                          Button(
                              child: const Text('Batal'),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          FilledButton(
                              child: const Text('Bayar'),
                              onPressed: () async {
                                await PaymentModalContent
                                    .globalKey.currentState!
                                    .createPayment();
                                Navigator.pop(context);
                              }),
                        ],
                      ));
              Navigator.pop(context);
              // final pdfFile = await PdfInvoiceApi.generate(saleId);
              // await FileHandleApi.openFile(pdfFile);
            }),
      ],
    ),
  );
}

showSaleDetail(
    BuildContext context, String saleId, Sale sale, String status) async {
  print(saleId);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Detail Penjualan'),
      content: SaleDetail(
        saleId: saleId,
        sale: sale,
      ),
      actions: [
        Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context);
            }),
        FilledButton(
            child: status == "Belum dibayar"
                ? Text('Bayar')
                : Text('Sudah Dibayar'),
            onPressed: status == "Belum dibayar"
                ? () async {
                    await showPayment(context, saleId, sale, status);
                    Navigator.pop(context);
                  }
                : null),
      ],
    ),
  );
}

class SalePage extends StatefulWidget {
  static final GlobalKey<_SalePageState> globalKey = GlobalKey();
  SalePage({Key? key}) : super(key: globalKey);

  @override
  State<SalePage> createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> with PageMixin {
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
  SaleService _saleService = SaleService();
  String? message;
  String? status;
  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Kode Penjualan", "Pembayaran", "Diskon", "PPN"];

  _showSaleDetail(
      BuildContext context, String saleId, Sale sale, String status) async {
    await showSaleDetail(context, saleId, sale, status);
    setState(() {
      salesFuture = getSales();
    });
  }

  getSales() async {
    var response = await _saleService.getSales();
    sales = response.data;
    backupSales = sales;
    print("Get to View Product: ${sales}");

    _data = DataTable(context: context);
  }

  showSaleModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Sales'),
        content: AddSaleModalContent(),
        actions: [
          Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context);
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Tambah'),
              onPressed: () {
                setState(() {
                  AddSaleModalContent.globalKey.currentState!.createSale();
                });
              }),
        ],
      ),
    );
  }

  showEditSaleModal(BuildContext context, int id, String saleCode,
      String saleDate, String saleDeadline, String saleDesc) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Edit Sales'),
        content: EditSaleModalContent(
          saleId: id,
          saleCode: saleCode,
          saleDate: saleDate,
          saleDeadline: saleDeadline,
          saleDesc: saleDesc,
        ),
        actions: [
          Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context);
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Simpan'),
              onPressed: () {
                setState(() {
                  EditSaleModalContent.globalKey.currentState!.createSale();
                });
              }),
        ],
      ),
    );
  }

  late Future salesFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    salesFuture = getSales();
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
        title: Text('Sales'),
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
                        if (value == "") {
                          print("Value Kosong");
                          setState(() {
                            salesFuture = getSales();
                          });
                        } else {
                          if (selectedFilter == "Kode Penjualan") {
                            setState(() {
                              sales = backupSales;
                              sales = sales!
                                  .where((sales) =>
                                      sales.saleCode!.contains(value))
                                  .toList();
                              _data = DataTable(context: context);
                            });
                          } else if (selectedFilter == "Pembayaran") {
                            setState(() {
                              sales = backupSales;
                              sales = sales!
                                  .where((sales) =>
                                      sales.paymentType!.contains(value))
                                  .toList();
                              _data = DataTable(context: context);
                            });
                          } else if (selectedFilter == "Diskon") {
                            setState(() {
                              sales = backupSales;
                              sales = sales!
                                  .where((sales) => sales.discountOnePercentage!
                                      .contains(value))
                                  .toList();
                              _data = DataTable(context: context);
                            });
                          } else if (selectedFilter == "PPN") {
                            setState(() {
                              sales = backupSales;
                              sales = sales!
                                  .where((sales) => sales.tax!.contains(value))
                                  .toList();
                              _data = DataTable(context: context);
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

                        sales = backupSales;
                        sales = sales!.where((sales) {
                          _formateDate = sales.saleDate!.substring(0, 10);
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
                    icon: const Icon(Material.Icons.refresh),
                    onPressed: () {
                      setState(() {
                        val = "";
                        _dateEnd = null;
                        _dateStart = null;
                        salesFuture = getSales();
                      });
                    })
              ],
            ),
            Container(
                child: Button(
              child: const Text("Tambah Sales"),
              onPressed: (() async {
                await showSaleModal(context);
                setState(() {
                  salesFuture = getSales();
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
            future: salesFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    // Material.DataColumn(label: Text('Id Pelanggan')),
                    Material.DataColumn(label: Text('Kode Penjualan')),
                    Material.DataColumn(label: Text('Tanggal Penjualan')),
                    Material.DataColumn(
                        label: Text('Tenggat Waktu Pembayaran')),
                    Material.DataColumn(label: Text('Pembayaran')),
                    Material.DataColumn(label: Text('Diskon(%)')),
                    Material.DataColumn(label: Text('PPN')),
                    Material.DataColumn(label: Text('Deskripsi Penjualan')),
                    Material.DataColumn(label: Text('Status Penjualan')),
                    Material.DataColumn(label: Text('Aksi'))
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
                final laporanPdfFile = await PdfsalesReportApi.generate(
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
      sales?.length ?? 500,
      (index) => {
            "id": sales?[index].saleId,
            "saleCode": sales?[index].saleCode,
            "saleDate": sales?[index].saleDate,
            "saleDeadline": sales?[index].saleDeadline,
            "paymentType": sales?[index].paymentType,
            "discount": sales?[index].discountOnePercentage ?? "0",
            "tax": sales?[index].tax,
            "saleDesc": sales?[index].saleDesc ?? " - ",
            "saleStatus": sales?[index].saleStatus,
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(
          Row(
            children: [
              Text(_data[index]['saleCode'].toString()),
              _data[index]['saleStatus'] == "Sudah dibayar"
                  ? Icon(
                      FluentIcons.check_mark,
                      color: Colors.green,
                    )
                  : Container()
            ],
          ), onTap: () {
        Sale _sale = Sale();
        sales!.forEach((element) {
          if (element.saleId == _data[index]['id']) {
            _sale = element;
          }
        });
        print("SASUKE ${_sale.saleCode}");
        SalePage.globalKey.currentState!._showSaleDetail(
            context,
            _data[index]['id'].toString(),
            _sale,
            _data[index]['saleStatus'].toString());

        // final pdfFile =
        //     await PdfInvoiceApi.generate(_data[index]['id'].toString());
        // FileHandleApi.openFile(pdfFile);
      }),
      Material.DataCell(Text(dateFormatter(_data[index]['saleDate']))),
      Material.DataCell(Text(dateFormatter(_data[index]['saleDeadline']))),
      Material.DataCell(Text(_data[index]['paymentType'].toString())),
      Material.DataCell(Text("${_data[index]['discount'].toString()}%")),
      Material.DataCell(Text(_data[index]['tax'].toString())),
      Material.DataCell(Text(_data[index]['saleDesc'].toString())),
      Material.DataCell(Text(_data[index]['saleStatus'].toString())),
      Material.DataCell(Material.Row(
        children: [
          IconButton(
              onPressed: () {
                SalePage.globalKey.currentState!.showEditSaleModal(
                    context,
                    _data[index]['id'],
                    _data[index]['saleCode'],
                    _data[index]['saleDate'],
                    _data[index]['saleDeadline'],
                    _data[index]['saleDesc']);
              },
              icon: const Icon(FluentIcons.edit, size: 24.0)),
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
