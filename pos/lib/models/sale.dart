import './payment.dart';

class Sale {
  int? saleId;
  String? saleCode;
  String? saleDate;
  String? saleDeadline;
  String? paymentType;
  String? paymentTerm;
  String? discountOnePercentage;
  String? discountTwoPercentage;
  String? extraDiscountPercentage;
  String? tax;
  String? saleDesc;
  String? saleStatus;
  List<Payment>? payments;

  Sale(
      {this.saleId,
      this.saleCode,
      this.saleDate,
      this.saleDeadline,
      this.paymentType,
      this.paymentTerm,
      this.discountOnePercentage,
      this.discountTwoPercentage,
      this.extraDiscountPercentage,
      this.tax,
      this.saleDesc,
      this.saleStatus,
      this.payments});

  Sale.fromJson(Map<String, dynamic> json) {
    saleId = json['saleId'];
    saleCode = json['saleCode'];
    saleDate = json['saleDate'];
    saleDeadline = json['saleDeadline'];
    paymentType = json['paymentType'];
    paymentTerm = json['paymentTerm'];
    discountOnePercentage = json['discountOnePercentage'];
    discountTwoPercentage = json['discountTwoPercentage'];
    extraDiscountPercentage = json['extraDiscountPercentage'];
    tax = json['tax'];
    saleDesc = json['saleDesc'];
    saleStatus = json['saleStatus'];
    if (json['payments'] != null) {
      payments = <Payment>[];
      json['payments'].forEach((v) {
        payments!.add(new Payment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['saleId'] = this.saleId;
    data['saleCode'] = this.saleCode;
    data['saleDate'] = this.saleDate;
    data['saleDeadline'] = this.saleDeadline;
    data['paymentType'] = this.paymentType;
    data['paymentTerm'] = this.paymentTerm;
    data['discountOnePercentage'] = this.discountOnePercentage;
    data['discountTwoPercentage'] = this.discountTwoPercentage;
    data['extraDiscountPercentage'] = this.extraDiscountPercentage;
    data['tax'] = this.tax;
    data['saleDesc'] = this.saleDesc;
    data['saleStatus'] = this.saleStatus;
    if (this.payments != null) {
      data['payments'] = this.payments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
