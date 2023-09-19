import 'package:example/models/supplier.dart';
import 'package:example/services/supplier.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

import '../../models/fabricatingMaterial.dart';
import '../../models/material.dart';
import '../../models/product.dart';
import '../../services/fabricatingMaterial.dart';
import '../../services/material.dart';
import '../../services/product.dart';

class EditSupplierModalContent extends StatefulWidget {
  static final GlobalKey<_EditSupplierModalContentState> globalKey =
      GlobalKey();
  int supplierId;
  String supplierCode;
  String supplierName;
  String supplierAddress;
  String supplierPhoneNumber;
  String supplierEmail;
  String supplierContactPerson;
  String paymentType;
  String paymentTerm;
  String supplierTax;
  List<Map<String, dynamic>> supplierProducts;
  List<Map<String, dynamic>> supplierMaterials;
  List<Map<String, dynamic>> supplierFabricatingMaterials;

  EditSupplierModalContent(
      {Key? key,
      required this.supplierId,
      required this.supplierCode,
      required this.supplierName,
      required this.supplierAddress,
      required this.supplierPhoneNumber,
      required this.supplierEmail,
      required this.supplierContactPerson,
      required this.paymentType,
      required this.paymentTerm,
      required this.supplierTax,
      required this.supplierProducts,
      required this.supplierMaterials,
      required this.supplierFabricatingMaterials})
      : super(key: globalKey);

  @override
  State<EditSupplierModalContent> createState() =>
      _EditSupplierModalContentState();
}

class _EditSupplierModalContentState extends State<EditSupplierModalContent> {
  //Service

  SupplierServices _supplierServices = SupplierServices();
  ProductService _productService = ProductService();
  MaterialService _materialService = MaterialService();
  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();

  List<Product> _products = [];
  List<Material> _materials = [];
  List<FabricatingMaterial> _fabricatingMaterials = [];
  int _selectedItem = 0;

  int currentIndex = 0;
  List<Tab> tabs = [];

  //List
  // List paymentType = ["Tunai", "Kredit"];
  // List taxType = ["Ya", "Tidak"];

  //Text Editing Controller / For Post
  final _supplierCodeInputController = TextEditingController();
  final _supplierNameInputController = TextEditingController();
  final _supplierAddressInputController = TextEditingController();
  final _supplierPhoneNumberInputController = TextEditingController();
  final _supplierEmailInputController = TextEditingController();
  final _supplierContactPersonInputController = TextEditingController();
  final _supplierContactPersonNumberInputController = TextEditingController();
  final _paymentTermInputController = TextEditingController();
  // String _selectedPaymentType = "";
  // String _selectedTax = "";
  List<Widget> _supplierProductsWidget = [];
  List<Widget> _supplierMaterialsWidget = [];
  List<Widget> _supplierFabricatingMaterialsWidget = [];

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  getProducts() async {
    var response = await _productService.getProduct();
    setState(() {
      _products = response.data;
      _products.forEach((element) {});
    });
    createSupplierProductsWidget();
  }

  getMaterials() async {
    var response = await _materialService.getMaterials();
    setState(() {
      _materials = response.data;
    });
    createSupplierMaterialsWidget();
  }

  getFabricatingMaterials() async {
    var response = await _fabricatingMaterialService.getFabricatingMaterials();

    setState(() {
      _fabricatingMaterials = response.data;
    });
    createSupplierFabricatingMaterialsWidget();
  }

