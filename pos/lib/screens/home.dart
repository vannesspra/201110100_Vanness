import 'package:example/functions/dateformatter.dart';
import 'package:example/main.dart';
import 'package:intl/intl.dart';

import 'package:example/models/order.dart';
import 'package:example/models/product.dart';
import 'package:example/models/profile.dart';
import 'package:example/models/sale.dart';
import 'package:example/screens/linechart.dart';
import 'package:example/screens/pricePoints.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/home.dart';
import 'package:example/services/order.dart';
import 'package:example/services/pdf_invoice_api.dart';
import 'package:example/services/profile.dart';
import 'package:example/widgets/add_profile_modal_content.dart';
import 'package:example/widgets/payment/payment_modal_content.dart';
import 'package:example/widgets/sale/sale_detail.dart';
import 'package:example/widgets/update_profile_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:url_launcher/link.dart';
import 'package:responsive_ui/responsive_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:fl_chart/fl_chart.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';

//Dashboard Data
List<Product> backupProducts = [];
List<Product> products = [];
List<Product> searchedProducts = [];

List<Order> backupOrders = [];
List<Order> orders = [];
List<Order> detailOrders = [];
List<Order> searchedOrders = [];

List<Sale> backupSales = [];
List<Sale> sales = [];
List<Sale> searchedSale = [];

bool isToday = false;

Future<String> checker(BuildContext context, String orderCode) async {
  OrderService _orderService = OrderService();
  var response = await _orderService.checkOrderValid(orderCode: orderCode);

  return response.status!;
}

showDetailOrder(BuildContext context, String orderCode) async {
  OrderService _orderService = OrderService();

  var response = await _orderService.getOrderByCode(orderCode);

  detailOrders = response.data;

  List<Widget> list = [];
  detailOrders.forEach((element) {
    list.add(Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Produk : ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(element.product!.productName!)
              ],
            ),
            Row(
              children: [
                Text(
                  "Kuantiti : ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(element.qty!)
              ],
            ),
            element.deliveryId == null
                ? int.tryParse(element.product!.productQty!)! -
                            int.tryParse(element.qty!)! <
                        0
                    ? InfoBar(
                        title: Text("Kuantiti produk tidak mencukupi"),
                        severity: InfoBarSeverity.error,
                        isLong: true,
                      )
                    : InfoBar(
                        title: Text("Kuantiti produk mencukupi"),
                        severity: InfoBarSeverity.success,
                        isLong: true,
                      )
                : Container()
          ],
        ),
      ),
    ));
  });
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Daftar Produk'),
      content: ScaffoldPage.scrollable(children: list),
      actions: [
        FilledButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    ),
  );
}

showPayment(BuildContext context, String saleId, Sale sale) async {
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
            child: const Text('Bayar'),
            onPressed: () async {
              final pdfFile = await PdfInvoiceApi.generate(saleId);
              await FileHandleApi.openFile(pdfFile);
              await PaymentModalContent.globalKey.currentState!.createPayment();
              Navigator.pop(context);
            }),
      ],
    ),
  );
}

showSaleDetail(
    BuildContext context, String saleId, Sale sale, String status) async {
  print(status);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      title: const Text('Detail Penjualan'),
      content: SaleDetail(saleId: saleId, sale: sale),
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
                    await showPayment(context, saleId, sale);
                    Navigator.pop(context);
                  }
                : null),
      ],
    ),
  );
}

