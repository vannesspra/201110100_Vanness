import './sale.dart';

class Payment {
  int? paymentId;
  String? paymentCode;
  String? paymentDate;
  String? paymentDesc;
  int? saleId;
  Sale? sale;

  Payment(
      {this.paymentId,
      this.paymentCode,
      this.paymentDate,
      this.paymentDesc,
      this.saleId,
      this.sale});

  Payment.fromJson(Map<String, dynamic> json) {
    paymentId = json['paymentId'];
    paymentCode = json['paymentCode'];
    paymentDate = json['paymentDate'];
    paymentDesc = json['paymentDesc'];
    saleId = json['saleId'];
    sale = json['sale'] != null ? Sale.fromJson(json['sale']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['paymentId'] = this.paymentId;
    data['paymentCode'] = this.paymentCode;
    data['paymentDate'] = this.paymentDate;
    data['paymentDesc'] = this.paymentDesc;
    data['saleId'] = this.saleId;
    if (this.sale != null) {
      data['sale'] = this.sale!.toJson();
    }
    return data;
  }
}
