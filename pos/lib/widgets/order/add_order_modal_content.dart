import 'dart:async';
import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:example/models/color.dart';
import 'package:example/models/customer.dart';
import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/models/material.dart';
import 'package:example/models/order.dart';
import 'package:example/models/product.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/routes/forms.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/fabricatingMaterial.dart';
import 'package:example/services/material.dart';
import 'package:example/services/order.dart';
import 'package:example/services/product.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class AddOrderModalContent extends StatefulWidget {
  static final GlobalKey<_AddOrderModalContentState> globalKey = GlobalKey();
  AddOrderModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddOrderModalContent> createState() => _AddOrderModalContentState();
}

class _AddOrderModalContentState extends State<AddOrderModalContent> {
  //List
  List<Product> products = [];
  List<Material> materials = [];
  List<FabricatingMaterial> fabricatingMaterials = [];
  List<Map<String, dynamic>> _selectedProducts = [];
  List<Widget> _selectedProductsWidget = [];
  List<Customer> customers = [];
  List<AutoSuggestBoxItem> product_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> material_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> fabricatingMaterial_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> customer_items = <AutoSuggestBoxItem>[];

  List<Order>? existingOrders;

  //Late
  late Future ordersFuture;

  //Service
  ProductService _productService = ProductService();
  MaterialService _materialService = MaterialService();
  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();
  CustomerServices _customerServices = CustomerServices();
  OrderService _orderService = OrderService();

  //Time
  DateTime requestedDeliveryDate = DateTime.now();
  DateTime orderDate = DateTime.now();
  final now = DateTime.now();

  final _orderCodeController = TextEditingController();
  final _productController = TextEditingController();
  final _materialController = TextEditingController();
  final _fabricatingMaterialController = TextEditingController();
  final _customerController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();

  int? _customerId = 0;

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  //Checkbox
  bool checked_order = false;
  bool checked_deliver = false;
  bool checked_done = false;

  List<LogicalKeyboardKey> keysPressed = [];

  getProducts() async {
    var response = await _productService.getProduct();
    products = response.data;
    products.forEach((element) {
      product_items.add(AutoSuggestBoxItem(
          value: element.productId, label: element.productName!));
    });
  }

  getMaterials() async {
    var response = await _materialService.getMaterials();
    materials = response.data;
    materials.forEach((element) {
      material_items.add(AutoSuggestBoxItem(
          value: element.materialId, label: element.materialName!));
    });
  }

  getFabricatingMaterials() async {
    var response = await _fabricatingMaterialService.getFabricatingMaterials();
    fabricatingMaterials = response.data;
    fabricatingMaterials.forEach((element) {
      fabricatingMaterial_items.add(AutoSuggestBoxItem(
          value: element.fabricatingMaterialId,
          label: element.fabricatingMaterialName!));
    });
  }

  getCustomers() async {
    var response = await _customerServices.getCustomer();
    customers = response.data;
    print(customers);
    customers.forEach((element) {
      customer_items.add(AutoSuggestBoxItem(
          value: element.customerId, label: element.customerName!));
    });
  }

