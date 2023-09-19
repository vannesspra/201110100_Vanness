import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:example/models/activityLog.dart';
import 'package:example/models/profile.dart';
import 'package:example/screens/activity_log_screen.dart';
import 'package:example/services/activityLog.dart';
import 'package:example/services/profile.dart';
import 'package:flutter/services.dart';
import '../file_handle_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// var n = 0;

class PdfLogReportApi {
  static Future<File> generate({
    required String filter,
    required String value,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) async {
    final pdf = pw.Document();

    final iconImage =
        (await rootBundle.load('assets/logo.jpg')).buffer.asUint8List();

    List<ActivityLog> _logs = [];
    Profile _profile = Profile();
    ProfileService _profileService = ProfileService();
    logService _logService = logService();
    List<List> newTableData = [];
    DateTime? _date;
    String _formateDate = "";
    String formateDateStart = formatDate(dateStart, [dd, " ", MM, " ", yyyy]);
    String formateDateEnd = formatDate(dateEnd, [dd, " ", MM, " ", yyyy]);

    var profileRes = await _profileService.getProfile();
    _profile = profileRes.data;
    var res3 = await _logService.getLogs();
    _logs = res3.data;

    void tableData(ActivityLog log) {
      newTableData.add([
        log.user!.userName,
        log.activityType,
        log.activity,
        log.activityDate!.substring(0, 10)
      ]);
    }

    if (value.isNotEmpty) {
      print("INIIIIIIIIIIIIIIIIIIIIIIIIIIIII" + value.toString());

      switch (filter) {
        case "Nama Pengguna":
          _logs.forEach((log) {
            if (log.user!.userName!
                .toLowerCase()
                .contains(value.toLowerCase())) {
              tableData(log);
            }
          });
          break;
        case "Kegiatan":
          _logs.forEach((log) {
            if (log.activityType!.toLowerCase().contains(value.toLowerCase())) {
              tableData(log);
            }
          });
          break;
        case "Jenis Kegiatan":
          _logs.forEach((log) {
            if (log.activity!.toLowerCase().contains(value.toLowerCase())) {
              tableData(log);
            }
          });
          break;
        default:
      }
    } else {
      print("Date Start $dateStart");
      print("Date End $dateEnd");
      _logs.forEach((log) {
        _formateDate = log.activityDate!.substring(0, 10);
        _date = DateTime.parse(_formateDate);

        if ((_date!.isAtSameMomentAs(dateStart) ||
                _date!.isAtSameMomentAs(dateEnd)) ||
            (_date!.isBefore(dateEnd) && _date!.isAfter(dateStart))) {
          tableData(log);
        }
      });
    }
    // _extraDiskon =
    //     (priceList.sum * int.parse(_sale.extraDiscountPercentage!) / 100)
    //         .round();

    final tableHeaders = [
      'Nama Pengguna',
      'Kegiatan',
      'Jenis Kegiatan',
      'Tanggal Kejadian',
    ];

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Row(
              children: [
                pw.Image(
                  pw.MemoryImage(iconImage),
                  height: 72,
                  width: 72,
                ),
                pw.SizedBox(width: 1 * PdfPageFormat.mm),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Activity Logs Report',
                      style: pw.TextStyle(
                        fontSize: 17.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      _profile.companyName!,
                      style: const pw.TextStyle(
                        fontSize: 15.0,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      "${formateDateStart} - ${formateDateEnd}",
                      style: const pw.TextStyle(
                        fontSize: 10.0,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),

            ///
            /// PDF Table Create
            ///
            pw.Table.fromTextArray(
              headers: tableHeaders,
              data: newTableData,
              border: null,
              headerHeight: 25.0,
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30.0,
              cellStyle: pw.TextStyle(fontSize: 8),
              cellPadding: pw.EdgeInsets.only(top: 2.0, bottom: 2.0),
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
              },
            ),
            pw.Divider(),
          ];
        },
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Text(
                _profile.companyName!,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Alamat: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    _profile.companyAddress!,
                  ),
                ],
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Email: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    _profile.companyEmail!,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // n += 1;
    return FileHandleApi.saveDocument(name: 'my_log_report.pdf', pdf: pdf);
  }
}
