import 'package:intl/intl.dart';

String dateFormatter(String date) {
  if (date != "-") {
    DateTime datetime = DateTime.parse(date);
    String formatted = DateFormat.yMMMMd('id_ID').format(datetime);
    return formatted;
  } else {
    return "-";
  }
}