  createOrder() async {
    var response = await _orderService.postOrder(
        orderCode: _orderCodeController.text,
        products: _selectedProducts,
        customerId: _customerId,
        requestedDeliveryDate: requestedDeliveryDate,
        orderDate: orderDate,
        orderDesc: _descController.text);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        ordersFuture = getOrders();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;
    });
  }

  getOrders() async {
    var response = await _orderService.getOrdersGrouped();
    existingOrders = response.data;
    _orderCodeController.text = "SO/ACC/${(formatDate(now, [
          mm,
          yy
        ]).toString())}/${(existingOrders!.length + 1).toString().padLeft(5, "0")}";
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

  void addMaterialViaScan(String materialCode) {
    setState(() {
      var contain = _selectedProducts
          .where((element) => element['materialCode'] == materialCode);
      String _price = "";
      String _name = "";
      String _materialId = "";
      materials.forEach((element) {
        if (element.materialCode == materialCode) {
          _price = element.materialPrice!;
          _materialId = element.materialId.toString();
          _name = element.materialName!;
        }
      });

      materials.forEach((element) {
        if (element.materialCode == materialCode) {
          if (contain.isEmpty) {
            _selectedProducts.add({
              "productId": null,
              "materialId": _materialId,
              "fabricatingMaterialId": null,
              "qty": "1",
              "price": _price,
              "name": _name,
              "label": _name
            });
          }
        }
      });

      _selectedProductsWidget = [];
      createWidget();

      _selectedProducts.forEach((element) {
        print(element['label']);
        print(element['qty']);
      });
    });
  }

  void addFabricatingMaterialViaScan(String fabricatingMaterialCode) {
    setState(() {
      var contain = _selectedProducts.where((element) =>
          element['fabricatingMaterialCode'] == fabricatingMaterialCode);
      String _price = "";
      String _name = "";
      String _fabricatingMaterialId = "";
      fabricatingMaterials.forEach((element) {
        if (element.fabricatingMaterialCode == fabricatingMaterialCode) {
          _price = element.fabricatingMaterialPrice!;
          _fabricatingMaterialId = element.fabricatingMaterialId.toString();
          _name = element.fabricatingMaterialName!;
        }
      });

      fabricatingMaterials.forEach((element) {
        if (element.fabricatingMaterialCode == fabricatingMaterialCode) {
          if (contain.isEmpty) {
            _selectedProducts.add({
              "productId": null,
              "materialId": null,
              "fabricatingMaterialId": _fabricatingMaterialId,
              "qty": "1",
              "price": _price,
              "name": _name,
              "label": _name
            });
          }
        }
      });

      _selectedProductsWidget = [];
      createWidget();

      _selectedProducts.forEach((element) {
        print(element['label']);
        print(element['qty']);
      });
    });
  }

  void addProductViaScan(String productCode) {
    setState(() {
      var contain = _selectedProducts
          .where((element) => element['productCode'] == productCode);
      String _price = "";
      String _name = "";
      String _productId = "";
      products.forEach((element) {
        if (element.productCode == productCode) {
          _price = element.productPrice!;
          _productId = element.productId.toString();
          _name = element.productName!;
        }
      });

      products.forEach((element) {
        if (element.productCode == productCode) {
          if (contain.isEmpty) {
            _selectedProducts.add({
              "productId": _productId,
              "materialId": null,
              "fabricatingMaterialId": null,
              "qty": "1",
              "price": _price,
              "name": _name,
              "label": _name
            });
          }
        }
      });

      _selectedProductsWidget = [];
      createWidget();

      _selectedProducts.forEach((element) {
        print(element['label']);
        print(element['qty']);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProducts();
    getMaterials();
    getFabricatingMaterials();
    getCustomers();
    ordersFuture = getOrders();
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
              future: ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      controller: _orderCodeController,
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
                selected: orderDate,
                onChanged: (value) => setState(() => orderDate = value),
              ),
            )),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                child: const Text("Tanggal Permintaan Pengiriman"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
                child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: DatePicker(
                selected: requestedDeliveryDate,
                onChanged: (value) =>
                    setState(() => requestedDeliveryDate = value),
              ),
            )),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Pelanggan/Customer"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: AutoSuggestBox(
                onSelected: (value) {
                  setState(() {
                    print("Customer Added");
                    _customerId = int.tryParse(value.value.toString());
                  });
                },
                controller: _customerController,
                placeholder: "Pelanggan",
                items: customer_items,
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
            Container(child: const Text("Bahan Baku"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: AutoSuggestBox(
                onChanged: (text, reason) {
                  addMaterialViaScan(text);
                },
                onSelected: (value) {
                  print(value.value);
                  setState(() {
                    var contain = _selectedProducts.where((element) =>
                        element['materialId'] == value.value.toString());
                    String _price = "";
                    String _name = "";
                    materials.forEach((element) {
                      if (element.materialId ==
                          int.parse(value.value.toString())) {
                        _price = element.materialPrice!;
                        _name = element.materialName!;
                      }
                    });
                    if (contain.isEmpty) {
                      print("Valid");
                      _selectedProducts.add({
                        "productId": null,
                        "materialId": value.value.toString(),
                        "fabricatingMaterialId": null,
                        "qty": "1",
                        "price": _price,
                        "name": _name,
                        "label": value.label
                      });
                    }
                    print(_selectedProducts);

                    _selectedProductsWidget = [];
                    createWidget();

                    _selectedProducts.forEach((element) {
                      print(element['label']);
                      print(element['qty']);
                    });
                  });
                },
                controller: _materialController,
                items: material_items,
                placeholder: "Bahan Baku",
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
            Container(child: const Text("Bahan\nSetengah Jadi"), width: 100),
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
                    var contain = _selectedProducts.where((element) =>
                        element['fabricatingMaterialId'] ==
                        value.value.toString());
                    String _price = "";
                    String _name = "";
                    fabricatingMaterials.forEach((element) {
                      if (element.fabricatingMaterialId ==
                          int.parse(value.value.toString())) {
                        _price = element.fabricatingMaterialPrice!;
                        _name = element.fabricatingMaterialName!;
                      }
                    });
                    if (contain.isEmpty) {
                      print("Valid");
                      _selectedProducts.add({
                        "productId": null,
                        "materialId": null,
                        "fabricatingMaterialId": value.value.toString(),
                        "qty": "1",
                        "price": _price,
                        "name": _name,
                        "label": value.label
                      });
                    }
                    print(_selectedProducts);

                    _selectedProductsWidget = [];
                    createWidget();

                    _selectedProducts.forEach((element) {
                      print(element['label']);
                      print(element['qty']);
                    });
                  });
                },
                controller: _fabricatingMaterialController,
                items: fabricatingMaterial_items,
                placeholder: "Barang 1/2 Jadi",
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
            Container(child: const Text("Item Produk"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: AutoSuggestBox(
                onChanged: (text, reason) {
                  print("SCANNED: ${text}");
                  addProductViaScan(text);
                },
                onSelected: (value) {
                  print(value.value);
                  setState(() {
                    var contain = _selectedProducts.where((element) =>
                        element['productId'] == value.value.toString());
                    String _price = "";
                    String _name = "";
                    products.forEach((element) {
                      if (element.productId ==
                          int.parse(value.value.toString())) {
                        _price = element.productPrice!;
                        _name = element.productName!;
                      }
                    });
                    if (contain.isEmpty) {
                      print("Valid");
                      _selectedProducts.add({
                        "productId": value.value.toString(),
                        "materialId": null,
                        "fabricatingMaterialId": null,
                        "qty": "1",
                        "price": _price,
                        "name": _name,
                        "label": value.label
                      });
                    }
                    print(_selectedProducts);

                    _selectedProductsWidget = [];
                    createWidget();

                    _selectedProducts.forEach((element) {
                      print(element['label']);
                      print(element['qty']);
                    });
                  });
                },
                controller: _productController,
                items: product_items,
                placeholder: "Produk",
              ),
            ),
          ],
        ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Container(
        //         constraints: const BoxConstraints(maxWidth: 250),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             const Text("Pelanggan"),
        //             AutoSuggestBox(
        //               onSelected: (value) {
        //                 setState(() {
        //                   print("Customer Added");
        //                   _customerId = int.tryParse(value.value.toString());
        //                 });
        //               },
        //               controller: _customerController,
        //               placeholder: "Pelanggan",
        //               items: customer_items,
        //             ),
        //           ],
        //         )),
        //     SizedBox(
        //       height: 10,
        //     ),
        //     Container(
        //         constraints: const BoxConstraints(maxWidth: 250),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             const Text("Produk"),
        //             AutoSuggestBox(
        //               onSelected: (value) {
        //                 print(value.value);
        //                 setState(() {
        //                   var contain = _selectedProducts.where((element) =>
        //                       element['productId'] == value.value.toString());
        //                   String _price = "";
        //                   String _name = "";
        //                   products.forEach((element) {
        //                     if (element.productId ==
        //                         int.parse(value.value.toString())) {
        //                       _price = element.productPrice!;
        //                       _name = element.productName!;
        //                     }
        //                   });
        //                   if (contain.isEmpty) {
        //                     print("Valid");
        //                     _selectedProducts.add({
        //                       "productId": value.value.toString(),
        //                       "materialId": null,
        //                       "fabricatingMaterialId": null,
        //                       "qty": "1",
        //                       "price": _price,
        //                       "name": _name,
        //                       "label": value.label
        //                     });
        //                   }
        //                   print(_selectedProducts);

        //                   _selectedProductsWidget = [];
        //                   createWidget();

        //                   _selectedProducts.forEach((element) {
        //                     print(element['label']);
        //                     print(element['qty']);
        //                   });
        //                 });
        //               },
        //               controller: _productController,
        //               items: product_items,
        //               placeholder: "Produk",
        //             ),
        //           ],
        //         )),
        //     const SizedBox(
        //       height: 10,
        //     ),
        //     Container(
        //         constraints: const BoxConstraints(maxWidth: 250),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             const Text("Bahan Baku"),
        //             AutoSuggestBox(
        //               onSelected: (value) {
        //                 print(value.value);
        //                 setState(() {
        //                   var contain = _selectedProducts.where((element) =>
        //                       element['materialId'] == value.value.toString());
        //                   String _price = "";
        //                   String _name = "";
        //                   materials.forEach((element) {
        //                     if (element.materialId ==
        //                         int.parse(value.value.toString())) {
        //                       _price = element.materialPrice!;
        //                       _name = element.materialName!;
        //                     }
        //                   });
        //                   if (contain.isEmpty) {
        //                     print("Valid");
        //                     _selectedProducts.add({
        //                       "productId": null,
        //                       "materialId": value.value.toString(),
        //                       "fabricatingMaterialId": null,
        //                       "qty": "1",
        //                       "price": _price,
        //                       "name": _name,
        //                       "label": value.label
        //                     });
        //                   }
        //                   print(_selectedProducts);

        //                   _selectedProductsWidget = [];
        //                   createWidget();

        //                   _selectedProducts.forEach((element) {
        //                     print(element['label']);
        //                     print(element['qty']);
        //                   });
        //                 });
        //               },
        //               controller: _materialController,
        //               items: material_items,
        //               placeholder: "Bahan Baku",
        //             ),
        //           ],
        //         )),
        //     const SizedBox(
        //       height: 10,
        //     ),
        //     Container(
        //         constraints: const BoxConstraints(maxWidth: 250),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             const Text("Barang 1/2 Jadi"),
        //             AutoSuggestBox(
        //               onSelected: (value) {
        //                 print(value.value);
        //                 setState(() {
        //                   var contain = _selectedProducts.where((element) =>
        //                       element['fabricatingMaterialId'] ==
        //                       value.value.toString());
        //                   String _price = "";
        //                   String _name = "";
        //                   fabricatingMaterials.forEach((element) {
        //                     if (element.fabricatingMaterialId ==
        //                         int.parse(value.value.toString())) {
        //                       _price = element.fabricatingMaterialPrice!;
        //                       _name = element.fabricatingMaterialName!;
        //                     }
        //                   });
        //                   if (contain.isEmpty) {
        //                     print("Valid");
        //                     _selectedProducts.add({
        //                       "productId": null,
        //                       "materialId": null,
        //                       "fabricatingMaterialId": value.value.toString(),
        //                       "qty": "1",
        //                       "price": _price,
        //                       "name": _name,
        //                       "label": value.label
        //                     });
        //                   }
        //                   print(_selectedProducts);

        //                   _selectedProductsWidget = [];
        //                   createWidget();

        //                   _selectedProducts.forEach((element) {
        //                     print(element['label']);
        //                     print(element['qty']);
        //                   });
        //                 });
        //               },
        //               controller: _fabricatingMaterialController,
        //               items: fabricatingMaterial_items,
        //               placeholder: "Barang 1/2 Jadi",
        //             ),
        //           ],
        //         )),
        //     SizedBox(
        //       height: 5,
        //     ),
        //     Column(
        //       children: _selectedProductsWidget,
        //     ),
        //     SizedBox(
        //       height: 10,
        //     ),
        //   ],
        // ),
        SizedBox(
          height: 10,
        ),
        Column(
          children: _selectedProductsWidget,
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
                placeholder: "Keterangan",
                maxLines: 2,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  void createWidget() {
    _selectedProducts.forEach((element) {
      _selectedProductsWidget.add(Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                icon: Icon(FluentIcons.remove_from_trash),
                onPressed: () {
                  setState(() {
                    print("Wah");
                    print(_selectedProducts);
                    if (element['productId'] != null) {
                      _selectedProducts.removeWhere(
                          (val) => val['productId'] == element['productId']);
                    } else if (element['materialId'] != null) {
                      _selectedProducts.removeWhere(
                          (val) => val['materialId'] == element['materialId']);
                    } else if (element['fabricatingMaterialId'] != null) {
                      _selectedProducts.removeWhere((val) =>
                          val['fabricatingMaterialId'] ==
                          element['fabricatingMaterialId']);
                    }

                    _selectedProductsWidget = [];
                    createWidget();
                    print(_selectedProducts);
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

                  print(_selectedProducts);
                },
              ),
            )
          ],
        ),
      ));
    });
  }
}
