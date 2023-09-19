import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/models/material.dart';

import './customer.dart';
import './product.dart';
import './delivery.dart';

class Order {
  int? orderId;
  String? orderCode;
  String? orderDate;
  String? requestedDeliveryDate;
  int? productId;
  int? materialId;
  int? fabricatingMaterialId;
  int? customerId;
  String? qty;
  String? orderDesc;
  String? orderStatus;
  int? deliveryId;
  Delivery? delivery;
  Product? product;
  Material? material;
  FabricatingMaterial? fabricatingMaterial;
  String? name;
  String? price;
  Customer? customer;
  int? saleId;

  Order(
      {this.orderId,
      this.orderCode,
      this.orderDate,
      this.requestedDeliveryDate,
      this.productId,
      this.materialId,
      this.fabricatingMaterialId,
      this.customerId,
      this.qty,
      this.orderDesc,
      this.orderStatus,
      this.deliveryId,
      this.delivery,
      this.product,
      this.material,
      this.fabricatingMaterial,
      this.name,
      this.price,
      this.customer,
      this.saleId});

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    orderCode = json['orderCode'];
    orderDate = json['orderDate'];
    requestedDeliveryDate = json['requestedDeliveryDate'];
    productId = json['productId'];
    materialId = json['materialId'];
    fabricatingMaterialId = json['fabricatingMaterialId'];
    customerId = json['customerId'];
    qty = json['qty'];
    orderDesc = json['orderDesc'];
    orderStatus = json['orderStatus'];
    deliveryId = json['deliveryId'];
    delivery = json['delivery'] != null
        ? new Delivery.fromJson(json['delivery'])
        : null;
    product =
        json['product'] != null ? new Product.fromJson(json['product']) : null;
    material = json['material'] != null
        ? new Material.fromJson(json['material'])
        : null;
    fabricatingMaterial = json['fabricatingMaterial'] != null
        ? new FabricatingMaterial.fromJson(json['fabricatingMaterial'])
        : null;
    name = json['name'];
    price = json['price'];
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
    saleId = json['saleId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['orderCode'] = this.orderCode;
    data['orderDate'] = this.orderDate;
    data['requestedDeliveryDate'] = this.requestedDeliveryDate;
    data['productId'] = this.productId;
    data['materialId'] = this.materialId;
    data['fabricatingMaterialId'] = this.fabricatingMaterialId;
    data['customerId'] = this.customerId;
    data['qty'] = this.qty;
    data['orderDesc'] = this.orderDesc;
    data['orderStatus'] = this.orderStatus;
    data['deliveryId'] = this.deliveryId;
    if (this.delivery != null) {
      data['delivery'] = this.delivery!.toJson();
    }
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    if (this.material != null) {
      data['material'] = this.material!.toJson();
    }
    if (this.fabricatingMaterial != null) {
      data['fabricatingMaterial'] = this.fabricatingMaterial!.toJson();
    }
    data['name'] = this.name;
    data['price'] = this.price;
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    data['saleId'] = this.saleId;
    return data;
  }
}
