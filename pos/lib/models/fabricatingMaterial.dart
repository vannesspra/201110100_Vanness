import 'package:example/models/color.dart';

class FabricatingMaterial {
  int? fabricatingMaterialId;
  String? fabricatingMaterialCode;
  String? fabricatingMaterialName;
  int? colorId;
  Color? color;
  String? fabricatingMaterialUnit;
  String? fabricatingMaterialMinimumStock;
  String? fabricatingMaterialQty;
  String? fabricatingMaterialPrice;
  bool? isDeleted;

  FabricatingMaterial(
      {this.fabricatingMaterialId,
      this.fabricatingMaterialCode,
      this.fabricatingMaterialName,
      this.color,
      this.fabricatingMaterialUnit,
      this.fabricatingMaterialMinimumStock,
      this.fabricatingMaterialQty,
      this.fabricatingMaterialPrice,
      this.isDeleted});

  FabricatingMaterial.fromJson(Map<String, dynamic> json) {
    fabricatingMaterialId = json['fabricatingMaterialId'];
    fabricatingMaterialCode = json['fabricatingMaterialCode'];
    fabricatingMaterialName = json['fabricatingMaterialName'];
    colorId = json['colorId'];
    fabricatingMaterialUnit = json['fabricatingMaterialUnit'];
    fabricatingMaterialMinimumStock = json['fabricatingMaterialMinimumStock'];
    fabricatingMaterialQty = json['fabricatingMaterialQty'];
    fabricatingMaterialPrice = json['fabricatingMaterialPrice'];
    color = json['color'] != null ? Color.fromJson(json['color']) : null;
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fabricatingMaterialId'] = this.fabricatingMaterialId;
    data['fabricatingMaterialCode'] = this.fabricatingMaterialCode;
    data['fabricatingMaterialName'] = this.fabricatingMaterialName;
    data['colorId'] = this.colorId;
    data['fabricatingMaterialUnit'] = this.fabricatingMaterialUnit;
    data['fabricatingMaterialMinimumStock'] =
        this.fabricatingMaterialMinimumStock;
    data['fabricatingMaterialQty'] = this.fabricatingMaterialQty;
    data['fabricatingMaterialPrice'] = this.fabricatingMaterialPrice;
    data['isDeleted'] = this.isDeleted;
    if (color != null) {
      data['color'] = color!.toJson();
    }
    return data;
  }
}
