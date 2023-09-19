import "package:example/models/fabricatingMaterial.dart";
import "package:example/models/product.dart";

import "./material.dart";
import "./supplier.dart";

class MaterialPurchase {
  int? materialPurchaseId;
  String? materialPurchaseCode;
  String? materialPurchaseDate;
  String? materialPurchaseQty;
  int? supplierId;
  int? materialId;
  Material? material;
  Product? product;
  FabricatingMaterial? fabricatingMaterial;
  Supplier? supplier;
  String? taxAmount;
  String? taxInvoiceNumber;
  String? taxInvoiceImg;
  MaterialPurchase(
      {this.materialPurchaseId,
      this.materialPurchaseCode,
      this.materialPurchaseDate,
      this.materialPurchaseQty,
      this.supplierId,
      this.materialId,
      this.material,
      this.product,
      this.fabricatingMaterial,
      this.supplier,
      this.taxAmount,
      this.taxInvoiceNumber,
      this.taxInvoiceImg});

  MaterialPurchase.fromJson(Map<String, dynamic> json) {
    materialPurchaseId = json['materialPurchaseId'];
    materialPurchaseCode = json['materialPurchaseCode'];
    materialPurchaseDate = json['materialPurchaseDate'];
    materialPurchaseQty = json['materialPurchaseQty'];
    supplierId = json['supplierId'];
    materialId = json['materialId'];
    material = json['material'] != null
        ? new Material.fromJson(json['material'])
        : null;
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
    fabricatingMaterial = json['fabricatingMaterial'] != null
        ? new FabricatingMaterial.fromJson(json['fabricatingMaterial'])
        : null;
    supplier = json['supplier'] != null
        ? new Supplier.fromJson(json['supplier'])
        : null;
    taxAmount = json['taxAmount'];
    taxInvoiceNumber = json['taxInvoiceNumber'];
    taxInvoiceImg = json['taxInvoiceImg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['materialPurchaseId'] = this.materialPurchaseId;
    data['materialPurchaseCode'] = this.materialPurchaseCode;
    data['materialPurchaseDate'] = this.materialPurchaseDate;
    data['materialPurchaseQty'] = this.materialPurchaseQty;
    data['supplierId'] = this.supplierId;
    data['materialId'] = this.materialId;
    if (this.material != null) {
      data['material'] = this.material!.toJson();
    }
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    if (this.fabricatingMaterial != null) {
      data['fabricatingMaterial'] = this.fabricatingMaterial!.toJson();
    }
    if (this.supplier != null) {
      data['supplier'] = this.supplier!.toJson();
    }
    data['taxAmount'] = this.taxAmount;
    data['taxInvoiceNumber'] = this.taxInvoiceNumber;
    data['taxInvoiceImg'] = this.taxInvoiceImg;
    return data;
  }
}
