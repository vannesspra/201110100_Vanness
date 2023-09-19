import 'dart:math';
import 'package:example/models/color.dart';
import 'package:example/models/material.dart';
import 'package:example/screens/product_color.dart';
import 'package:example/services/color.dart';
import 'package:example/services/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as FlutterMaterial;
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class AddBahanBakuModalContent extends StatefulWidget {
  static final GlobalKey<_AddBahanBakuModalContentState> globalKey =
      GlobalKey();
  AddBahanBakuModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddBahanBakuModalContent> createState() =>
      _AddBahanBakuModalContentState();
}

class _AddBahanBakuModalContentState extends State<AddBahanBakuModalContent> {
  List<Material>? existingMaterials;

  //Service
  MaterialService _bahanbakuService = MaterialService();
  ColorService _colorService = ColorService();

  late List<Color> _colors = [];
  List<AutoSuggestBoxItem> color_items = <AutoSuggestBoxItem>[];
  //Future
  late Future colorFuture;
  late Future materialFuture;

  //Text Editing Controller / For Post
  final _kodeBahanBakuInputController = TextEditingController();
  final _namaBahanBakuInputController = TextEditingController();
  final _unitBahanbakuInputController = TextEditingController();
  final _qtyBahanBakuInputController = TextEditingController();
  final _hargaBahanBakuInputController = TextEditingController();
  final _minStockBahanBakuInputController = TextEditingController();
  final _colorController = TextEditingController(text: "");
  // List _inputedProductColors = [];
  int? _selectedColor;

  String? _colorCode = "";
  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  postBahanBaku() async {
    var response = await _bahanbakuService.postMaterial(
        materialCode: _kodeBahanBakuInputController.text,
        materialName: _namaBahanBakuInputController.text,
        colorId: _selectedColor,
        materialUnit: _unitBahanbakuInputController.text,
        materialMinimumStock: _minStockBahanBakuInputController.text,
        materialQty: _qtyBahanBakuInputController.text,
        materialPrice: _hargaBahanBakuInputController.text);
    print(response.message);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        materialFuture = getMaterials();
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

  getMaterials() async {
    var response = await _bahanbakuService.getMaterials();
    existingMaterials = response.data;
    _kodeBahanBakuInputController.text =
        "BK${(existingMaterials!.length + 1).toString().padLeft(5, "0")}";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    colorFuture = getColors();
    materialFuture = getMaterials();
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
              child: FutureBuilder(
                future: materialFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: TextBox(
                        controller: _kodeBahanBakuInputController,
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
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
                  controller: _namaBahanBakuInputController,
                  placeholder: "Masukkan nama Bahan Baku",
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
            //       print("Woke ${value.value}");
            //       setState(() {
            //         _colorCode = value.value.toString();
            //         colors!.forEach((element) {
            //           if (element.colorCode == _colorCode) {
            //             _selectedColor = element.colorId;
            //           }
            //         });

            //         // getExtraDiscounts(_orderCode!);
            //       });
            //     },
            //     controller: _colorController,
            //     // maxPopupHeight: 100,
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
          mainAxisAlignment: MainAxisAlignment.start,
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
                  controller: _hargaBahanBakuInputController,
                  placeholder: "Masukkan harga Bahan baku per satuan unit",
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
                  controller: _unitBahanbakuInputController,
                  placeholder:
                      "Masukkan Kg/Drum/Pcs/Pail/Gram/Meter/Centimeter",
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
                  controller: _qtyBahanBakuInputController,
                  placeholder:
                      "Masukkan qty sesuai dengan satuan unit yang telah ditentukan",
                  maxLines: 2,
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
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextBox(
                  inputFormatters: <TextInputFormatter>[
                      // for below version 2 use this
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                      // for version 2 and greater youcan also use this
                      // FilteringTextInputFormatter.digitsOnly
                    ],
                  controller: _minStockBahanBakuInputController,
                  placeholder:
                      "Masukkan minimum stock yang harus dijaga setiap bulannya",
                  maxLines: 2,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
