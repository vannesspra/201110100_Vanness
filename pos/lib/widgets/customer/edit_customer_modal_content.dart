import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/product.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class EditCustomerModalContent extends StatefulWidget {
  static final GlobalKey<_EditCustomerModalContentState> globalKey =
      GlobalKey();
  int customerId;
  String customerCode;
  String customerName;
  String customerAddress;
  String customerPhoneNumber;
  String customerEmail;
  String customerContactPerson;
  String discountOne;
  String discountTwo;
  String paymentType;
  String paymentTerm;
  String tax;
  List<Map<String, String>> extraDiscounts;
  EditCustomerModalContent({
    Key? key,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhoneNumber,
    required this.customerEmail,
    required this.customerContactPerson,
    required this.discountOne,
    required this.discountTwo,
    required this.paymentType,
    required this.paymentTerm,
    required this.tax,
    required this.extraDiscounts,
  }) : super(key: globalKey);

  @override
  State<EditCustomerModalContent> createState() =>
      _EditCustomerModalContentState();
}

class _EditCustomerModalContentState extends State<EditCustomerModalContent> {
  //Service
  CustomerServices _customerServices = CustomerServices();

  //Text Editing Controller / For Post
  final _customerCodeInputController = TextEditingController();
  final _customerNameInputController = TextEditingController();
  final _customerAddressInputController = TextEditingController();
  final _customerPhoneNumberInputController = TextEditingController();
  final _customerEmailInputController = TextEditingController();
  final _customerContactPersonInputController = TextEditingController();
  final _customerContactPersonNumberInputController = TextEditingController();
  final _discountOneInputController = TextEditingController();
  final _discountTwoInputController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _extraDiscountController = TextEditingController();
  final _paymentTermInputController = TextEditingController();

  late List<Map<String, String>> _extraDiscounts;
  List<Widget> _extraDiscountsWidget = [];

  //Post Response Message
  bool _messageStatusOpen = false;
  bool amountPaidIsNotValid = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  List<String> paymentTypeList = ["Ya", "Tidak"];
  List<String> taxList = ['Ya', "Tidak"];
  bool discountChecked = false;
  int? paymentTypeSelectedIndex;
  int? taxSelectedIndex;

