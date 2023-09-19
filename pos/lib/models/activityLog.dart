import 'user.dart';

class ActivityLog {
  int? logId;
  int? userId;
  String? activityType;
  String? activity;
  String? activityDate;
  User? user;

  ActivityLog(
      {this.logId,
      this.userId,
      this.activityType,
      this.activity,
      this.activityDate,
      this.user});

  ActivityLog.fromJson(Map<String, dynamic> json) {
    logId = json['logId'];
    userId = json['userId'];
    activityType = json['activityType'];
    activity = json['activity'];
    activityDate = json['activityDate'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['logId'] = this.logId;
    data['userId'] = this.userId;
    data['activityType'] = this.activityType;
    data['activity'] = this.activity;
    data['activityDate'] = this.activityDate;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}
