import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:example/models/adjustment.dart';
import 'package:example/models/color.dart';
import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/models/material.dart';
import 'package:example/models/product.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/services/adjustment.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/fabricatingMaterial.dart';
import 'package:example/services/material.dart';
import 'package:example/services/product.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class AddAdjustmentModalContent extends StatefulWidget {
  static final GlobalKey<_AddAdjustmentModalContentState> globalKey =
      GlobalKey();
  AddAdjustmentModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddAdjustmentModalContent> createState() =>
      _AddAdjustmentModalContentState();
}

class _AddAdjustmentModalContentState extends State<AddAdjustmentModalContent> {
  //Service
  MaterialService _materialService = MaterialService();
  ProductService _productService = ProductService();
  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();
  AdjustmentService _adjustmentService = AdjustmentService();

  //models
  List<Material> materials = [];
  List<Product> products = [];
  List<FabricatingMaterial> fabricatingMaterial = [];
  List<Widget> _widgets = [];
  List<AutoSuggestBoxItem> material_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> product_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> fabricatingMaterial_items = <AutoSuggestBoxItem>[];

  List<Adjustment>? existingAdjustments;

  //Late
  late Future adjustmentsFuture;

  //Time
  final now = DateTime.now();

  //Text Editing Controller / For Post
  final _adjustmentCodeInputController = TextEditingController();
  final _adjustedQtyInpuController = TextEditingController();
  final _adjustmentReasonInputController = TextEditingController();
  final _adjustmentDescInputController = TextEditingController();
  final _adjustedQtyInputController = TextEditingController();
  final _adjustedMaterialController = TextEditingController();
  final _adjustedProductController = TextEditingController();
  final _adjustedFabMaterialController = TextEditingController();

  String selectedFilter = "";
  List filterList = ["Produk", "Bahan Baku", "Barang 1/2 Jadi"];

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  int? _materialId;
  int? _productId;
  int? _fabricatingMaterialId;

  // getTypes() async {
  //   var response = await _typeService.getTypes();
  //   _productTypes = response.data;
  //   print("Get to View: ${_productTypes}");
  //   for (var element in _productTypes) {
  //     print(element.typeName);
  //   }
  // }

  // getColors() async {
  //   var response = await _colorService.getColors();
  //   _colors = response.data;
  //   print("Get to View: ${_colors}");

  //   for (var element in _colors) {
  //     print(element.colorName);
  //     _productColorTreeItems.add(TreeViewItem(
  //         content: Text(element.colorName!), value: element.colorId));
  //   }

  //   _productColorsTree = [
  //     TreeViewItem(
  //         lazy: true,
  //         // Ensure the list is modifiable.

  //         content: const Text("Warna Produk"),
  //         value: -1,
  //         children: _productColorTreeItems)
  //   ];
  // }

