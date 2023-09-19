// import './product_color.dart';
import './color.dart';
import './product_type.dart';

class Product {
  int? productId;
  String? productCode;
  String? productName;
  int? typeId;
  int? colorId;
  String? productPrice;
  String? productDesc;
  String? productMinimumStock;
  String? productQty;
  // List<ProductColor>? productColors;
  Color? color;
  ProductType? type;

  Product(
      {this.productId,
      this.productCode,
      this.productName,
      this.typeId,
      this.productPrice,
      this.productDesc,
      this.productMinimumStock,
      this.productQty,
      // this.productColors,
      this.color,
      this.type});

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productCode = json['productCode'];
    productName = json['productName'];
    typeId = json['typeId'];
    colorId = json['colorId'];
    productPrice = json['productPrice'];
    productDesc = json['productDesc'];
    productMinimumStock = json['productMinimumStock'];
    productQty = json['productQty'];
    // if (json['productColors'] != null) {
    //   productColors = <ProductColor>[];
    //   json['productColors'].forEach((v) {
    //     productColors!.add(new ProductColor.fromJson(v));
    //   });
    // }
    type = json['type'] != null ? new ProductType.fromJson(json['type']) : null;
    color = json['color'] != null ? new Color.fromJson(json['color']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['productCode'] = this.productCode;
    data['productName'] = this.productName;
    data['typeId'] = this.typeId;
    data['colorId'] = this.colorId;
    data['productPrice'] = this.productPrice;
    data['productDesc'] = this.productDesc;
    data['productMinimumStock'] = this.productMinimumStock;
    data['productQty'] = this.productQty;
    // if (this.productColors != null) {
    //   data['productColors'] =
    //       this.productColors!.map((v) => v.toJson()).toList();
    // }
    if (this.type != null) {
      data['type'] = this.type!.toJson();
    }
    if (this.color != null) {
      data['color'] = this.color!.toJson();
    }
    return data;
  }
}