  updateSupplier() async {
    var response = await _supplierServices.updateSupplier(
        supplierId: widget.supplierId,
        supplierName: _supplierNameInputController.text,
        supplierAddress: _supplierAddressInputController.text,
        supplierPhoneNumber: _supplierPhoneNumberInputController.text,
        supplierEmail: _supplierEmailInputController.text,
        supplierContactPerson: _supplierContactPersonInputController.text,
        paymentTerm: paymentTypeSelectedIndex == 1
            ? _paymentTermInputController.text
            : "0",
        paymentType: paymentTypeSelectedIndex == 1 ? "Kredit" : "Cash",
        supplierTax: taxSelectedIndex == 0 ? "Ya" : "Tidak",
        supplierProducts: widget.supplierProducts,
        supplierMaterials: widget.supplierMaterials,
        supplierFabricatingMaterials: widget.supplierFabricatingMaterials);

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

    _supplierCodeInputController.text = widget.supplierCode;
    _supplierNameInputController.text = widget.supplierName;
    _supplierAddressInputController.text = widget.supplierAddress;
    _supplierPhoneNumberInputController.text = widget.supplierPhoneNumber;
    _supplierEmailInputController.text = widget.supplierEmail;
    _supplierContactPersonInputController.text = widget.supplierContactPerson;
    _paymentTermInputController.text =
        widget.paymentType == "Cash" ? "-" : widget.paymentTerm;
    paymentTypeSelectedIndex = widget.paymentType == "Cash" ? 0 : 1;
    taxSelectedIndex = widget.supplierTax == "Ya" ? 0 : 1;
    getProducts();
    getMaterials();
    getFabricatingMaterials();
  }

  List<String> paymentTypeList = ["Ya", "Tidak"];
  List<String> supplierTaxList = ["Ya", "Tidak"];
  int? paymentTypeSelectedIndex;
  int? taxSelectedIndex;

  bool checked = false;

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
                child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: TextBox(
                controller: _supplierCodeInputController,
                placeholder: "Kode Pemasok",
                enabled: false,
              ),
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
                controller: _supplierNameInputController,
                placeholder: "Masukkan nama supplier CV/PT",
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
            Container(child: const Text("Alamat"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _supplierAddressInputController,
                placeholder: "Masukkan Alamat Supplier",
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
                controller: _supplierPhoneNumberInputController,
                placeholder: "Masukkan telepon supplier",
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
                controller: _supplierEmailInputController,
                placeholder: "Masukkan email supplier",
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
                controller: _supplierContactPersonInputController,
                placeholder: "Masukkan nama kontak supplier",
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
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: TextBox(
                  inputFormatters: <TextInputFormatter>[
                    // for below version 2 use this
                    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    // for version 2 and greater youcan also use this
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  enabled: paymentTypeSelectedIndex == 1 ? true : false,
                  controller: _paymentTermInputController,
                  placeholder: "Masukkan jumlah hari",
                ),
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
                      content: Text(supplierTaxList[index]),
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
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: 10 / 8,
            child: TabView(
              tabs: <Tab>[
                Tab(
                    text: Text("Item Produk"),
                    body: Card(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("Tambah"),
                                const SizedBox(
                                  width: 10,
                                ),
                                Button(
                                    child:
                                        Icon(FluentIcons.calculator_addition),
                                    onPressed: () {
                                      setState(() {
                                        widget.supplierProducts.add({
                                          "productId": null,
                                          "materialId": null,
                                          "fabricatingMaterialId": null,
                                          "label": "Pilih barang"
                                        });
                                        print(widget.supplierProducts);
                                        _supplierProductsWidget = [];
                                        createSupplierProductsWidget();
                                      });
                                    })
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: _supplierProductsWidget,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                Tab(
                    text: Text("Bahan Baku"),
                    body: Card(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("Tambah"),
                                const SizedBox(
                                  width: 10,
                                ),
                                Button(
                                    child:
                                        Icon(FluentIcons.calculator_addition),
                                    onPressed: () {
                                      setState(() {
                                        widget.supplierMaterials.add({
                                          "productId": null,
                                          "materialId": null,
                                          "fabricatingMaterialId": null,
                                          "label": "Pilih barang"
                                        });
                                        _supplierMaterialsWidget = [];
                                        createSupplierMaterialsWidget();
                                      });
                                    })
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: _supplierMaterialsWidget,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                Tab(
                    text: Text("Bahan Setengah Jadi"),
                    body: Card(
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("Tambah"),
                                const SizedBox(
                                  width: 10,
                                ),
                                Button(
                                    child:
                                        Icon(FluentIcons.calculator_addition),
                                    onPressed: () {
                                      setState(() {
                                        widget.supplierFabricatingMaterials
                                            .add({
                                          "productId": null,
                                          "materialId": null,
                                          "fabricatingMaterialId": null,
                                          "label": "Pilih barang"
                                        });
                                        _supplierFabricatingMaterialsWidget =
                                            [];
                                        createSupplierFabricatingMaterialsWidget();
                                      });
                                    })
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SingleChildScrollView(
                              child: Column(
                                children: _supplierFabricatingMaterialsWidget,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
              currentIndex: currentIndex,
              onChanged: (index) => setState(() => currentIndex = index),
              tabWidthBehavior: TabWidthBehavior.sizeToContent,
              closeButtonVisibility: CloseButtonVisibilityMode.never,
              showScrollButtons: true,
              wheelScroll: false,
            ),
          ),
        )
      ],
    );
  }

  void createSupplierProductsWidget() {
    widget.supplierProducts.forEach((element) {
      int _selectedItem = 0;

      _supplierProductsWidget.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ComboBox(
                      placeholder: Text(element['label']),
                      value: element['productId'],
                      items: _products.map((e) {
                        return ComboBoxItem(
                          child: Text(e.productName!),
                          value: e.productId,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          print(value);

                          if (widget.supplierProducts
                              .any((item) => item['productId'] == value)) {
                          } else {
                            element['productId'] = int.parse(value.toString());
                            _supplierProductsWidget = [];
                            createSupplierProductsWidget();
                          }
                        });
                      }),
                ),
                Button(
                    child: Icon(FluentIcons.recycle_bin),
                    onPressed: () {
                      setState(() {
                        print("Wah");
                        widget.supplierProducts.removeWhere(
                            (val) => val['productId'] == element['productId']);
                        _supplierProductsWidget = [];
                        createSupplierProductsWidget();
                      });
                    })
              ],
            ),
          ],
        ),
      ));
    });
  }

