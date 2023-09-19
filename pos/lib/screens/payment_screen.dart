import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_payment_report_api.dart';
import 'package:intl/intl.dart';
import 'package:example/models/payment.dart';
import 'package:example/models/product_color.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/payment.dart';
import 'package:example/services/pdf_invoice_api.dart';
import 'package:example/widgets/customer/add_customer_modal_content.dart';
import 'package:example/widgets/delivery/delivery_detail.dart';
import 'package:example/widgets/payment/payment_modal_content.dart';
import 'package:example/widgets/sale/add_sale_modal_content.dart';
import 'package:example/widgets/sale/sale_detail.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:url_launcher/link.dart';
import '../models/sale.dart';
import '../services/sale.dart';
import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';

List<Payment>? backupPayment;
List<Payment>? payments;
List<Payment>? searchedPayment;

showPayment(BuildContext context, String saleId, Sale sale) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Payment Sales'),
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
            child: const Text('Bayar'),
            onPressed: () async {
              await PaymentModalContent.globalKey.currentState!.createPayment();
              Future.delayed(Duration(seconds: 5), () {
                Navigator.pop(context);
              });
            }),
      ],
    ),
  );
}

showSaleDetail(BuildContext context, String saleId, Sale sale) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Penjualan yang dibayar'),
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
            child: const Text('Cetak Invoice'),
            onPressed: () async {
              // final pdfFile =
              //     await PdfInvoiceApi.generate(_data[index]['id'].toString());
              // FileHandleApi.openFile(pdfFile);
              final pdfFile = await PdfInvoiceApi.generate(saleId);
              await FileHandleApi.openFile(pdfFile);
              Navigator.pop(context);
            }),
      ],
    ),
  );
}

class PaymentPage extends StatefulWidget {
  static final GlobalKey<_PaymentPageState> globalKey = GlobalKey();
  PaymentPage({Key? key}) : super(key: globalKey);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with PageMixin {
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
  PaymentService _paymentService = PaymentService();
  String? message;
  String? status;
  late Material.DataTableSource _data;
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  late Future salesFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Kode Pembayaran", "Kode Penjualan"];

  _showSaleDetail(BuildContext context, String saleId, Sale sale) async {
    print("Kontol Testing : $saleId");
    await showSaleDetail(context, saleId, sale);
    setState(() {
      salesFuture = getSales();
    });
  }

  getSales() async {
    var response = await _paymentService.getPayments();
    payments = response.data;
    backupPayment = payments;
    print("Get to View Product: ${payments}");

    _data = DataTable(context: context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    salesFuture = getSales();
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
        title: Text('Payment Sales'),
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
                            salesFuture = getSales();
                          });
                        } else {
                          if (selectedFilter == "Kode Pembayaran") {
                            setState(() {
                              payments = backupPayment;
                              payments = payments!
                                  .where((payment) =>
                                      payment.paymentCode!.contains(value))
                                  .toList();
                              _data = DataTable(context: context);
                            });
                          } else if (selectedFilter == "Kode Penjualan") {
                            setState(() {
                              payments = backupPayment;
                              payments = payments!
                                  .where((payment) =>
                                      payment.sale!.saleCode!.contains(value))
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

                        payments = backupPayment;
                        payments = payments!.where((pay) {
                          _formateDate = pay.paymentDate!.substring(0, 10);
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
                    Material.DataColumn(label: Text('Kode Pembayaran')),
                    Material.DataColumn(label: Text('Tanggal Pembayaran')),
                    Material.DataColumn(label: Text('Keterangan')),
                    Material.DataColumn(label: Text('Kode Penjualan'))
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
                        borderRadius: BorderRadius.circular(20)
                      )
                    ),
                    constraints: const BoxConstraints(maxWidth: 450),
                    title: Row(
                      children: [
                        const Icon(Material.Icons.warning, size: 35,),
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
                final laporanPdfFile = await PdfPaymentReportApi.generate(
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
      payments?.length ?? 500,
      (index) => {
            "id": payments?[index].paymentId,
            "paymentCode": payments?[index].paymentCode,
            "paymentDate": payments?[index].paymentDate,
            "paymentDesc": payments?[index].paymentDesc ?? " - ",
            "saleId": payments?[index].saleId,
            "sale": payments?[index].sale,
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(Text(_data[index]['paymentCode'].toString()),
          onTap: () {
        PaymentPage.globalKey.currentState!._showSaleDetail(
            context, _data[index]['saleId'].toString(), _data[index]['sale']);
      }),
      Material.DataCell(Text(dateFormatter(_data[index]['paymentDate']))),
      Material.DataCell(Text(_data[index]['paymentDesc'].toString())),
      Material.DataCell(Text(_data[index]['sale'].saleCode.toString())),
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
