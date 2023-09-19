import 'dart:async';
import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/services/color.dart';
import 'package:example/services/product.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class EditProductModalContent extends StatefulWidget {
  static final GlobalKey<_EditProductModalContentState> globalKey = GlobalKey();
  int productId;
  String productCode;
  String productName;
  String productPrice;
  String productDesc;
  String productMinimumStock;
  String productQty;
  // List<Color>? colors;
  int? typeId;
  int? colorId;

  EditProductModalContent(
      {Key? key,
      required this.productId,
      required this.productCode,
      required this.productName,
      required this.productPrice,
      required this.productDesc,
      required this.productMinimumStock,
      required this.productQty,
      required this.colorId,
      required this.typeId})
      : super(key: globalKey);

  @override
  State<EditProductModalContent> createState() =>
      _EditProductModalContentState();
}

class _EditProductModalContentState extends State<EditProductModalContent> {
  //Service
  TypeService _typeService = TypeService();
  ColorService _colorService = ColorService();
  ProductService _productService = ProductService();

  late List<ProductType> _productTypes = [];
  late List<Color> _colors = [];
  // List<TreeViewItem> _productColorsTree = [
  //   TreeViewItem(content: const Text("Warna Produk"), value: -1, children: [])
  // ];

  // List<TreeViewItem> _productColorTreeItems = <TreeViewItem>[];

  //Future
  late Future typeFuture;
  late Future colorFuture;

  //Text Editing Controller / For Post
  final _productCodeInputController = TextEditingController();
  final _productNameInputController = TextEditingController();
  final _productPriceInputController = TextEditingController();
  final _productDescInputController = TextEditingController();
  final _productQtyInputController = TextEditingController();
  final _productMinimumStockInputController = TextEditingController();
  // List _inputedProductColors = [];
  int? _selectedType;
  int? _selectedColor;

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  Future<Uint8List> captureWidget() async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage();

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    print(pngBytes);