  updateCustomer() async {
    var response = await _customerServices.updateCustomer(
      customerId: widget.customerId,
      customerName: _customerNameInputController.text,
      customerAddress: _customerAddressInputController.text,
      customerPhoneNumber: _customerPhoneNumberInputController.text,
      customerEmail: _customerEmailInputController.text,
      customerContactPerson: _customerContactPersonInputController.text,
      discountOne:
          discountChecked == true ? _discountOneInputController.text : "0",
      discountTwo:
          discountChecked == true ? _discountTwoInputController.text : "0",
      paymentType: paymentTypeSelectedIndex == 1 ? "Kredit" : "Cash",
      paymentTerm: paymentTypeSelectedIndex == 1
          ? _paymentTermInputController.text
          : "0",
      tax: taxSelectedIndex == 0 ? "Ya" : "Tidak",
      extraDiscounts: widget.extraDiscounts,
    );
    print(response.message);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _extraDiscounts = widget.extraDiscounts;
    _customerCodeInputController.text = widget.customerCode;
    _customerNameInputController.text = widget.customerName;
    _customerAddressInputController.text = widget.customerAddress;
    _customerPhoneNumberInputController.text = widget.customerPhoneNumber;
    _customerEmailInputController.text = widget.customerEmail;
    _customerContactPersonInputController.text = widget.customerContactPerson;
    discountChecked =
        widget.discountOne == "0" && widget.discountTwo == "0" ? false : true;
    _discountOneInputController.text = widget.discountOne;
    _discountTwoInputController.text = widget.discountTwo;
    _paymentTermInputController.text =
        widget.paymentType == "Cash" ? "0" : widget.paymentTerm;
    paymentTypeSelectedIndex = widget.paymentType == "Cash" ? 0 : 1;
    taxSelectedIndex = widget.tax == "Ya" ? 0 : 1;
    _extraDiscounts = widget.extraDiscounts;
    print(_extraDiscounts);
    createWidget();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      children: [
        if (_messageStatusOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: InfoBar(
              onClose: () {
                setState(() {
                  _messageStatusOpen = false;
                });
              },
              title: Text(_messageTitle),
              content: Text(_messageContent),
              severity: _messageStatus,
              isLong: true,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Kode"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
                child: TextBox(
              controller: _customerCodeInputController,
              placeholder: "Kode Pelanggan",
              enabled: false,
            ))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Nama"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
                child: TextBox(
              controller: _customerNameInputController,
              placeholder: "Masukkan nama Pelanggan / Customer",
            ))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Alamat"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _customerAddressInputController,
                placeholder: "Masukkan Alamat Pelanggan / Customer",
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Telepon"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _customerPhoneNumberInputController,
                placeholder: "Masukkan telepon Pelanggan / Customer",
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Email"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _customerEmailInputController,
                placeholder: "Masukkan email Pelanggan / Customer",
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Kontak"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _customerContactPersonInputController,
                placeholder: "Masukkan nama kontak Pelanggan / Customer",
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Cash"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Row(
                children: List.generate(2, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: RadioButton(
                      checked: paymentTypeSelectedIndex == index,
                      onChanged: (checked) {
                        if (checked) {
                          setState(() => paymentTypeSelectedIndex = index);
                        }
                      },
                      content: Text(paymentTypeList[index]),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Jatuh Tempo Kredit"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                enabled: paymentTypeSelectedIndex == 1 ? true : false,
                controller: _paymentTermInputController,
                placeholder: "Masukkan jumlah hari",
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("PPN"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Row(
                children: List.generate(2, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: RadioButton(
                      checked: taxSelectedIndex == index,
                      onChanged: (checked) {
                        if (checked) {
                          setState(() => taxSelectedIndex = index);
                        }
                      },
                      content: Text(taxList[index]),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                    checked: discountChecked,
                    onChanged: (value) {
                      setState(() {
                        discountChecked = value!;
                      });
                    }),
                const Text("Diskon"),
              ],
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Diskon 1:"),
                  TextBox(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      // for below version 2 use this
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                    ],
                    enabled: discountChecked,
                    controller: _discountOneInputController,
                    placeholder: "",
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Diskon 2:"),
                  TextBox(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      // for below version 2 use this
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                    ],
                    enabled: discountChecked,
                    controller: _discountTwoInputController,
                    placeholder: "",
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Extra Diskon"),
                    const SizedBox(
                      width: 10,
                    ),
                    Button(
                        child: Icon(FluentIcons.calculator_subtract),
                        onPressed: () {
                          setState(() {
                            _extraDiscounts.removeLast();
                            _extraDiscountsWidget = [];
                            createWidget();
                          });
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    Button(
                        child: Icon(FluentIcons.calculator_addition),
                        onPressed: () {
                          if (amountPaidIsNotValid) {
                          } else {
                            print(_extraDiscounts.length);
                            int _defaultAmountPaid = 0;
                            if (_extraDiscounts.length > 0) {
                              _defaultAmountPaid = int.tryParse(_extraDiscounts[
                                          _extraDiscounts.length - 1]
                                      ['amountPaid']!)! +
                                  10000;
                            } else {
                              _defaultAmountPaid = 100000;
                            }

                            setState(() {
                              _extraDiscounts.add({
                                "amountPaid": _defaultAmountPaid.toString(),
                                "discount": "0"
                              });
                              _extraDiscountsWidget = [];
                              createWidget();
                            });
                          }
                        })
                  ],
                ),
              ],
            )),
        const SizedBox(
          height: 5,
        ),
        Card(
          child: Column(
            children: [
              if (amountPaidIsNotValid)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: InfoBar(
                    onClose: () {
                      setState(() {
                        amountPaidIsNotValid = false;
                      });
                    },
                    title: Text("Kesalahan Nilai Penjualan"),
                    content: Text(
                        "Nilai penjualan tidak boleh lebih kecil dari nilai penjualan sebelumnya!"),
                    severity: InfoBarSeverity.error,
                    isLong: true,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: const Text("Nilai Penjualan"),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: const Text("Diskon (%)"),
                  )
                ],
              ),
              Column(
                children: _extraDiscountsWidget,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void createWidget() {
    bool _amountPaidIsNotValid = false;
    _extraDiscounts.forEach((element) {
      _extraDiscountsWidget.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: TextBox(
                    keyboardType: TextInputType.number,
                    placeholder: element['amountPaid'],
                    enabled: element['edited'] == "true" ? false : true,
                    inputFormatters: <TextInputFormatter>[
                      // for below version 2 use this
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      // for version 2 and greater youcan also use this
                    ],
                    onEditingComplete: () {
                      setState(() {
                        amountPaidIsNotValid = _amountPaidIsNotValid;
                      });
                    },
                    onChanged: (value) {
                      int _defaultAmountPaid = 0;
                      if (_extraDiscounts.length > 1) {
                        _defaultAmountPaid = int.tryParse(
                                _extraDiscounts[_extraDiscounts.length - 2]
                                    ['amountPaid']!)! +
                            10000;
                      } else {
                        _defaultAmountPaid = 100000;
                      }
                      setState(() {
                        if (value == "") {
                          element['amountPaid'] = _defaultAmountPaid.toString();
                          amountPaidIsNotValid = false;
                        } else {
                          if (_extraDiscounts.length > 1) {
                            // print(
                            //     "Nilai Jual Sebelumnya: ${_extraDiscounts[_extraDiscounts.length - 2]['amountPaid']}");
                            if (int.tryParse(value)! <=
                                int.tryParse(
                                    _extraDiscounts[_extraDiscounts.length - 2]
                                        ['amountPaid']!)!) {
                              print("BAH");
                              element['amountPaid'] =
                                  _defaultAmountPaid.toString();
                              amountPaidIsNotValid = true;
                            } else {
                              element['amountPaid'] = value;
                              amountPaidIsNotValid = false;
                            }
                          } else {
                            element['amountPaid'] = value;
                          }
                        }
                      });
                    },
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 50),
                  child: TextBox(
                    keyboardType: TextInputType.number,
                    placeholder: element['discount'],
                    enabled: element['edited'] == "true" ? false : true,
                    inputFormatters: <TextInputFormatter>[
                      // for below version 2 use this
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      // for version 2 and greater youcan also use this
                    ],
                    onChanged: (value) {
                      setState(() {
                        element['discount'] = value;
                        print(_extraDiscountController.text);
                        if (value == "") {
                          print("Buh");
                          element['discount'] = "0";
                        }
                      });
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ));
    });
  }
}