  postAdjustment() async {
    var response = await _adjustmentService.postAdjustment(
        adjustedQty: _adjustedQtyInpuController.text,
        adjustmentCode: _adjustmentCodeInputController.text,
        materialId: _materialId,
        productId: _productId,
        fabricatingMaterialId: _fabricatingMaterialId,
        adjustmentDesc: _adjustmentDescInputController.text,
        adjustmentReason: _adjustmentReasonInputController.text);
    print(response.message);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        adjustmentsFuture = getAdjustments();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;
    });
  }

  getAdjustments() async {
    var response = await _adjustmentService.getAdjustments();
    existingAdjustments = response.data;
    _adjustmentCodeInputController.text = "PI/ACC/${(formatDate(now, [
          mm,
          yy
        ]).toString())}/${(existingAdjustments!.length + 1).toString().padLeft(5, "0")}";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMaterials();
    getProducts();
    getFabricatingMaterial();

    adjustmentsFuture = getAdjustments();
  }

  getMaterials() async {
    var response = await _materialService.getMaterials();
    materials = response.data;
    materials.forEach((element) {
      material_items.add(AutoSuggestBoxItem(
          value: element.materialId, label: element.materialName!));
    });
  }

  getProducts() async {
    var response = await _productService.getProduct();
    products = response.data;
    products.forEach((element) {
      product_items.add(AutoSuggestBoxItem(
          value: element.productId, label: element.productName!));
    });
  }

  getFabricatingMaterial() async {
    var response = await _fabricatingMaterialService.getFabricatingMaterials();
    fabricatingMaterial = response.data;
    fabricatingMaterial.forEach((element) {
      fabricatingMaterial_items.add(AutoSuggestBoxItem(
          value: element.fabricatingMaterialId,
          label: element.fabricatingMaterialName!));
    });
  }

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
                child: FutureBuilder(
              future: adjustmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      controller: _adjustmentCodeInputController,
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
        const SizedBox(
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
                  placeholder: const Text("Kategori Penyesuaian"),
                  value: selectedFilter,
                  items: filterList.map((e) {
                    return ComboBoxItem(
                      child: Text(e),
                      value: e,
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _widgets = [];
                      print(value);
                      selectedFilter = value.toString();
                    });
                  }),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedFilter == "Bahan Baku") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(child: const Text("Pilih Bahan Baku"), width: 100),
                  Container(
                    child: const Text(":"),
                    width: 10,
                  ),
                  Expanded(
                    child: AutoSuggestBox(
                      clearButtonEnabled: false,
                      controller: _adjustedMaterialController,
                      onSelected: (value) {
                        String _materialQty = "";
                        materials.forEach((element) {
                          if (element.materialId == value.value) {
                            _materialQty = element.materialQty!;
                            setState(() {
                              _adjustedMaterialController.text =
                                  element.materialName!;
                            });
                          }
                        });

                        setState(() {
                          _widgets = [];
                          _materialId = int.tryParse(value.value.toString());
                          createWidget(_materialQty);
                          // _adjustedMaterialController.text =
                        });
                      },
                      items: material_items,
                      placeholder: "Bahan Baku",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ] else if (selectedFilter == "Produk") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(child: const Text("Pilih Produk"), width: 100),
                  Container(
                    child: const Text(":"),
                    width: 10,
                  ),
                  Expanded(
                    child: AutoSuggestBox(
                      controller: _adjustedProductController,
                      clearButtonEnabled: false,
                      onSelected: (value) {
                        String _productQty = "";
                        products.forEach((element) {
                          if (element.productId == value.value) {
                            _productQty = element.productQty!;
                            setState(() {
                              _adjustedProductController.text =
                                  element.productName!;
                            });
                          }
                        });

                        setState(() {
                          _widgets = [];
                          _productId = int.tryParse(value.value.toString());
                          createWidget(_productQty);
                        });
                      },
                      items: product_items,
                      placeholder: "Produk",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ] else if (selectedFilter == "Barang 1/2 Jadi") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: const Text("Pilih Bahan Setengah Jadi"),
                      width: 100),
                  Container(
                    child: const Text(":"),
                    width: 10,
                  ),
                  Expanded(
                    child: AutoSuggestBox(
                      controller: _adjustedFabMaterialController,
                      clearButtonEnabled: false,
                      onSelected: (value) {
                        String _fabricatingMaterialQty = "";
                        fabricatingMaterial.forEach((element) {
                          if (element.fabricatingMaterialId == value.value) {
                            _fabricatingMaterialQty =
                                element.fabricatingMaterialQty!;
                            setState(() {
                              _adjustedFabMaterialController.text =
                                  element.fabricatingMaterialName!;
                            });
                          }
                        });

                        setState(() {
                          _widgets = [];
                          _fabricatingMaterialId =
                              int.tryParse(value.value.toString());
                          createWidget(_fabricatingMaterialQty);
                        });
                      },
                      items: fabricatingMaterial_items,
                      placeholder: "Barang 1/2 Jadi",
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          children: _widgets,
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Alasan"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _adjustmentReasonInputController,
                placeholder: "Alasan penyesuaian",
                maxLines: 2,
              ),
            ),
          ],
        ),
        const SizedBox(
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
                controller: _adjustmentDescInputController,
                placeholder: "Deskripsi penyesuaian ... ",
                maxLines: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void createWidget(String formerQty) {
    _widgets.add(Container(
      padding: EdgeInsets.only(bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Qty Sistem"),
                TextBox(
                  placeholder: formerQty,
                  enabled: false,
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Qty Fisikal"),
                TextBox(
                  controller: _adjustedQtyInpuController,
                  placeholder: "0",
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
