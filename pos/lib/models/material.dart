import 'package:example/models/color.dart';

class Material {
  int? materialId;
  String? materialCode;
  String? materialName;
  int? colorId;
  Color? color;
  String? materialUnit;
  String? materialMinimumStock;
  String? materialPrice;
  String? materialQty;

  Material(
      {this.materialId,
      this.materialCode,
      this.materialName,
      this.color,
      this.materialUnit,
      this.materialMinimumStock,
      this.materialPrice,
      this.materialQty});

  Material.fromJson(Map<String, dynamic> json) {
    materialId = json['materialId'];
    materialCode = json['materialCode'];
    materialName = json['materialName'];
    colorId = json['colorId'];
    materialUnit = json['materialUnit'];
    materialMinimumStock = json['materialMinimumStock'];
    materialPrice = json['materialPrice'];
    materialQty = json['materialQty'];
    color = json['color'] != null ? Color.fromJson(json['color']) : null;
  }

  Object? get value => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['materialId'] = this.materialId;
    data['materialCode'] = this.materialCode;
    data['materialName'] = this.materialName;
    data['colorId'] = this.colorId;
    data['materialUnit'] = this.materialUnit;
    data['materialMinimumStock'] = this.materialMinimumStock;
    data['materialPrice'] = this.materialPrice;
    data['materialQty'] = this.materialQty;
    if (color != null) {
      data['color'] = color!.toJson();
    }
    return data;
  }
}
