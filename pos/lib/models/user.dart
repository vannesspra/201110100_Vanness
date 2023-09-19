import 'package:pdf/widgets.dart';

class User {
  int? userId;
  String? name;
  String? userName;
  String? password;
  String? role;
  String? refresh_token;

  User(
      {this.userId,
      this.name,
      this.userName,
      this.password,
      this.role,
      this.refresh_token});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    userName = json['userName'];
    password = json['password'];
    role = json['role'];
    refresh_token = json['refresh_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['userId'] = userId;
    data['name'] = name;
    data['userName'] = userName;
    data['password'] = password;
    data['role'] = role;
    data['refresh_token'] = refresh_token;
    return data;
  }
}
