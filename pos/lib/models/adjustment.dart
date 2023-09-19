import './material.dart';
import './product.dart';
import './fabricatingMaterial.dart';

class Adjustment {
  int? adjustmentId;
  String? adjustmentCode;
  String? adjustmentDate;
  int? materialId;
  int? productId;
  int? fabricatingMaterialId;
  String? formerQty;
  String? adjustedQty;
  String? adjustmentReason;
  String? adjustmentDesc;
  Product? product;
  Material? material;
  FabricatingMaterial? fabricatingMaterial;

  Adjustment({
    this.adjustmentId,
    this.adjustmentCode,
    this.adjustmentDate,
    this.materialId,
    this.productId,
    this.fabricatingMaterialId,
    this.formerQty,
    this.adjustedQty,
    this.adjustmentReason,
    this.adjustmentDesc,
    this.product,
    this.material,
    this.fabricatingMaterial,
  });

  Adjustment.fromJson(Map<String, dynamic> json) {
    adjustmentId = json['adjustmentId'];
    adjustmentCode = json['adjustmentCode'];
    adjustmentDate = json['adjustmentDate'];
    materialId = json['materialId'];
    productId = json['productId'];
    fabricatingMaterialId = json['fabricatingMaterialId'];
    formerQty = json['formerQty'];
    adjustedQty = json['adjustedQty'];
    adjustmentReason = json['adjustmentReason'];
    adjustmentDesc = json['adjustmentDesc'];
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
    material = json['material'] != null
        ? new Material.fromJson(json['material'])
        : null;
    fabricatingMaterial = json['fabricatingMaterial'] != null
        ? new FabricatingMaterial.fromJson(json['fabricatingMaterial'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adjustmentId'] = this.adjustmentId;
    data['adjustmentCode'] = this.adjustmentCode;
    data['adjustmentDate'] = this.adjustmentDate;
    data['materialId'] = this.materialId;
    data['productId'] = this.productId;
    data['fabricatingMaterialId'] = this.fabricatingMaterialId;
    data['formerQty'] = this.formerQty;
    data['adjustedQty'] = this.adjustedQty;
    data['adjustmentReason'] = this.adjustmentReason;
    data['adjustmentDesc'] = this.adjustmentDesc;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    if (this.material != null) {
      data['material'] = this.material!.toJson();
    }
    if (this.fabricatingMaterial != null) {
      data['fabricatingMaterial'] = this.fabricatingMaterial!.toJson();
    }
    return data;
  }
}
