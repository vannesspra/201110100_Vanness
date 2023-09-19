class ProductType {
  int? typeId;
  String? typeCode;
  String? typeName;
  String? typeDesc;

  ProductType({this.typeId, this.typeCode, this.typeName, this.typeDesc});

  ProductType.fromJson(Map<String, dynamic> json) {
    typeId = json['typeId'];
    typeCode = json['typeCode'];
    typeName = json['typeName'];
    typeDesc = json['typeDesc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeId'] = this.typeId;
    data['typeCode'] = this.typeCode;
    data['typeName'] = this.typeName;
    data['typeDesc'] = this.typeDesc;

    return data;
  }
}