    return pngBytes;
  }

  Future<void> printBarcode() async {
    print("FUCEK");
    final barcodeImage = await captureWidget();

    print("Fucek " + barcodeImage.toString());
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pdf = pw.Document();
        final imageProvider = pw.MemoryImage(barcodeImage);

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(imageProvider),
              );
            },
          ),
        );

        return pdf.save();
      },
    );
  }

  getTypes() async {
    var response = await _typeService.getTypes();
    _productTypes = response.data;
    print("Get to View: ${_productTypes}");
    for (var element in _productTypes) {
      print(element.typeName);
    }
  }

  getColors() async {
    var response = await _colorService.getColors();
    _colors = response.data;
    print("Get to View: ${_colors}");
    for (var element in _colors) {
      print(element.colorName);
    }

    // for (var element in _colors) {
    //   if (widget.colors!
    //       .map((item) => item.colorId)
    //       .contains(element.colorId)) {
    //     _productColorTreeItems.add(TreeViewItem(
    //         selected: true,
    //         content: Text(element.colorName!),
    //         value: element.colorId));
    //   } else {
    //     _productColorTreeItems.add(TreeViewItem(
    //         selected: false,
    //         content: Text(element.colorName!),
    //         value: element.colorId));
    //   }
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

  updateProduct() async {
    var response = await _productService.updateProduct(
      productId: widget.productId,
      productCode: _productCodeInputController.text,
      productName: _productNameInputController.text,
      productPrice: _productPriceInputController.text,
      productDesc: _productDescInputController.text,
      productMinimumStock: _productMinimumStockInputController.text,
      productQty: _productQtyInputController.text,
      typeId: _selectedType,
      // colors: _inputedProductColors
      colorId: _selectedColor,
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
    _selectedType = widget.typeId;
    _selectedColor = widget.colorId;
    _productCodeInputController.text = widget.productCode;
    _productNameInputController.text = widget.productName;
    _productPriceInputController.text = widget.productPrice;
    _productQtyInputController.text = widget.productQty;
    _productMinimumStockInputController.text = widget.productMinimumStock;
    typeFuture = getTypes();
    colorFuture = getColors();
  }

  bool checked = false;
  final GlobalKey globalKey = new GlobalKey();
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
              readOnly: true,
              enabled: false,
              controller: _productCodeInputController,
              placeholder:
                  "Diinput manual sesuai dengan barang apa yang akan diinput",
            )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Jenis Produk"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: FutureBuilder(
                  future: typeFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Widget child;
                    if (snapshot.connectionState == ConnectionState.done) {
                      child = ComboBox(
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
                              _selectedType = int.parse(value.toString());
                              print(_selectedType);
                              print(_selectedType.runtimeType);
                            });
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
            Container(child: const Text("Nama Item Produk"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _productNameInputController,
                placeholder: "Diinput manual sesuai dengan nama item produk",
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
            Container(child: const Text("Harga Item"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _productPriceInputController,
                placeholder: "Diinput harga item",
                inputFormatters: <TextInputFormatter>[
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  // for version 2 and greater youcan also use this
                ],
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
            Container(child: const Text("Qty Item"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _productQtyInputController,
                placeholder: "Diinput manual sesuai dengan jumlah item produk",
                inputFormatters: <TextInputFormatter>[
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  // for version 2 and greater youcan also use this
                ],
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
            Container(child: const Text("Minimum Stock"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _productMinimumStockInputController,
                placeholder: "Diinput batas atas item produk",
                inputFormatters: <TextInputFormatter>[
                  // for below version 2 use this
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  // for version 2 and greater youcan also use this
                ],
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
            Expanded(
              child: FutureBuilder(
                  future: colorFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Widget child;
                    if (snapshot.connectionState == ConnectionState.done) {
                      child = ComboBox(
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
                            value: e.colorName,
                          );
                        }).toList(),
                      );
                    }
                    return child;
                  }),
            ),
          ],
        ),

        // FutureBuilder(
        //   future: colorFuture,
        //   builder: (BuildContext context, AsyncSnapshot snaphot) {
        //     Widget child;
        //     if (snaphot.connectionState == ConnectionState.done) {
        //       child = TreeView(
        //         selectionMode: TreeViewSelectionMode.multiple,
        //         shrinkWrap: true,
        //         items: _productColorsTree,
        //         onItemInvoked: (item, onItemInovked) async =>
        //             debugPrint('onItemInvoked: $item'),
        //         onSelectionChanged: (selectedItems) async {
        //           debugPrint(
        //               'onSelectionChanged: ${selectedItems.map((i) => i.value)}');
        //           selectedItems.forEach((item) {
        //             if (item.value != -1 &&
        //                 !_inputedProductColors.contains(item.value)) {
        //               setState(() {
        //                 print("Valid");
        //                 _inputedProductColors.add(item.value);
        //               });
        //             }
        //           });
        //           if (selectedItems.isEmpty) {
        //             _inputedProductColors = [];
        //           }
        //           print("CURRENTLY INPUTTED COLOR ID");
        //           _inputedProductColors.forEach((element) {
        //             print(element.runtimeType);
        //           });
        //         },
        //         onSecondaryTap: (item, details) async {
        //           debugPrint(
        //               'onSecondaryTap $item at ${details.globalPosition}');
        //         },
        //       );
        //     } else {
        //       child = TreeView(
        //         selectionMode: TreeViewSelectionMode.multiple,
        //         shrinkWrap: true,
        //         items: [
        //           TreeViewItem(
        //               lazy: true,
        //               content: const Text("Warna Produk"),
        //               value: -1,
        //               children: [])
        //         ],
        //       );
        //     }
        //     return child;
        //   },
        // ),

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
                controller: _productDescInputController,
                placeholder: "Diinput sesuai dengan tambahan keterangan produk",
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Center(
            child: Column(
          children: [
            RepaintBoundary(
              child: getBarcodeWidget(),
              key: globalKey,
            ),
            const SizedBox(
              height: 20,
            ),
            Button(
                child: Text(
                  "Print QR",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  printBarcode();
                })
          ],
        ))
      ],
    );
  }

  getBarcodeWidget() {
    return BarcodeWidget(
      barcode: Barcode.aztec(), // Barcode type and settings
      data: widget.productCode, // Content
      width: 200,
      height: 200,
    );
  }
}
