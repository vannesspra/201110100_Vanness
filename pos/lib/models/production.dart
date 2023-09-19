import 'package:example/models/fabricatingMaterial.dart';

import './product.dart';

class Production {
  int? productionId;
  String? productionCode;
  String? productionDate;
  String? productionQty;
  // int? productId;
  // int? fabricatingMaterialId;
  String? productionDesc;
  Product? product;
  FabricatingMaterial? fabricatingMaterial;

  Production(
      {this.productionId,
      this.productionCode,
      this.productionDate,
      // this.productId,
      // this.fabricatingMaterialId,
      this.productionQty,
      this.productionDesc,
      this.product,
      this.fabricatingMaterial});

  Production.fromJson(Map<String, dynamic> json) {
    productionId = json['productionId'];
    productionCode = json['productionCode'];
    productionDate = json['productionDate'];
    // productId = json['productId'];
    // fabricatingMaterialId = json['fabricatingMaterialId'];
    productionQty = json['productionQty'];
    productionDesc = json['productionDesc'];
    product =
        json['product'] != null ? Product.fromJson(json['product']) : null;
    fabricatingMaterial = json['fabricatingMaterial'] != null
        ? FabricatingMaterial.fromJson(json['fabricatingMaterial'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['productionId'] = productionId;
    data['productionCode'] = productionCode;
    data['productionDate'] = productionDate;
    // data['productId'] = productId;
    // data['fabricatingMaterialId'] = fabricatingMaterialId;
    data['productionQty'] = productionQty;
    data['productionDesc'] = productionDesc;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (fabricatingMaterial != null) {
      data['fabricatingMaterial'] = fabricatingMaterial!.toJson();
    }
    return data;
  }
}