class HomePage extends StatefulWidget {
  static final GlobalKey<_HomePageState> globalKey = GlobalKey();
  HomePage({Key? key}) : super(key: globalKey);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PageMixin {
  Profile _profile = Profile();
  late Future profileFuture;
  late Future homeFuture;
  DateTime? _dateTime;
  String? _myDate;

  ProfileService _profileService = ProfileService();
  HomeService _homeService = HomeService();

  late Material.DataTableSource _data;
  late Material.DataTableSource _data1;
  late Material.DataTableSource _data2;

  bool selected = true;
  String? comboboxValue;

  _showSaleDetail(
      BuildContext context, String saleId, Sale sale, String status) async {
    await showSaleDetail(context, saleId, sale, status);
    setState(() {
      homeFuture = getHomeStat();
    });
  }

  String convertMonthFunc(int month) {
    var conv = "";
    switch (month) {
      case 1:
        conv = "Januari";
        break;
      case 2:
        conv = "Februari";
        break;
      case 3:
        conv = "Maret";
        break;
      case 4:
        conv = "April";
        break;
      case 5:
        conv = "Mei";
        break;
      case 6:
        conv = "Juni";
        break;
      case 7:
        conv = "Juli";
        break;
      case 8:
        conv = "Agustus";
        break;
      case 9:
        conv = "September";
        break;
      case 10:
        conv = "Oktober";
        break;
      case 11:
        conv = "November";
        break;
      case 12:
        conv = "Desember";
        break;
      default:
    }
    return conv;
  }

  getHomeStat() async {
    var response = await _homeService.getHomeStat();
    print("GET HOME STAT");
    // print(response.data);

    // Mapping Products
    products = [];
    response.data['products']['data'].forEach((data) {
      products.add(Product.fromJson(data));
    });
    backupProducts = products;
    _data = TestDataQty();

    // Mapping Orders
    orders = [];
    response.data['orders']['data'].forEach((data) {
      orders.add(Order.fromJson(data));
    });
    backupOrders = orders;
    _data1 = TestDataOrd(context: context);

    // Mapping Sales
    sales = [];
    final int today = DateTime.now().day;
    final int thisMonth = DateTime.now().month;
    final int thisYear = DateTime.now().year;
    String? convertmonth;

    convertmonth = convertMonthFunc(thisMonth);
    var time = "${today} ${convertmonth} ${thisYear}";
    response.data['transactions']['data'].forEach((data) {
      //TODO
      var array = Sale.fromJson(data);
      if (_dateTime == null) {
        if (dateFormatter(array.payments![0].paymentDate!) == time.toString()) {
          sales.add(array);
        }
      } else if (_dateTime != null) {
        var dateDay = '';
        if (_dateTime.toString().split(' ')[0].split('-')[2].startsWith('0')) {
          dateDay =
              _dateTime.toString().split(' ')[0].split('-')[2].split('0')[1];
        } else {
          dateDay = _dateTime.toString().split(' ')[0].split('-')[2];
        }
        var dateMonth = convertMonthFunc(
            int.parse(_dateTime.toString().split(' ')[0].split('-')[1]));
        var dateYear = _dateTime.toString().split(' ')[0].split('-')[0];
        var _finalDateTime = "${dateDay} ${dateMonth} ${dateYear}";
        if (dateFormatter(array.payments![0].paymentDate!) ==
            _finalDateTime.toString()) {
          sales.add(array);
        }
        print("final:" + _finalDateTime);
      }

      //  if (dateFormatter(array.saleDate!) == time.toString()) {
      //     setState(() {
      //       sales.add(array);
      //     });
      //   }
      //   print("iniiiiiiiiiiiii:"+"${dateFormatter(array.saleDate!) == time.toString()}");
      //   print(dateFormatter(array.saleDate!));
      //   print(time);
      //   print(array.saleDate!);
    });
    // print(response.data['transactions']['data']);
    backupSales = sales;
    _data2 = TestDataPay(context: context);
    setState(() {});
  }

  showUpdateProfileModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Ubah Profil Perusahaan'),
        content: UpdateProfileModalContent(
          companyId: _profile.companyId!,
          companyName: _profile.companyName!,
          companyAddress: _profile.companyAddress!,
          companyContactPerson: _profile.companyContactPerson!,
          companyContactPersonNumber: _profile.companyContactPersonNumber!,
          companyEmail: _profile.companyEmail!,
          companyPhoneNumber: _profile.companyPhoneNumber!,
          companyWebsite: _profile.companyWebsite!,
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
              onPressed: () {
                setState(() {
                  UpdateProfileModalContent.globalKey.currentState!
                      .updateProfile();
                });
              }),
        ],
      ),
    );
    setState(() {});
  }

  showAddProfileModal() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Profil Perusahaan'),
        content: AddProfileModalContent(),
        actions: [
          FilledButton(
              child: const Text('Tambah'),
              onPressed: () async {
                await AddProfileModalContent.globalKey.currentState!
                    .createProfile();
                Navigator.pop(context);
              }),
        ],
      ),
    );
    setState(() {});
  }

  getProfile() async {
    var response = await _profileService.getProfile();
    print(response.data);
    _profile = response.data;
    if (_profile.companyId == null) {
      await showAddProfileModal();
      setState(() {
        profileFuture = getProfile();
      });
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    profileFuture = getProfile();
    homeFuture = getHomeStat();
    // _dateTime;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // print(dotenv.env['TESTING']);
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: FutureBuilder(
            future: profileFuture,
            builder: (context, snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Text(
                  _profile.companyName ?? "",
                  style: TextStyle(fontFamily: "Dosis", fontSize: 45.0),
                );
              } else {
                child = Text(
                  "",
                  style: TextStyle(fontFamily: "Dosis", fontSize: 45.0),
                );
              }
              return child;
            }),
      ),
      children: [
        Card(
          child:
              Wrap(alignment: WrapAlignment.center, spacing: 24.0, children: [
            Responsive(alignment: WrapAlignment.spaceBetween, children: <
                Widget>[
              Div(
                divison: const Division(colS: 12, colXL: 6),
                child: Card(
                    margin: const EdgeInsets.all(5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                            future: profileFuture,
                            builder: (context, snapshot) {
                              Widget child;
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                child = Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 20.0,
                                  children: [
                                    const Text(
                                      "INFORMASI PERUSAHAAN",
                                      style: TextStyle(
                                          fontFamily: "Josefin",
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Material.Divider(
                                      color: Colors.white,
                                      thickness: 2,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      child: Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(4),
                                          1: FlexColumnWidth(1),
                                          2: FlexColumnWidth(6),
                                        },
                                        children: [
                                          TableRow(children: [
                                            const Text(
                                              "ALAMAT",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              _profile.companyAddress ?? "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "TELPON",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              _profile.companyPhoneNumber ?? "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "WEBSITE",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              _profile.companyWebsite ?? "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "EMAIL",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              _profile.companyEmail ?? "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "CTC PERSON",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              _profile.companyContactPerson ??
                                                  "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "NO CTC PERSON",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              _profile.companyContactPersonNumber ??
                                                  "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    )
                                  ],
                                );
                              } else {
                                child = Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 20.0,
                                  children: [
                                    const Text(
                                      "INFORMASI PERUSAHAAN",
                                      style: TextStyle(
                                          fontFamily: "Josefin",
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Material.Divider(
                                      color: Colors.white,
                                      thickness: 2,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      child: Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(4),
                                          1: FlexColumnWidth(1),
                                          2: FlexColumnWidth(6),
                                        },
                                        children: [
                                          TableRow(children: [
                                            const Text(
                                              "ALAMAT",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "TELPON",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "WEBSITE",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "EMAIL",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "CTC PERSON",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                          TableRow(children: [
                                            const Text(
                                              "NO CTC PERSON",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 16.0),
                                            ),
                                            const Text(
                                              ":",
                                              style: TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            ),
                                            Text(
                                              "",
                                              style: const TextStyle(
                                                  fontFamily: "Dosis",
                                                  fontSize: 18.0),
                                            )
                                          ]),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    )
                                  ],
                                );
                              }
                              return child;
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        Button(
                            child: const Text("Ubah Profil"),
                            onPressed: () async {
                              await showUpdateProfileModal(context);
                              setState(() {
                                profileFuture = getProfile();
                              });
                            })
                      ],
                    )),
              ),
              Div(
                divison: const Division(colS: 12, colXL: 6),
                child: Card(
                    margin: const EdgeInsets.all(5.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20.0,
                      children: [
                        FutureBuilder(
                            future: homeFuture,
                            builder: ((context, snapshot) {
                              Widget child;
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (sales.isEmpty) {
                                  child = Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Transaction Succed",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Material.Icons.date_range),
                                              onPressed: () {
                                                Material.showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2099),
                                                ).then((date) {
                                                  //tambahkan setState dan panggil variabel _dateTime.
                                                  setState(() {
                                                    _dateTime = date;
                                                    print(_dateTime);
                                                    homeFuture = getHomeStat();
                                                  });
                                                });
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                        const Center(
                                          heightFactor: 15,
                                          child:
                                              Text("Tidak Ada Data Transaksi"),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  child = Material.PaginatedDataTable(
                                    source: _data2,
                                    header: const Text(
                                      "Transaction Succed\t",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    actions: [
                                      Material.IconButton(
                                        icon: const Icon(
                                            Material.Icons.date_range),
                                        onPressed: () {
                                          Material.showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2099),
                                          ).then((date) {
                                            //tambahkan setState dan panggil variabel _dateTime.
                                            setState(() {
                                              _dateTime = date;
                                              print(_dateTime);
                                              homeFuture = getHomeStat();
                                            });
                                          });
                                          setState(() {});
                                        },
                                      )
                                    ],
                                    columns: const [
                                      Material.DataColumn(
                                          label: Text("Kode Penjualan")),
                                      Material.DataColumn(
                                          label: Text("Tanggal Pembayaran")),
                                    ],
                                    columnSpacing: 100,
                                    horizontalMargin: 65,
                                    rowsPerPage: 3,
                                  );
                                }
                              } else {
                                child = const Center(
                                  heightFactor: 10,
                                  child: ProgressRing(),
                                );
                              }
                              return child;
                            }))
                        // SizedBox(
                        //   height: 250,
                        //   child: Icon(FluentIcons.lock_solid),
                        // ),
                      ],
                    )),
              ),
              Div(
                  divison: const Division(colS: 12, colXL: 6),
                  child: SingleChildScrollView(
                    child: Card(
                        margin: const EdgeInsets.all(5.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20.0,
                          children: [
                            FutureBuilder(
                                future: homeFuture,
                                builder: ((context, snapshot) {
                                  Widget child;
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (products.isEmpty) {
                                      child = Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Stok Menipis",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Center(
                                              heightFactor: 15,
                                              child: Text(
                                                  "Tidak Ada Stok Menipis"),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      child = Material.PaginatedDataTable(
                                        source: _data,
                                        header: const Text(
                                          "Stok Menipis",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        columns: const [
                                          Material.DataColumn(
                                              label: Text("Nama Produk")),
                                          Material.DataColumn(
                                              label: Text("Kuantiti Tersisa")),
                                        ],
                                        columnSpacing: 100,
                                        horizontalMargin: 65,
                                        rowsPerPage: 4,
                                      );
                                    }
                                  } else {
                                    child = const Center(
                                      heightFactor: 10,
                                      child: ProgressRing(),
                                    );
                                  }
                                  return child;
                                }))
                            // SizedBox(
                            //   height: 250,
                            //   child: Icon(FluentIcons.lock_solid),
                            // ),
                          ],
                        )),
                  )),
              Div(
                divison: const Division(colS: 12, colXL: 6),
                child: Card(
                    margin: const EdgeInsets.all(5.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20.0,
                      children: [
                        FutureBuilder(
                            future: homeFuture,
                            builder: ((context, snapshot) {
                              Widget child;
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (orders.isEmpty) {
                                  child = Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Unprocessed Order",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Center(
                                          heightFactor: 15,
                                          child: Text(
                                              "Tidak Ada Orderan yang belum diproses"),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  child = Material.PaginatedDataTable(
                                    source: _data1,
                                    header: const Text(
                                      "Unprocessed Order\t",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    columns: const [
                                      Material.DataColumn(
                                          label: Text("Kode Pesanan")),
                                      Material.DataColumn(
                                          label: Text("Pelanggan")),
                                      Material.DataColumn(
                                          label: Text("Status")),
                                    ],
                                    columnSpacing: 100,
                                    horizontalMargin: 65,
                                    rowsPerPage: 4,
                                  );
                                }
                              } else {
                                child = const Center(
                                  heightFactor: 10,
                                  child: ProgressRing(),
                                );
                              }
                              return child;
                            }))
                        // SizedBox(
                        //   height: 250,
                        //   child: Icon(FluentIcons.lock_solid),
                        // ),
                      ],
                    )),
              ),
              Div(
                divison: const Division(colS: 12),
                child: Card(
                    margin: const EdgeInsets.all(5.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20.0,
                      children: [
                        const Text(
                          "Monthly Sales",
                          style: TextStyle(
                              fontFamily: "Josefin",
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                        const Material.Divider(
                          color: Colors.white,
                          thickness: 2,
                          height: 25,
                        ),
                        const LineChartSample1()
                        // SizedBox(
                        //   height: 250,
                        //   child: Icon(FluentIcons.lock_solid),
                        // ),
                      ],
                    )),
              ),
            ])
          ]),
        ),
        const SizedBox(height: 30.0),
      ],
    );
  }
}

class TestDataQty extends Material.DataTableSource {
  final List<Map<String, dynamic>> _data = List.generate(
      products.length,
      (index) => {
            "id": products[index].productId,
            "product_name": products[index].productName,
            "qty": products[index].productQty
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(Text(_data[index]['product_name'].toString())),
      Material.DataCell(Text(_data[index]['qty'].toString())),
    ]);
    // TODO: implement getRow
    throw UnimplementedError();
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

class TestDataOrd extends Material.DataTableSource {
  final BuildContext context;
  TestDataOrd({required this.context});
  final List<Map<String, dynamic>> _data1 = List.generate(
      orders.length,
      (index) => {
            "id": orders[index].orderId,
            "orderCode": orders[index].orderCode,
            "customer": orders[index].customer?.customerName,
            "status": orders[index].orderStatus,
            "deliveryId": orders[index].deliveryId
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(
      cells: [
        Material.DataCell(
          FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                String? data = snapshot.data;
                return Padding(
                    padding: const EdgeInsets.only(right: 80),
                    child: _data1[index]['deliveryId'] == null
                        ? Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child:
                                    Text(_data1[index]['orderCode'].toString()),
                              ),
                              data == "error"
                                  ? Icon(
                                      FluentIcons.product_warning,
                                      color: Colors.red,
                                    )
                                  : Text("")
                            ],
                          )
                        : Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child:
                                    Text(_data1[index]['orderCode'].toString()),
                              ),
                              Icon(
                                FluentIcons.check_mark,
                                color: Colors.green,
                              )
                            ],
                          ));
              } else {
                return Padding(
                  padding: const EdgeInsets.only(right: 80),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Text(_data1[index]['orderCode'].toString()),
                      ),
                    ],
                  ),
                );
              }
            },
            future: checker(context, _data1[index]['orderCode']),
          ),
          onTap: () {
            print("Hello");
            showDetailOrder(context, _data1[index]['orderCode']);
          },
        ),
        Material.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data1[index]['customer'].toString()),
        )),
        Material.DataCell(Padding(
          padding: const EdgeInsets.only(right: 80),
          child: Text(_data1[index]['status'].toString()),
        ))
      ],
    );
    ;
    // TODO: implement getRow
    throw UnimplementedError();
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _data1.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}

