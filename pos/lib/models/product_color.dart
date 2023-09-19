import './color.dart';

class ProductColor {
  int? productId;
  int? colorId;
  String? createdAt;
  String? updatedAt;
  Color? color;

  ProductColor(
      {this.productId,
      this.colorId,
      this.createdAt,
      this.updatedAt,
      this.color});

  ProductColor.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    colorId = json['colorId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    color = json['color'] != null ? new Color.fromJson(json['color']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['colorId'] = this.colorId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.color != null) {
      data['color'] = this.color!.toJson();
    }
    return data;
  }
}
