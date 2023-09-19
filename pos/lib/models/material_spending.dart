import 'package:example/models/fabricatingMaterial.dart';
import './material.dart';

class MaterialSpending {
  int? materialSpendingId;
  String? materialSpendingCode;
  String? materialSpendingDate;
  String? materialSpendingQty;
  int? materialId;
  Material? material;
  FabricatingMaterial? fabricatingMaterial;

  MaterialSpending(
      {this.materialSpendingId,
      this.materialSpendingCode,
      this.materialSpendingDate,
      this.materialSpendingQty,
      this.materialId,
      this.material,
      this.fabricatingMaterial});

  MaterialSpending.fromJson(Map<String, dynamic> json) {
    materialSpendingId = json['materialSpendingId'];
    materialSpendingCode = json['materialSpendingCode'];
    materialSpendingDate = json['materialSpendingDate'];
    materialSpendingQty = json['materialSpendingQty'];
    materialId = json['materialId'];
    material = json['material'] != null
        ? new Material.fromJson(json['material'])
        : null;
    fabricatingMaterial = json['fabricatingMaterial'] != null
        ? new FabricatingMaterial.fromJson(json['fabricatingMaterial'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['materialSpendingId'] = this.materialSpendingId;
    data['materialSpendingCode'] = this.materialSpendingCode;
    data['materialSpendingDate'] = this.materialSpendingDate;
    data['materialSpendingQty'] = this.materialSpendingQty;
    data['materialId'] = this.materialId;
    if (this.material != null) {
      data['material'] = this.material!.toJson();
    }
    if (this.fabricatingMaterial != null) {
      data['fabricatingMaterial'] = this.fabricatingMaterial!.toJson();
    }
    return data;
  }
}
