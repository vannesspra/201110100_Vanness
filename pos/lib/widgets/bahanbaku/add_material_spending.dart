import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/models/customer.dart';
import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/models/material_spending.dart';
import 'package:example/models/product.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/models/supplier.dart';
import 'package:example/routes/forms.dart';
import 'package:example/screens/fabricatingMaterial_screen.dart';
import 'package:example/services/fabricatingMaterial.dart';
import 'package:example/services/material.dart';
import 'package:example/services/material_purchase.dart';
import 'package:example/services/material_spending.dart';
import 'package:example/services/order.dart';
import 'package:example/services/product.dart';
import 'package:example/services/supplier.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:example/models/material.dart';

class AddMaterialSpendingModalContent extends StatefulWidget {
  static final GlobalKey<_AddMaterialSpendingModalContentState> globalKey =
      GlobalKey();
  AddMaterialSpendingModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddMaterialSpendingModalContent> createState() =>
      _AddMaterialSpendingModalContentState();
}

class _AddMaterialSpendingModalContentState
    extends State<AddMaterialSpendingModalContent> {
  //List
  List<MaterialSpending>? existingMaterialSpendings;

  List<Material> materials = [];
  List<FabricatingMaterial> fabricatingMaterials = [];
  List<Map<String, dynamic>> _selectedMaterials = [];
  List<Widget> _selectedMaterialsWidget = [];
  Widget materialWidget = Container();
  Widget fabricatingMaterialWidget = Container();

  List<AutoSuggestBoxItem> material_items = <AutoSuggestBoxItem>[];
  List<AutoSuggestBoxItem> fabricatingMaterial_items = <AutoSuggestBoxItem>[];

  //Service
  MaterialService _materialService = MaterialService();
  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();
  SupplierServices _supplierServices = SupplierServices();
  OrderService _orderService = OrderService();
  MaterialSpendingService _materialSpendingService = MaterialSpendingService();

  //Time
  DateTime materialSpendingDate = DateTime.now();

  //Future
  late Future materialSpendingsFuture;

  final _materialSpendingCodeController = TextEditingController();
  final _materialController = TextEditingController();
  final _fabricatingMaterialController = TextEditingController();
  final _qtyController = TextEditingController();

  int? _materialId = 0;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMaterials();
    getFabricatingMaterials();

    materialSpendingsFuture = getMaterialSpendings();
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

  getMaterialSpendings() async {
    var response = await _materialSpendingService.getMaterialSpendingGrouped();
    existingMaterialSpendings = response.data;
    _materialSpendingCodeController.text =
        "PB${(existingMaterialSpendings!.length + 1).toString().padLeft(5, "0")}";
  }

  createMaterialSpendings() async {
    var response = await _materialSpendingService.postMaterialSpending(
      materialSpendingCode: _materialSpendingCodeController.text,
      materialSpendingDate: materialSpendingDate,
      materials: _selectedMaterials,
    );
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        materialSpendingsFuture = getMaterialSpendings();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;
    });
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
              future: materialSpendingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      controller: _materialSpendingCodeController,
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
                  selected: materialSpendingDate,
                  onChanged: (value) =>
                      setState(() => materialSpendingDate = value),
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
            Container(child: const Text("Bahan Baku"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: AutoSuggestBox(
                    onSelected: (value) {
                      print(value.value);
                      setState(() {
                        _materialId = int.tryParse(value.value.toString());
                        var contain = _selectedMaterials.where((element) =>
                            element['materialId'] == value.value.toString());
                        if (contain.isEmpty) {
                          _selectedMaterials.add({
                            "materialId": value.value.toString(),
                            "fabricatingMaterialId": null,
                            "qty": "1",
                            "label": value.label
                          });
                        }

                        _selectedMaterialsWidget = [];
                        createWidget();
                      });
                    },
                    controller: _materialController,
                    items: material_items,
                    placeholder: "Masukkan Bahan Baku",
                  )),
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
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 250),
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
                            "materialId": null,
                            "fabricatingMaterialId": value.value.toString(),
                            "qty": "1",
                            "label": value.label
                          });
                        }

                        _selectedMaterialsWidget = [];
                        createWidget();
                      });
                    },
                    controller: _fabricatingMaterialController,
                    items: fabricatingMaterial_items,
                    placeholder: "Masukkan Bahan Setengah Jadi",
                  )),
            ),
          ],
        ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Container(
        //         constraints: const BoxConstraints(maxWidth: 250),
        //         child: AutoSuggestBox(
        //           onSelected: (value) {
        //             print(value.value);
        //             setState(() {
        //               _materialId = int.tryParse(value.value.toString());
        //               var contain = _selectedMaterials.where((element) =>
        //                   element['fabricatingMaterialId'] ==
        //                   value.value.toString());

        //               if (contain.isEmpty) {
        //                 _selectedMaterials.add({
        //                   "materialId": null,
        //                   "fabricatingMaterialId": value.value.toString(),
        //                   "qty": "1",
        //                   "label": value.label
        //                 });
        //               }

        //               _selectedMaterialsWidget = [];
        //               createWidget();
        //             });
        //           },
        //           controller: _fabricatingMaterialController,
        //           items: fabricatingMaterial_items,
        //           placeholder: "Barang Setengah Jadi",
        //         )),
        //     SizedBox(
        //       height: 10,
        //     ),
        //   ],
        // ),
        SizedBox(
          height: 10,
        ),
        Column(
          children: _selectedMaterialsWidget,
        ),
      ],
    );
  }

  void createWidget() {
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
                    if (element['materialId'] != null) {
                      _selectedMaterials.removeWhere(
                          (val) => val['materialId'] == element['materialId']);
                    } else if (element['fabricatingMaterialId'] != null) {
                      _selectedMaterials.removeWhere((val) =>
                          val['fabricatingMaterialId'] ==
                          element['fabricatingMaterialId']);
                    }

                    _selectedMaterialsWidget = [];
                    createWidget();
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
