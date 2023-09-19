class Customer {
  int? customerId;
  String? customerCode;
  String? customerName;
  String? customerAddress;
  String? customerPhoneNumber;
  String? customerEmail;
  String? customerContactPerson;
  String? discountOne;
  String? discountTwo;
  String? paymentType;
  String? paymentTerm;
  String? tax;
  List<ExtraDiscounts>? extraDiscounts;

  Customer(
      {this.customerId,
      this.customerCode,
      this.customerName,
      this.customerAddress,
      this.customerPhoneNumber,
      this.customerEmail,
      this.customerContactPerson,
      this.discountOne,
      this.discountTwo,
      this.paymentType,
      this.paymentTerm,
      this.tax,
      this.extraDiscounts});

  Customer.fromJson(Map<String, dynamic> json) {
    customerId = json['customerId'];
    customerCode = json['customerCode'];
    customerName = json['customerName'];
    customerAddress = json['customerAddress'];
    customerPhoneNumber = json['customerPhoneNumber'];
    customerEmail = json['customerEmail'];
    customerContactPerson = json['customerContactPerson'];
    discountOne = json['discountOne'];
    discountTwo = json['discountTwo'];
    paymentType = json['paymentType'];
    paymentTerm = json['paymentTerm'];
    tax = json['tax'];
    if (json['extraDiscounts'] != null) {
      extraDiscounts = <ExtraDiscounts>[];
      json['extraDiscounts'].forEach((v) {
        extraDiscounts!.add(new ExtraDiscounts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['customerId'] = customerId;
    data['customerCode'] = customerCode;
    data['customerName'] = customerName;
    data['customerAddress'] = customerAddress;
    data['customerPhoneNumber'] = customerPhoneNumber;
    data['customerEmail'] = customerEmail;
    data['customerContactPerson'] = customerContactPerson;
    data['discountOne'] = this.discountOne;
    data['discountTwo'] = this.discountTwo;
    data['paymentType'] = this.paymentType;
    data['paymentTerm'] = this.paymentTerm;
    data['tax'] = this.tax;
    if (this.extraDiscounts != null) {
      data['extraDiscounts'] =
          this.extraDiscounts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ExtraDiscounts {
  int? extraDiscountId;
  int? customerId;
  String? amountPaid;
  String? discount;

  ExtraDiscounts(
      {this.extraDiscountId, this.customerId, this.amountPaid, this.discount});

  ExtraDiscounts.fromJson(Map<String, dynamic> json) {
    extraDiscountId = json['extraDiscountId'];
    customerId = json['customerId'];
    amountPaid = json['amountPaid'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['extraDiscountId'] = this.extraDiscountId;
    data['customerId'] = this.customerId;
    data['amountPaid'] = this.amountPaid;
    data['discount'] = this.discount;
    return data;
  }
}
