import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:example/functions/dateformatter.dart';
import 'package:example/models/activityLog.dart';
import 'package:example/services/activityLog.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;
import 'package:url_launcher/link.dart';
import 'package:example/services/file_handle_api.dart';
import 'package:example/services/report/pdf_log_report_api.dart';

import '../models/sponsor.dart';
import '../widgets/changelog.dart';
import '../widgets/material_equivalents.dart';
import '../widgets/page.dart';
import '../widgets/sponsor.dart';
import '../services/product.dart';
import '../models/product.dart';

List<ActivityLog>? logs;
List<ActivityLog>? backupLogs;
List<ActivityLog>? searchedLogs;

class LogPage extends StatefulWidget {
  static final GlobalKey<_LogPageState> globalKey = GlobalKey();
  LogPage({Key? key}) : super(key: globalKey);

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> with PageMixin {
  logService _logService = logService();
  late Material.DataTableSource _data;
  late Future logsFuture;
  bool selected = true;
  String? comboboxValue;

  DateTime? _dateTimeStart;
  DateTime? _dateTimeEnd;
  DateTime? _dateStart;
  DateTime? _dateEnd;
  DateTime? _date;

  String _formateDateStart = "";
  String _formateDateEnd = "";
  String _formateDate = "";

  String? message;
  String? status;

  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  getLogs() async {
    var response = await _logService.getLogs();
    logs = response.data;
    backupLogs = logs;
    logs?.forEach((element) {
      print(element.logId);
    });

    _data = DataTable();
  }

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Nama Pengguna", "Kegiatan", "Jenis Kegiatan"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    logsFuture = getLogs();
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
        title: Text('Log Activity'),
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
                          print("Value kosong");
                          setState(() {
                            logsFuture = getLogs();
                          });
                        } else {
                          if (selectedFilter == "Nama Pengguna") {
                            setState(() {
                              logs = backupLogs;
                              logs = logs!
                                  .where((log) => log.user!.userName!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                            });
                          } else if (selectedFilter == "Kegiatan") {
                            setState(() {
                              logs = backupLogs;
                              logs = logs!
                                  .where((log) => log.activityType!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                              _data = DataTable();
                            });
                          } else if (selectedFilter == "Jenis Kegiatan") {
                            setState(() {
                              logs = backupLogs;
                              logs = logs!
                                  .where((log) => log.activity!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
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

                        logs = backupLogs;
                        logs = logs!.where((log) {
                          _formateDate = log.activityDate!.substring(0, 10);
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
                    icon: const Icon(Material.Icons.refresh),
                    onPressed: () {
                      setState(() {
                        val = "";
                        _dateEnd = null;
                        _dateStart = null;
                        logsFuture = getLogs();
                      });
                    })
              ],
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: logsFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    Material.DataColumn(label: Text('Nama Pengguna')),
                    Material.DataColumn(label: Text('Kegiatan Terhadap')),
                    Material.DataColumn(label: Text('Jenis Kegiatan')),
                    Material.DataColumn(label: Text('Tanggal Kegiatan')),
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
                final laporanPdfFile = await PdfLogReportApi.generate(
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
  List<Color> _colors = [];
  final List<Map<String, dynamic>> _data = List.generate(
      logs?.length ?? 500,
      (index) => {
            "id": logs?[index].logId,
            "userId": logs?[index].userId,
            "activityType": logs?[index].activityType,
            "activity": logs?[index].activity,
            "activityDate": logs?[index].activityDate,
            "user": logs?[index].user,
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
      Material.DataCell(Text(_data[index]['user'].userName.toString())),
      Material.DataCell(Text(_data[index]['activityType'].toString())),
      Material.DataCell(Text(_data[index]['activity'].toString())),
      Material.DataCell(Text(dateFormatter(_data[index]['activityDate']))),
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
