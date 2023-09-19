import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/models/customer.dart';
import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/models/product.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/models/production.dart';
import 'package:example/routes/forms.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/fabricatingMaterial.dart';
import 'package:example/services/order.dart';
import 'package:example/services/product.dart';
import 'package:example/services/production.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class AddProductionModalContent extends StatefulWidget {
  static final GlobalKey<_AddProductionModalContentState> globalKey =
      GlobalKey();
  AddProductionModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddProductionModalContent> createState() =>
      _AddProductionModalContentState();
}

class _AddProductionModalContentState extends State<AddProductionModalContent> {
  int? _selectedType;
  dynamic _selectKat;
  late Future typeFuture;

  //List
  List<Production>? existingProductions;

  List<Product> products = [];
  List<ProductType> _productTypes = [];
  List<FabricatingMaterial> fabricatingMaterials = [];
  List<Map<String, dynamic>> _selectedMaterials = [];
  List<Widget> _selectedMaterialsWidget = [];
  Widget productWidget = Container();
  Widget fabricatingMaterialWidget = Container();
  List<AutoSuggestBoxItem> product_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> fabricatingMaterial_items = <AutoSuggestBoxItem>[];
  // List<Map<String, String>> _selectedFabricatingMaterials = [];
  // List<Widget> _selectedFabricatingMaterialsWidget = [];
  List<Widget> _widgets = [];

  //Late
  late Future productionFuture;

  //Service
  TypeService _typeService = TypeService();
  ProductService _productService = ProductService();
  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();
  // CustomerServices _customerServices = CustomerServices();
  ProductionService _productionService = ProductionService();

  //Time
  DateTime productionDate = DateTime.now();

  final _productionCodeController = TextEditingController();
  final _productController = TextEditingController();
  final _fabricatingMaterialController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();

  int? _productId = 0;
  int? _fabricatingMaterialId = 0;

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  //Checkbox
  bool checked_order = false;
  bool checked_deliver = false;
  bool checked_done = false;

  //List of Type
  String selectedFilter = "";
  List filterList = ["Produk", "Bahan Setengah Jadi"];

  List<LogicalKeyboardKey> keysPressed = [];

  getTypes() async {
    var response = await _typeService.getTypes();
    _productTypes = response.data;
    print("Get to View: ${_productTypes}");
    for (var element in _productTypes) {
      print(element.typeName);
    }
  }

  getProducts(int typeId) async {
    var response = await _productService.getProduct();
    products = response.data;
    products.forEach((element) {
      if (element.typeId == typeId) {
        product_items.add(AutoSuggestBoxItem(
            value: element.productId, label: element.productName!));
      }
    });
  }

  getFabricatingMaterials() async {
    var response = await _fabricatingMaterialService.getFabricatingMaterials();
    fabricatingMaterials = response.data;
    fabricatingMaterials.forEach((element) {
      fabricatingMaterial_items.add(
        AutoSuggestBoxItem(
          value: element.fabricatingMaterialId,
          label: element.fabricatingMaterialName!,
        ),
      );
    });
  }

  getProductions() async {
    var response = await _productionService.getProduction();
    existingProductions = response.data;
    _productionCodeController.text =
        "HPB${(existingProductions!.length + 1).toString().padLeft(5, "0")}";
  }

