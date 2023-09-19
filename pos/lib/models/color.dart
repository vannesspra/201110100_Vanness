class Color {
  int? colorId;
  String? colorCode;
  String? colorName;
  String? colorDesc;

  Color({this.colorId, this.colorCode, this.colorName, this.colorDesc});

  Color.fromJson(Map<String, dynamic> json) {
    colorId = json['colorId'];
    colorCode = json['colorCode'];
    colorName = json['colorName'];
    colorDesc = json['colorDesc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['colorId'] = this.colorId;
    data['colorCode'] = this.colorCode;
    data['colorName'] = this.colorName;
    data['colorDesc'] = this.colorDesc;
    return data;
  }
}