  void createSupplierMaterialsWidget() {
    widget.supplierMaterials.forEach((element) {
      int _selectedItem = 0;
      _supplierMaterialsWidget.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ComboBox(
                      placeholder: Text(element['label']),
                      value: element['materialId'],
                      items: _materials.map((e) {
                        return ComboBoxItem(
                          child: Text(e.materialName!),
                          value: e.materialId,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          print(value);

                          if (widget.supplierMaterials
                              .any((item) => item['materialId'] == value)) {
                          } else {
                            element['materialId'] = int.parse(value.toString());
                            _supplierMaterialsWidget = [];
                            createSupplierMaterialsWidget();
                          }
                        });
                      }),
                ),
                Button(
                    child: Icon(FluentIcons.recycle_bin),
                    onPressed: () {
                      setState(() {
                        print("Wah");
                        widget.supplierMaterials.removeWhere((val) =>
                            val['materialId'] == element['materialId']);
                        _supplierMaterialsWidget = [];
                        createSupplierMaterialsWidget();
                      });
                    })
              ],
            ),
          ],
        ),
      ));
    });
  }

  void createSupplierFabricatingMaterialsWidget() {
    widget.supplierFabricatingMaterials.forEach((element) {
      int _selectedItem = 0;
      _supplierFabricatingMaterialsWidget.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: ComboBox(
                      placeholder: Text(element['label']),
                      value: element['fabricatingMaterialId'],
                      items: _fabricatingMaterials.map((e) {
                        return ComboBoxItem(
                          child: Text(e.fabricatingMaterialName!),
                          value: e.fabricatingMaterialId,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          print(value);

                          if (widget.supplierFabricatingMaterials.any((item) =>
                              item['fabricatingMaterialId'] == value)) {
                          } else {
                            element['fabricatingMaterialId'] =
                                int.parse(value.toString());
                            _supplierFabricatingMaterialsWidget = [];
                            createSupplierFabricatingMaterialsWidget();
                          }
                        });
                      }),
                ),
                Button(
                    child: Icon(FluentIcons.recycle_bin),
                    onPressed: () {
                      setState(() {
                        print("Wah");
                        widget.supplierFabricatingMaterials.removeWhere((val) =>
                            val['fabricatingMaterialId'] ==
                            element['fabricatingMaterialId']);
                        _supplierFabricatingMaterialsWidget = [];
                        createSupplierFabricatingMaterialsWidget();
                      });
                    })
              ],
            ),
          ],
        ),
      ));
    });
  }
}