  createProduction() async {
    var response = await _productionService.postProduction(
        productionCode: _productionCodeController.text,
        // productId: _productId!,
        // fabricatingMaterialId: _fabricatingMaterialId!,
        // productionQty: _qtyController.text,
        productionDate: productionDate,
        materials: _selectedMaterials,
        productionQty: _qtyController.text,
        productionDesc: _descController.text);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        productionFuture = getProductions();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;
    });
  }

  void _handleKeyPress(RawKeyEvent event) {
    setState(() {
      if (event is RawKeyDownEvent) {
        if (!keysPressed.contains(event.logicalKey)) {
          keysPressed.add(event.logicalKey);
        }
      } else if (event is RawKeyUpEvent) {
        keysPressed.remove(event.logicalKey);
      }
    });
  }

  // void addMaterialViaScan(String materialCode) {
  //   setState(() {
  //     var contain = _selectedProducts
  //         .where((element) => element['materialCode'] == materialCode);
  //     String _price = "";
  //     String _name = "";
  //     String _materialId = "";
  //     materials.forEach((element) {
  //       if (element.materialCode == materialCode) {
  //         _price = element.materialPrice!;
  //         _materialId = element.materialId.toString();
  //         _name = element.materialName!;
  //       }
  //     });

  //     materials.forEach((element) {
  //       if (element.materialCode == materialCode) {
  //         if (contain.isEmpty) {
  //           _selectedProducts.add({
  //             "productId": null,
  //             "materialId": _materialId,
  //             "fabricatingMaterialId": null,
  //             "qty": "1",
  //             "price": _price,
  //             "name": _name,
  //             "label": _name
  //           });
  //         }
  //       }
  //     });

  //     _selectedProductsWidget = [];
  //     createWidget();

  //     _selectedProducts.forEach((element) {
  //       print(element['label']);
  //       print(element['qty']);
  //     });
  //   });
  // }

  void addFabricatingMaterialViaScan(String fabricatingMaterialCode) {
    setState(() {
      // _productId = int.tryParse(value.value.toString());
      var contain = _selectedMaterials.where((element) =>
          element['fabricatingMaterialCode'] == fabricatingMaterialCode);

      String _id = "";
      String _name = "";
      fabricatingMaterials.forEach((element) {
        if (element.fabricatingMaterialCode == fabricatingMaterialCode) {
          _id = element.fabricatingMaterialId.toString();
          _name = element.fabricatingMaterialName!;
        }
      });
      fabricatingMaterials.forEach((element) {
        if (element.fabricatingMaterialCode == fabricatingMaterialCode) {
          if (contain.isEmpty) {
            _selectedMaterials.add({
              "productId": null,
              "fabricatingMaterialId": _id,
              // "qty": '1',
              "label": _name
            });
          }
          _fabricatingMaterialController.text = _name;
        }
      });
      // print(value.label);
      _selectedMaterialsWidget = [];
      createMaterialWidgets();
    });
  }

  void addProductViaScan(String productCode) {
    setState(() {
      // _productId = int.tryParse(value.value.toString());
      var contain = _selectedMaterials
          .where((element) => element['productCode'] == productCode);

      String _id = "";
      String _name = "";
      products.forEach((element) {
        if (element.productCode == productCode) {
          _id = element.productId.toString();
          _name = element.productName!;
        }
      });
      products.forEach((element) {
        if (element.productCode == productCode) {
          if (contain.isEmpty) {
            _selectedMaterials.add({
              "productId": _id,
              "fabricatingMaterialId": null,
              // "qty": '1',
              "label": _name
            });
          }
          _productController.text = _name;
        }
      });
      // print(value.label);
      _selectedMaterialsWidget = [];
      createMaterialWidgets();

      // _productController.text = _name;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getFabricatingMaterials();
    typeFuture = getTypes();
    productionFuture = getProductions();
    print("HARO");
    RawKeyboard.instance.addListener(_handleKeyPress);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyPress);

    super.dispose();
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
                child: FutureBuilder(
              future: productionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      controller: _productionCodeController,
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
            )),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Tanggal"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: DatePicker(
                  selected: productionDate,
                  onChanged: (value) => setState(() => productionDate = value),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Kategori"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: ComboBox(
                  placeholder: const Text("Pilih Kategori"),
                  value: _selectKat,
                  items: filterList.map((e) {
                    return ComboBoxItem(
                      child: Text(e),
                      value: e,
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectKat = value;
                      selectedFilter = value.toString();
                    });
                  }),
            ),
          ],
        ),

        SizedBox(
          height: 10,
        ),
        // SizedBox(
        //   child: () {
        //     createProductWidget();
        //   }(),
        // ),
        // productWidget,
        // SizedBox(
        //   height: 10,
        // ),
        // SizedBox(
        //   child: () {
        //     createFabricatingMaterialWidget();
        //   }(),
        // ),
        // fabricatingMaterialWidget,
        // selectedFilter == "Produk"
        selectedFilter == "Produk"
            ? Container(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: const Text("Jenis Produk"), width: 100),
                        Container(
                          child: const Text(":"),
                          width: 10,
                        ),
                        Expanded(
                          child: FutureBuilder(
                              future: typeFuture,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                Widget child;
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  child = ComboBox(
                                      placeholder:
                                          const Text("Pilih jenis produk"),
                                      value: _selectedType,
                                      items: _productTypes.map((e) {
                                        return ComboBoxItem(
                                          child: Text(e.typeName!),
                                          value: e.typeId,
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          print(int.parse(value.toString()));
                                          _selectedType =
                                              int.parse(value.toString());
                                          print(_selectedType);
                                          print(_selectedType.runtimeType);
                                        });
                                        product_items = [];
                                        getProducts(_selectedType!);
                                      });
                                } else {
                                  child = ComboBox(
                                    placeholder: const ProgressBar(),
                                    value: _selectedType,
                                    items: _productTypes.map((e) {
                                      return ComboBoxItem(
                                        child: Text(e.typeName!),
                                        value: e.typeId,
                                      );
                                    }).toList(),
                                  );
                                }
                                return child;
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(child: const Text("Item Produk"), width: 100),
                        Container(
                          child: const Text(":"),
                          width: 10,
                        ),
                        Expanded(
                          child: AutoSuggestBox(
                            onChanged: (text, reason) {
                              addProductViaScan(text);
                            },
                            onSelected: (value) {
                              print(value.value);
                              setState(() {
                                // _productId = int.tryParse(value.value.toString());
                                var contain = _selectedMaterials.where(
                                    (element) =>
                                        element['productId'] ==
                                        value.value.toString());
                                if (contain.isEmpty) {
                                  _selectedMaterials.add({
                                    "productId": value.value.toString(),
                                    "fabricatingMaterialId": null,
                                    // "qty": '1',
                                    "label": value.label
                                  });
                                }
                                print(value.label);
                                _selectedMaterialsWidget = [];
                                createMaterialWidgets();
                              });
                            },
                            controller: _productController,
                            items: product_items,
                            placeholder: "Nama Item Produk",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : selectedFilter == "Bahan Setengah Jadi"
                ? Container(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: const Text("Bahan\nSetengah Jadi"),
                            width: 100),
                        Container(
                          child: const Text(":"),
                          width: 10,
                        ),
                        Expanded(
                          child: AutoSuggestBox(
                            onChanged: (text, reason) {
                              addFabricatingMaterialViaScan(text);
                            },
                            onSelected: (value) {
                              print(value.value);
                              setState(() {
                                // _fabricatingMaterialId =
                                //     int.tryParse(value.value.toString());
                                var contain = _selectedMaterials.where(
                                    (element) =>
                                        element['fabricatingMaterialId'] ==
                                        value.value.toString());
                                if (contain.isEmpty) {
                                  _selectedMaterials.add({
                                    "productId": null,
                                    "fabricatingMaterialId":
                                        value.value.toString(),
                                    // "qty": '1',
                                    "label": value.label
                                  });
                                }
                                _selectedMaterialsWidget = [];
                                createMaterialWidgets();
                              });
                            },
                            controller: _fabricatingMaterialController,
                            items: fabricatingMaterial_items,
                            placeholder: "Pilih Bahan Setengah Jadi",
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
        //         : const SizedBox(),
        selectedFilter == "Bahan Setengah Jadi" || selectedFilter == "Produk"
            ? SizedBox(
                height: 10,
              )
            : const SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Qty"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                width: 100,
                child: TextBox(
                  controller: _qtyController,
                  placeholder: "Masukkan qty hasil produksi",
                  inputFormatters: <TextInputFormatter>[
                    // for below version 2 use this
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Deskripsi"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _descController,
                placeholder: "Masukkan deskripsi tambahan",
                maxLines: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // void createProductWidget() {
  //   setState(() {
  //     productWidget = Container(
  //         constraints: const BoxConstraints(maxWidth: 250),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text("Produk"),
  //             AutoSuggestBox(
  //               onSelected: (value) {
  //                 print(value.value);
  //                 setState(() {
  //                   var contain = _selectedMaterials.where((element) =>
  //                       element['productId'] == value.value.toString());
  //                   if (contain.isEmpty) {
  //                     _selectedMaterials.add({
  //                       "productId": value.value.toString(),
  //                       "fabricatingMaterialId": null,
  //                       "qty": "1",
  //                       "label": value.label
  //                     });
  //                   }

  //                   _selectedMaterialsWidget = [];
  //                   createMaterialWidgets();
  //                 });
  //               },
  //               controller: _productController,
  //               items: product_items,
  //               placeholder: "Produk",
  //             ),
  //           ],
  //         ));
  //   });
  // }

  // void createFabricatingMaterialWidget() {
  //   setState(() {
  //     fabricatingMaterialWidget = Container(
  //         constraints: const BoxConstraints(maxWidth: 250),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text("Barang Setengah Jadi"),
  //             AutoSuggestBox(
  //               onSelected: (value) {
  //                 print(value.value);
  //                 setState(() {
  //                   var contain = _selectedMaterials.where((element) =>
  //                       element['fabricatingMaterialId'] ==
  //                       value.value.toString());
  //                   if (contain.isEmpty) {
  //                     _selectedMaterials.add({
  //                       "productId": null,
  //                       "fabricatingMaterialId": value.value.toString(),
  //                       "qty": "1",
  //                       "label": value.label
  //                     });
  //                   }

  //                   _selectedMaterialsWidget = [];
  //                   createMaterialWidgets();
  //                 });
  //               },
  //               controller: _fabricatingMaterialController,
  //               items: fabricatingMaterial_items,
  //               placeholder: "Barang Setengah Jadi",
  //             ),
  //           ],
  //         ));
  //   });
  // }

  void createMaterialWidgets() {
    _selectedMaterials.forEach((element) {
      _selectedMaterialsWidget.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: Icon(FluentIcons.remove_from_trash),
                onPressed: () {
                  setState(() {
                    _selectedMaterials
                        .removeWhere((val) => val['id'] == element['id']);
                    _selectedMaterialsWidget = [];
                    createMaterialWidgets();
                    print(_selectedMaterials);
                  });
                }),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0),
              child: Text(element['label']!),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 50),
              child: TextBox(
                keyboardType: TextInputType.number,
                placeholder: element['qty'],
                inputFormatters: <TextInputFormatter>[
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  // for version 2 and greater youcan also use this
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  setState(() {
                    element['qty'] = value;
                    print(_qtyController.text);
                    if (value == "") {
                      print("Buh");
                      element['qty'] = "1";
                    }
                  });
                },
              ),
            )
          ],
        ),
      ));
    });
  }

  // void createWidget() {
  //   selectedFilter == "Produk"
  //       ? _selectedProducts.forEach((element) {
  //           _selectedProductsWidget.add(Padding(
  //             padding: const EdgeInsets.only(bottom: 5.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 IconButton(
  //                     icon: Icon(FluentIcons.remove_from_trash),
  //                     onPressed: () {
  //                       setState(() {
  //                         print("Wah");
  //                         print(_selectedProducts);
  //                         _selectedProducts
  //                             .removeWhere((val) => val['id'] == element['id']);
  //                         _selectedProductsWidget = [];
  //                         createWidget();
  //                         print(_selectedProducts);
  //                       });
  //                     }),
  //                 Padding(
  //                   padding: const EdgeInsets.only(right: 8.0, left: 8.0),
  //                   child: Text(element['label']!),
  //                 ),
  //                 Container(
  //                   constraints: const BoxConstraints(maxWidth: 50),
  //                   child: TextBox(
  //                     keyboardType: TextInputType.number,
  //                     placeholder: element['qty'],
  //                     inputFormatters: <TextInputFormatter>[
  //                       // for below version 2 use this
  //                       FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
  //                       // for version 2 and greater youcan also use this
  //                       FilteringTextInputFormatter.digitsOnly
  //                     ],
  //                     onChanged: (value) {
  //                       setState(() {
  //                         element['qty'] = value;
  //                         print(_qtyController.text);
  //                         if (value == "") {
  //                           print("Buh");
  //                           element['qty'] = "1";
  //                         }
  //                       });

  //                       print(_selectedProducts);
  //                     },
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ));
  //         })
  //       : _selectedFabricatingMaterials.forEach((element) {
  //           _selectedFabricatingMaterialsWidget.add(Padding(
  //             padding: const EdgeInsets.only(bottom: 5.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 IconButton(
  //                     icon: Icon(FluentIcons.remove_from_trash),
  //                     onPressed: () {
  //                       setState(() {
  //                         print("Wah");
  //                         print(_selectedFabricatingMaterials);
  //                         _selectedFabricatingMaterials
  //                             .removeWhere((val) => val['id'] == element['id']);
  //                         _selectedFabricatingMaterialsWidget = [];
  //                         createWidget();
  //                         print(_selectedFabricatingMaterials);
  //                       });
  //                     }),
  //                 Padding(
  //                   padding: const EdgeInsets.only(right: 8.0, left: 8.0),
  //                   child: Text(element['label']!),
  //                 ),
  //                 Container(
  //                   constraints: const BoxConstraints(maxWidth: 50),
  //                   child: TextBox(
  //                     keyboardType: TextInputType.number,
  //                     placeholder: element['qty'],
  //                     inputFormatters: <TextInputFormatter>[
  //                       // for below version 2 use this
  //                       FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
  //                       // for version 2 and greater youcan also use this
  //                       FilteringTextInputFormatter.digitsOnly
  //                     ],
  //                     onChanged: (value) {
  //                       setState(() {
  //                         element['qty'] = value;
  //                         print(_qtyController.text);
  //                         if (value == "") {
  //                           print("Buh");
  //                           element['qty'] = "1";
  //                         }
  //                       });

  //                       print(_selectedFabricatingMaterials);
  //                     },
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ));
  //         });
  // }
}
