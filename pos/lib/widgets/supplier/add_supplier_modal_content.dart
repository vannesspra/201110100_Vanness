import 'dart:math';

import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/models/material.dart';
import 'package:example/models/product.dart';
import 'package:example/models/supplier.dart';
import 'package:example/services/fabricatingMaterial.dart';
import 'package:example/services/material.dart';
import 'package:example/services/product.dart';
import 'package:example/services/supplier.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:tab_container/tab_container.dart';

class AddSupplierModalContent extends StatefulWidget {
  static final GlobalKey<_AddSupplierModalContentState> globalKey = GlobalKey();
  AddSupplierModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddSupplierModalContent> createState() =>
      _AddSupplierModalContentState();
}

class _AddSupplierModalContentState extends State<AddSupplierModalContent> {
  //List
  // List paymentType = ["Tunai", "Kredit"];
  // List taxType = ["Ya", "Tidak"];

  //Service

  SupplierServices _supplierServices = SupplierServices();
  ProductService _productService = ProductService();
  MaterialService _materialService = MaterialService();
  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();

  List<Supplier>? existingSuppliers;
  List<Product> _products = [];
  List<Material> _materials = [];
  List<FabricatingMaterial> _fabricatingMaterials = [];
  List<Map<String, dynamic>> _availItems = [];
  int _selectedItem = 0;

  //Future
  late Future supplierFuture;

  int currentIndex = 0;
  List<Tab> tabs = [];

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

  List<Map<String, dynamic>> _supplierProducts = [];
  List<Map<String, dynamic>> _supplierMaterials = [];
  List<Map<String, dynamic>> _supplierFabricatingMaterials = [];
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
      _products.forEach((element) {
        _availItems.add({
          "id": element.productId,
          "label": "${element.productName} (${element.color!.colorName})"
        });
      });
    });
  }

  getMaterials() async {
    var response = await _materialService.getMaterials();
    setState(() {
      _materials = response.data;
      _materials.forEach((element) {
        _availItems
            .add({"id": element.materialId, "label": element.materialName});
      });
    });
  }

  getFabricatingMaterials() async {
    var response = await _fabricatingMaterialService.getFabricatingMaterials();

    setState(() {
      _fabricatingMaterials = response.data;

      _fabricatingMaterials.forEach((element) {
        _availItems.add({
          "id": element.fabricatingMaterialId,
          "label": element.fabricatingMaterialName
        });
      });
    });
  }

  getSuppliers() async {
    var response = await _supplierServices.getSupplier();
    existingSuppliers = response.data;
    _supplierCodeInputController.text =
        "SP${(existingSuppliers!.length + 1).toString().padLeft(5, "0")}";
  }

  postSupplier() async {
    var response = await _supplierServices.postSupplier(
        supplierCode: _supplierCodeInputController.text,
        supplierName: _supplierNameInputController.text,
        supplierAddress: _supplierAddressInputController.text,
        supplierPhoneNumber: _supplierPhoneNumberInputController.text,
        supplierEmail: _supplierEmailInputController.text,
        supplierContactPerson: _supplierContactPersonInputController.text,
        paymentTerm: _paymentTermInputController.text,
        paymentType: paymentTypeList[paymentTypeSelectedIndex] == "Ya"
            ? "Cash"
            : "Kredit",
        supplierTax: supplierTaxList[taxSelectedIndex],
        supplierProducts: _supplierProducts,
        supplierMaterials: _supplierMaterials,
        supplierFabricatingMaterials: _supplierFabricatingMaterials);
    print(response.message);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        supplierFuture = getSuppliers();
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
    getProducts();
    getMaterials();
    getFabricatingMaterials();

    supplierFuture = getSuppliers();
  }

  List<String> paymentTypeList = ["Ya", "Tidak"];
  List<String> supplierTaxList = ["Ya", "Tidak"];
  int paymentTypeSelectedIndex = 0;
  int taxSelectedIndex = 0;

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
                    child: FutureBuilder(
                      future: supplierFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: TextBox(
                              controller: _supplierCodeInputController,
                              enabled: false,
                            ),
                            width: 200,
                          );
                        } else {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: const ProgressBar(),
                            width: 200,
                          );
                        }
                      },
                    )))
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
                                        _supplierProducts.add({
                                          "productId": null,
                                          "materialId": null,
                                          "fabricatingMaterialId": null,
                                          "label": "Pilih barang"
                                        });
                                        print(_supplierProducts);
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
                                        _supplierMaterials.add({
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
                                        _supplierFabricatingMaterials.add({
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
    _supplierProducts.forEach((element) {
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

                          if (_supplierProducts
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
                        _supplierProducts.removeWhere(
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
    _supplierMaterials.forEach((element) {
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

                          if (_supplierMaterials
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
                        _supplierMaterials.removeWhere((val) =>
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
    _supplierFabricatingMaterials.forEach((element) {
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

                          if (_supplierFabricatingMaterials.any((item) =>
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
                        _supplierFabricatingMaterials.removeWhere((val) =>
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
