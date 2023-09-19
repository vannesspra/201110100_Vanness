import 'dart:math';

import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/screens/product_color.dart';
import 'package:example/services/color.dart';
import 'package:example/models/color.dart';
import 'package:example/services/fabricatingMaterial.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class AddFabricatingMaterialModalContent extends StatefulWidget {
  static final GlobalKey<_AddFabricatingMaterialModalContentState> globalKey =
      GlobalKey();
  AddFabricatingMaterialModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddFabricatingMaterialModalContent> createState() =>
      _AddFabricatingMaterialModalContentState();
}

class _AddFabricatingMaterialModalContentState
    extends State<AddFabricatingMaterialModalContent> {
  //Service
  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();
  ColorService _colorService = ColorService();

  //List
  List<FabricatingMaterial>? existingFabricatingMaterials;
  late List<Color> _colors = [];
  List<AutoSuggestBoxItem> color_items = <AutoSuggestBoxItem>[];
  //Future
  late Future colorFuture;
  late Future fabricatingMaterialFuture;

  //Text Editing Controller / For Post
  final _kodeBarangSetengahJadiInputController = TextEditingController();
  final _namaBarangSetengahJadiInputController = TextEditingController();
  final _unitBarangSetengahJadiInputController = TextEditingController();
  final _qtyBarangSetengahJadiInputController = TextEditingController();
  final _minStockBarangSetengahJadiInputController = TextEditingController();
  final _hargaBarangSetengahJadiInputController = TextEditingController();
  final _colorController = TextEditingController(text: "");
  // List _inputedProductColors = [];
  int? _selectedColor;

  String? _colorCode = "";

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  postBarangSetengahJadi() async {
    var response = await _fabricatingMaterialService.postFabricatingMaterial(
        fabricatingMaterialCode: _kodeBarangSetengahJadiInputController.text,
        fabricatingMaterialName: _namaBarangSetengahJadiInputController.text,
        colorId: _selectedColor,
        fabricatingMaterialUnit: _unitBarangSetengahJadiInputController.text,
        fabricatingMaterialMinimumStock:
            _minStockBarangSetengahJadiInputController.text,
        fabricatingMaterialQty: _qtyBarangSetengahJadiInputController.text,
        fabricatingMaterialPrice: _hargaBarangSetengahJadiInputController.text);
    print(response.message);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        fabricatingMaterialFuture = getFabricatingMaterials();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;

      getColors();
    });
  }

  getColors() async {
    color_items = [];
    var response = await _colorService.getColors();
    _colors = response.data;
    print("Get to View: ${_colors}");
    _colors.forEach((element) {
      color_items.add(
        AutoSuggestBoxItem(
          value: element.colorCode,
          label: element.colorName!,
        ),
      );
    });
    // for (var element in _colors) {
    //   print(element.colorName);
    //   _productColorTreeItems.add(TreeViewItem(
    //       content: Text(element.colorName!), value: element.colorId));
    // }

    // _productColorsTree = [
    //   TreeViewItem(
    //       lazy: true,
    //       // Ensure the list is modifiable.

    //       content: const Text("Warna Produk"),
    //       value: -1,
    //       children: _productColorTreeItems)
    // ];
  }

  getFabricatingMaterials() async {
    var response = await _fabricatingMaterialService.getFabricatingMaterials();
    existingFabricatingMaterials = response.data;
    _kodeBarangSetengahJadiInputController.text =
        "BSJ${(existingFabricatingMaterials!.length + 1).toString().padLeft(5, "0")}";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getColors();
    colorFuture = getColors();
    fabricatingMaterialFuture = getFabricatingMaterials();
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
            Container(
              child: const Text("Kode"),
              width: 100,
            ),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: FutureBuilder(
                    future: fabricatingMaterialFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: TextBox(
                            controller: _kodeBarangSetengahJadiInputController,
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
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: const Text("Nama"),
              width: 100,
            ),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextBox(
                  controller: _namaBarangSetengahJadiInputController,
                  placeholder: "Masukkan nama bahan setengah jadi",
                  // maxLines: 2,
                ),
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
            Container(child: const Text("Warna"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            // Expanded(
            //   child: AutoSuggestBox(
            //     trailingIcon: IconButton(
            //         icon: Icon(FluentIcons.clear),
            //         onPressed: () {
            //           setState(() {
            //             _colorController.text = '';
            //             _selectedColor = null;
            //             print(_colorCode);
            //           });
            //         }),
            //     clearButtonEnabled: false,
            //     onSelected: (value) {
            //       print("iniiiiiii ${value.value}");
            //       setState(() {
            //         _colorCode = value.value.toString();
            //         // if (_colorCode == "null") {
            //         //   _selectedColor = -1;
            //         //   print(_selectedColor);
            //         // }
            //         colors!.forEach((element) {
            //           if (element.colorCode == _colorCode) {
            //             _selectedColor = element.colorId;
            //           }
            //         });

            //         // getExtraDiscounts(_orderCode!);
            //       });
            //     },
            //     controller: _colorController,
            //     placeholder:
            //         "Sesuai dengan master yang telah diinput di tambahan warna baru (boleh null)",
            //     items: color_items,
            //   ),
            // ),
            Expanded(
              child: FutureBuilder(
                  future: colorFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Widget child;
                    if (snapshot.connectionState == ConnectionState.done) {
                      child = ComboBox(
                          placeholder: const Text("Pilih warna produk"),
                          value: _selectedColor,
                          items: _colors.map((e) {
                            return ComboBoxItem(
                              child: Text(e.colorName!),
                              value: e.colorId,
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              print(int.parse(value.toString()));
                              _selectedColor = int.parse(value.toString());
                              print(_selectedColor);
                              print(_selectedColor.runtimeType);
                            });
                          });
                    } else {
                      child = ComboBox(
                        placeholder: const ProgressBar(),
                        value: _selectedColor,
                        items: _colors.map((e) {
                          return ComboBoxItem(
                            child: Text(e.colorName!),
                            value: e.colorId,
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
            Container(
              child: const Text("Harga @"),
              width: 100,
            ),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextBox(
                  inputFormatters: <TextInputFormatter>[
                      // for below version 2 use this
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      // for version 2 and greater youcan also use this
                      // FilteringTextInputFormatter.digitsOnly
                    ],
                  controller: _hargaBarangSetengahJadiInputController,
                  placeholder:
                      "Masukkan harga bahan setengah jadi per satuan unit",
                  // maxLines: 2,
                ),
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
            Container(
              child: const Text("Satuan Unit"),
              width: 100,
            ),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextBox(
                  controller: _unitBarangSetengahJadiInputController,
                  placeholder: "Masukkan Kg/Drum/Pcs/Pail/Gram",
                  maxLines: 2,
                ),
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
            Container(
              child: const Text("Qty"),
              width: 100,
            ),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextBox(
                  inputFormatters: <TextInputFormatter>[
                      // for below version 2 use this
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      // for version 2 and greater youcan also use this
                      // FilteringTextInputFormatter.digitsOnly
                    ],
                  controller: _qtyBarangSetengahJadiInputController,
                  placeholder:
                      "Masukkan qty sesuai dengan satuan unit yang telah ditentukan",
                  maxLines: 2,
                ),
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
            Container(
              child: const Text("Minimum Stock"),
              width: 100,
            ),
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
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      // for version 2 and greater youcan also use this
                      // FilteringTextInputFormatter.digitsOnly
                    ],
                  controller: _minStockBarangSetengahJadiInputController,
                  placeholder:
                      "Masukkan minimum stock yang harus dijaga setiap bulannya",
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