class TestDataPay extends Material.DataTableSource {
  final BuildContext context;
  TestDataPay({required this.context});
  final List<Map<String, dynamic>> _data2 = List.generate(
      sales.length,
      (index) => {
            "id": sales[index].saleId,
            "saleCode": sales[index].saleCode,
            "saleDate": sales[index].saleDate,
            "saleDeadline": sales[index].saleDeadline,
            "paymentType": sales[index].paymentType,
            "discount": sales[index].discountOnePercentage ?? "0",
            "tax": sales[index].tax,
            "saleDesc": sales[index].saleDesc ?? " - ",
            "saleStatus": sales[index].saleStatus,
            "payment": sales[index].payments![0]
          });

  @override
  Material.DataRow? getRow(int index) {
    // if (dateFormatter(_data2[index]['payment'].paymentDate) == time) {
    return Material.DataRow(cells: [
      Material.DataCell(
          Row(
            children: [
              Text(_data2[index]['saleCode'].toString()),
              _data2[index]['saleStatus'] == "Sudah dibayar"
                  ? Icon(
                      FluentIcons.check_mark,
                      color: Colors.green,
                    )
                  : Container()
            ],
          ), onTap: () {
        Sale _sale = Sale();
        sales.forEach((element) {
          if (element.saleId == _data2[index]['id']) {
            _sale = element;
          }
        });
        HomePage.globalKey.currentState!._showSaleDetail(
            context,
            _data2[index]['id'].toString(),
            _sale,
            _data2[index]['saleStatus'].toString());

        // final pdfFile =
        //     await PdfInvoiceApi.generate(_data[index]['id'].toString());
        // FileHandleApi.openFile(pdfFile);
      }),
      Material.DataCell(
          Text(dateFormatter(_data2[index]['payment'].paymentDate))),
    ]);
    // } else {
    //   !isToday;
    //   return const Material.DataRow(
    //     cells: [Material.DataCell(Text("No Transaction")), Material.DataCell(Text("No Transaction"))]
    //   );
    // }

    // TODO: implement getRow
    throw UnimplementedError();
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _data2.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
