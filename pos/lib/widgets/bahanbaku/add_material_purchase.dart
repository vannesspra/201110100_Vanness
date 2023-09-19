import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart' as FlutterMaterial;
import 'package:example/models/color.dart';
import 'package:example/models/customer.dart';
import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/models/product.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/models/supplier.dart';
import 'package:example/routes/forms.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/material.dart';
import 'package:example/services/material_purchase.dart';
import 'package:example/services/order.dart';
import 'package:example/services/product.dart';
import 'package:example/services/supplier.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:example/models/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class AddMaterialPurchaseModalContent extends StatefulWidget {
  static final GlobalKey<_AddMaterialPurchaseModalContentState> globalKey =
      GlobalKey();
  AddMaterialPurchaseModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddMaterialPurchaseModalContent> createState() =>
      _AddMaterialPurchaseModalContentState();
}

class _AddMaterialPurchaseModalContentState
    extends State<AddMaterialPurchaseModalContent> {
  //List
  PlatformFile? _imagePlatformFile;
  File? _imageFile;
  String? _imagePath;
  String fileName = "";
  List<Material> materials = [];
  List<Product> products = [];
  List<FabricatingMaterial> fabricatingMaterials = [];
  List<Map<String, dynamic>> _selectedMaterials = [];
  List<Widget> _selectedMaterialsWidget = [];
  Widget materialWidget = Container();
  Widget productWidget = Container();
  Widget fabricatingMaterialWidget = Container();
  List<Supplier> suppliers = [];
  List<AutoSuggestBoxItem> material_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> product_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> fabricatingMaterial_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> supplier_items = <AutoSuggestBoxItem>[];

  //Service
  ProductService _productService = ProductService();
  MaterialService _materialService = MaterialService();
  SupplierServices _supplierServices = SupplierServices();
  OrderService _orderService = OrderService();
  MaterialPurchaseService _materialPurchaseService = MaterialPurchaseService();

  //Time
  DateTime materialPurchaseDate = DateTime.now();

  final _materialPurchaseCodeController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _taxAmountController = TextEditingController();
  final _materialController = TextEditingController();
  final _productController = TextEditingController();
  final _fabricatingMaterialController = TextEditingController();
  final _supplierController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();

  int? _supplierId = 0;
  String _tax = "Tidak";
  int? _materialId = 0;

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  //Checkbox
  bool checked_order = false;
  bool checked_deliver = false;
  bool checked_done = false;

  // getMaterials() async {
  //   var response = await _materialService.getMaterials();
  //   materials = response.data;
  //   materials.forEach((element) {
  //     material_items.add(AutoSuggestBoxItem(
  //         value: element.materialId, label: element.materialName!));
  //   });
  // }

  getSuppliers() async {
    var response = await _supplierServices.getSupplier();
    suppliers = response.data;
    print(suppliers);
    // suppliers.forEach((supplier) {
    //   supplier.supplierProducts!.forEach((supplierProduct) {
    //     if (supplierProduct.material != null) {
    //       materials.add(supplierProduct.material!);
    //     }
    //   });
    // });
    suppliers.forEach((element) {
      supplier_items.add(AutoSuggestBoxItem(
          value: element.supplierId, label: element.supplierName!));
    });
  }

  createMaterialPurchases() async {
    var response = await _materialPurchaseService.postMaterialPurchase(
        materialPurchaseCode: _materialPurchaseCodeController.text,
        materialPruchaseDate: materialPurchaseDate,
        taxInvoiceNumber: _invoiceNumberController.text,
        taxAmount: _taxAmountController.text,
        materials: _selectedMaterials,
        supplierId: _supplierId,
        imagePath: _imagePath);
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
    // getMaterials();
    getSuppliers();
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
                controller: _materialPurchaseCodeController,
                placeholder: "Diinput dari PO yang diterima",
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
            Container(child: const Text("Tanggal"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
                child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: DatePicker(
                selected: materialPurchaseDate,
                onChanged: (value) =>
                    setState(() => materialPurchaseDate = value),
              ),
            )),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(child: const Text("Supplier"), width: 100),
                Container(
                  child: const Text(":"),
                  width: 10,
                ),
                Expanded(
                  child: AutoSuggestBox(
                    onSelected: (value) {
                      setState(() {
                        _selectedMaterials = [];
                        _selectedMaterialsWidget = [];
                        _supplierId = int.tryParse(value.value.toString());
                        print("VALUE: ${value.value}");
                        // FOR MATERIAL
                        materialWidget = Container();
                        material_items.clear();
                        materials.clear();
                        _materialController.clear();

                        // PRODUCT
                        productWidget = Container();
                        product_items.clear();
                        products.clear();
                        _productController.clear();

                        // FAB
                        fabricatingMaterialWidget = Container();
                        fabricatingMaterial_items.clear();
                        fabricatingMaterials.clear();
                        _fabricatingMaterialController.clear();

                        suppliers.forEach((supplier) {
                          if (supplier.supplierId == _supplierId) {
                            _tax = supplier.supplierTax!;
                            supplier.supplierProducts!
                                .forEach((supplierProduct) {
                              if (supplierProduct.material != null) {
                                materials.add(supplierProduct.material!);
                              } else if (supplierProduct.product != null) {
                                products.add(supplierProduct.product!);
                              } else if (supplierProduct.fabricatingMaterial !=
                                  null) {
                                fabricatingMaterials
                                    .add(supplierProduct.fabricatingMaterial!);
                              }
                            });
                          }
                        });

                        materials.forEach((element) {
                          material_items.add(AutoSuggestBoxItem(
                              value: element.materialId,
                              label: element.materialName!));
                        });

                        products.forEach((element) {
                          product_items.add(AutoSuggestBoxItem(
                              value: element.productId,
                              label: element.productName!));
                        });

                        fabricatingMaterials.forEach((element) {
                          fabricatingMaterial_items.add(AutoSuggestBoxItem(
                              value: element.fabricatingMaterialId,
                              label: element.fabricatingMaterialName!));
                        });

                        createMaterialWidget();
                        createProductWidget();
                        createFabricatingMaterialWidget();
                      });
                    },
                    controller: _supplierController,
                    placeholder:
                        "Diinput sesuai dengan supplier yang didaftarkan",
                    items: supplier_items,
                  ),
                ),
              ],
            ),
            if (_tax == "Ya")
              Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(child: const Text("Nominal PPn"), width: 100),
                      Container(
                        child: const Text(":"),
                        width: 10,
                      ),
                      Expanded(
                        child: TextBox(
                          controller: _taxAmountController,
                          placeholder: "Masukkan nominal PPn",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              child: const Text("Nomor Faktur"), width: 100),
                          Container(
                            child: const Text(":"),
                            width: 10,
                          ),
                          Expanded(
                            child: TextBox(
                              suffix: IconButton(
                                icon: Icon(FluentIcons.upload),
                                onPressed: () async {
                                  var picked =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                  );

                                  if (picked != null) {
                                    setState(() {
                                      fileName = picked.files.first.name;
                                      _imagePlatformFile = picked.files.first;
                                    });
                                  }

                                  _imagePath = _imagePlatformFile!.path;
                                  _imageFile = File(_imagePath!);

                                  // final directory =
                                  //     await getTemporaryDirectory();
                                  // final imagePath = await ImagePicker()
                                  //     .getImage(source: ImageSource.gallery);

                                  // if (imagePath != null) {
                                  //   final imageName =
                                  //       path.basename(imagePath.path);
                                  //   final savedImagePath =
                                  //       path.join(directory.path, imageName);

                                  //   // Copy the selected image to the temporary directory
                                  //   await File(imagePath.path)
                                  //       .copy(savedImagePath);

                                  //   setState(() {
                                  //     _imagePath = savedImagePath;
                                  //     print("SUUU : ${_imagePath}");
                                  //   });
                                  // }
                                },
                              ),
                              controller: _invoiceNumberController,
                              placeholder: "Nomor Faktur",
                            ),
                          ),
                          TextButton(
                              child: Text(fileName),
                              onPressed: () async {
                                // await showDialog(
                                //     context: context,
                                //     builder: (_) => ImageDialog(
                                //           pasedFile: _imagePlatformFile!,
                                //         ));
                                openFullScreenImageModal(context, _imageFile!);
                              }),
                        ],
                      ),
                      // if (_imagePlatformFile != null)
                      //   Image.file(
                      //     File(_imagePlatformFile!.path!),
                      //     width: 300,
                      //     height: 300,
                      //     fit: BoxFit.cover,
                      //   ),
                    ],
                  )
                ],
              ),
            SizedBox(
              height: 10,
            ),
            materialWidget,
            SizedBox(
              height: 10,
            ),
            fabricatingMaterialWidget,
            SizedBox(
              height: 10,
            ),
            productWidget,
            SizedBox(
              height: 15,
            ),
            Column(
              children: _selectedMaterialsWidget,
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  void openFullScreenImageModal(BuildContext context, File imageFile) {
    Navigator.of(context).push(
      FlutterMaterial.MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenImageModal(imageFile: imageFile),
      ),
    );
  }

  void createMaterialWidget() {
    setState(() {
      materialWidget = Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Bahan Baku"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: AutoSuggestBox(
                onSelected: (value) {
                  print(value.value);
                  setState(() {
                    _materialId = int.tryParse(value.value.toString());
                    var contain = _selectedMaterials.where((element) =>
                        element['materialId'] == value.value.toString());
                    if (contain.isEmpty) {
                      _selectedMaterials.add({
                        "supplierId": _supplierId,
                        "materialId": value.value.toString(),
                        "productId": null,
                        "fabricatingMaterialId": null,
                        "qty": "1",
                        "label": value.label
                      });
                    }

                    _selectedMaterialsWidget = [];
                    createMaterialWidgets();
                  });
                },
                controller: _materialController,
                items: material_items,
                placeholder: "Diinput sesuai bahan baku yang didaftarkan",
              ),
            ),
          ],
        ),
      );
    });
  }

  void createProductWidget() {
    setState(() {
      productWidget = Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Item Produk"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: AutoSuggestBox(
                onSelected: (value) {
                  print(value.value);
                  setState(() {
                    _materialId = int.tryParse(value.value.toString());
                    var contain = _selectedMaterials.where((element) =>
                        element['productId'] == value.value.toString());
                    if (contain.isEmpty) {
                      _selectedMaterials.add({
                        "supplierId": _supplierId,
                        "materialId": null,
                        "productId": value.value.toString(),
                        "fabricatingMaterialId": null,
                        "qty": "1",
                        "label": value.label
                      });
                    }

                    _selectedMaterialsWidget = [];
                    createMaterialWidgets();
                  });
                },
                controller: _productController,
                items: product_items,
                placeholder:
                    "Diinput sesuai dengan item produk yang didaftarkan",
              ),
            ),
          ],
        ),
      );
    });
  }

  void createFabricatingMaterialWidget() {
    setState(() {
      fabricatingMaterialWidget = Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Bahan\nsetengah jadi"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: AutoSuggestBox(
                onSelected: (value) {
                  print(value.value);
                  setState(() {
                    _materialId = int.tryParse(value.value.toString());
                    var contain = _selectedMaterials.where((element) =>
                        element['fabricatingMaterialId'] ==
                        value.value.toString());
                    if (contain.isEmpty) {
                      _selectedMaterials.add({
                        "supplierId": _supplierId,
                        "materialId": null,
                        "productId": null,
                        "fabricatingMaterialId": value.value.toString(),
                        "qty": "1",
                        "label": value.label
                      });
                    }

                    _selectedMaterialsWidget = [];
                    createMaterialWidgets();
                  });
                },
                controller: _fabricatingMaterialController,
                items: fabricatingMaterial_items,
                placeholder:
                    "Diinput sesuai dengan bahan setengah jadi yang didaftarkan",
              ),
            ),
          ],
        ),
      );
    });
  }

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
                    if (element['productId'] != null) {
                      _selectedMaterials.removeWhere(
                          (val) => val['productId'] == element['productId']);
                    } else if (element['materialId'] != null) {
                      _selectedMaterials.removeWhere(
                          (val) => val['materialId'] == element['materialId']);
                    } else if (element['fabricatingMaterialId'] != null) {
                      _selectedMaterials.removeWhere((val) =>
                          val['fabricatingMaterialId'] ==
                          element['fabricatingMaterialId']);
                    }
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
}

class FullScreenImageModal extends StatelessWidget {
  final File imageFile;

  const FullScreenImageModal({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return FlutterMaterial.Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: Center(
              child: Image.file(imageFile),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FlutterMaterial.IconButton(
              icon: Icon(FlutterMaterial.Icons.close),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
