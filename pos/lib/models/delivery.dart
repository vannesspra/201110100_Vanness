class Delivery {
  int? deliveryId;
  String? deliveryCode;
  String? deliveryDate;
  String? carPlatNumber;
  String? senderName;
  String? deliveryDesc;

  Delivery(
      {this.deliveryId,
      this.deliveryCode,
      this.deliveryDate,
      this.carPlatNumber,
      this.senderName,
      this.deliveryDesc});

  Delivery.fromJson(Map<String, dynamic> json) {
    deliveryId = json['deliveryId'];
    deliveryCode = json['deliveryCode'];
    deliveryDate = json['deliveryDate'];
    carPlatNumber = json['carPlatNumber'];
    senderName = json['senderName'];
    deliveryDesc = json['deliveryDesc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deliveryId'] = this.deliveryId;
    data['deliveryCode'] = this.deliveryCode;
    data['deliveryDate'] = this.deliveryDate;
    data['carPlatNumber'] = this.carPlatNumber;
    data['senderName'] = this.senderName;
    data['deliveryDesc'] = this.deliveryDesc;
    return data;
  }
}
