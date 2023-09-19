class Profile {
  int? companyId;
  String? companyName;
  String? companyAddress;
  String? companyPhoneNumber;
  String? companyWebsite;
  String? companyEmail;
  String? companyContactPerson;
  String? companyContactPersonNumber;

  Profile(
      {this.companyId,
      this.companyName,
      this.companyAddress,
      this.companyPhoneNumber,
      this.companyWebsite,
      this.companyEmail,
      this.companyContactPerson,
      this.companyContactPersonNumber});

  Profile.fromJson(Map<String, dynamic> json) {
    companyId = json['companyId'];
    companyName = json['companyName'];
    companyAddress = json['companyAddress'];
    companyPhoneNumber = json['companyPhoneNumber'];
    companyWebsite = json['companyWebsite'];
    companyEmail = json['companyEmail'];
    companyContactPerson = json['companyContactPerson'];
    companyContactPersonNumber = json['companyContactPersonNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['companyId'] = this.companyId;
    data['companyName'] = this.companyName;
    data['companyAddress'] = this.companyAddress;
    data['companyPhoneNumber'] = this.companyPhoneNumber;
    data['companyWebsite'] = this.companyWebsite;
    data['companyEmail'] = this.companyEmail;
    data['companyContactPerson'] = this.companyContactPerson;
    data['companyContactPersonNumber'] = this.companyContactPersonNumber;
    return data;
  }
}
