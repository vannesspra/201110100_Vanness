import '../models/product.dart';
import '../models/material.dart';
import '../models/fabricatingMaterial.dart';

class Supplier {
  int? supplierId;
  String? supplierCode;
  String? supplierName;
  String? supplierAddress;
  String? supplierPhoneNumber;
  String? supplierEmail;
  String? supplierContactPerson;
  String? paymentType;
  String? paymentTerm;
  String? supplierTax;
  List<SupplierProducts>? supplierProducts;

  Supplier(
      {this.supplierId,
      this.supplierCode,
      this.supplierName,
      this.supplierAddress,
      this.supplierPhoneNumber,
      this.supplierEmail,
      this.supplierContactPerson,
      this.paymentType,
      this.paymentTerm,
      this.supplierTax,
      this.supplierProducts});

  Supplier.fromJson(Map<String, dynamic> json) {
    supplierId = json['supplierId'];
    supplierCode = json['supplierCode'];
    supplierName = json['supplierName'];
    supplierAddress = json['supplierAddress'];
    supplierPhoneNumber = json['supplierPhoneNumber'];
    supplierEmail = json['supplierEmail'];
    supplierContactPerson = json['supplierContactPerson'];
    paymentType = json['paymentType'];
    paymentTerm = json['paymentTerm'];
    supplierTax = json['supplierTax'];
    if (json['supplierProducts'] != null) {
      supplierProducts = <SupplierProducts>[];
      json['supplierProducts'].forEach((v) {
        supplierProducts!.add(new SupplierProducts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['supplierId'] = supplierId;
    data['supplierCode'] = supplierCode;
    data['supplierName'] = supplierName;
    data['supplierAddress'] = supplierAddress;
    data['supplierPhoneNumber'] = supplierPhoneNumber;
    data['supplierEmail'] = supplierEmail;
    data['supplierContactPerson'] = supplierContactPerson;
    data['paymentType'] = paymentType;
    data['paymentTerm'] = paymentTerm;
    data['supplierTax'] = supplierTax;
    if (this.supplierProducts != null) {
      data['supplierProducts'] =
          this.supplierProducts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SupplierProducts {
  int? supplierProductId;
  int? supplierId;
  int? materialId;
  int? fabricatingMaterialId;
  int? productId;
  Product? product;
  Material? material;
  FabricatingMaterial? fabricatingMaterial;

  SupplierProducts(
      {this.supplierProductId,
      this.supplierId,
      this.materialId,
      this.fabricatingMaterialId,
      this.productId,
      this.product,
      this.material,
      this.fabricatingMaterial});

  SupplierProducts.fromJson(Map<String, dynamic> json) {
    supplierProductId = json['supplierProductId'];
    supplierId = json['supplierId'];
    materialId = json['materialId'];
    fabricatingMaterialId = json['fabricatingMaterialId'];
    productId = json['productId'];
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
    data['supplierProductId'] = this.supplierProductId;
    data['supplierId'] = this.supplierId;
    data['materialId'] = this.materialId;
    data['fabricatingMaterialId'] = this.fabricatingMaterialId;
    data['productId'] = this.productId;
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
