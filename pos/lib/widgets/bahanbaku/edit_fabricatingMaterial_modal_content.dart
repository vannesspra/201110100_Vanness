import 'dart:math';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:example/models/color.dart';
import 'package:example/screens/product_color.dart';
import 'package:example/services/color.dart';
import 'package:example/models/fabricatingMaterial.dart';
import 'package:example/services/fabricatingMaterial.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:barcode_widget/barcode_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class EditFabricatingMaterialModalContent extends StatefulWidget {
  static final GlobalKey<_EditFabricatingMaterialModalContentState> globalKey =
      GlobalKey();
  int fabricatingMaterialId;
  String fabricatingMaterialCode;
  String fabricatingMaterialName;
  String fabricatingMaterialUnit;
  String fabricatingMaterialMinimumStock;
  String fabricatingMaterialQty;
  String fabricatingMaterialPrice;
  int? colorId;
  EditFabricatingMaterialModalContent(
      {Key? key,
      required this.fabricatingMaterialId,
      required this.fabricatingMaterialCode,
      required this.fabricatingMaterialName,
      this.colorId,
      required this.fabricatingMaterialUnit,
      required this.fabricatingMaterialMinimumStock,
      required this.fabricatingMaterialQty,
      required this.fabricatingMaterialPrice})
      : super(key: globalKey);

  @override
  State<EditFabricatingMaterialModalContent> createState() =>
      _EditFabricatingMaterialModalContentState();
}

class _EditFabricatingMaterialModalContentState
    extends State<EditFabricatingMaterialModalContent> {
  //Service
  FabricatingMaterialService _fabricatingMaterialService =
      FabricatingMaterialService();
  ColorService _colorService = ColorService();
  late List<Color> _colors = [];
  List<AutoSuggestBoxItem> color_items = <AutoSuggestBoxItem>[];
  //Future
  late Future colorFuture;
  //Text Editing Controller / For Post
  final _kodeBahanBakuInputController = TextEditingController();
  final _namaBahanBakuInputController = TextEditingController();
  final _unitBahanbakuInputController = TextEditingController();
  final _qtyBahanBakuInputController = TextEditingController();
  final _minStockBahanBakuInputController = TextEditingController();
  final _hargaBahanBakuInputController = TextEditingController();
  final _colorController = TextEditingController(text: "");
  int? _selectedColor;

  String? _colorCode = "";
  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

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

    _colors.forEach((element) {
      if (element.colorId == widget.colorId) {
        setState(() {
          _colorController.text = element.colorName!;
        });
      }
    });

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

  updateMaterial() async {
    var response = await _fabricatingMaterialService.updateFabricatingMaterial(
        fabricatingMaterialId: widget.fabricatingMaterialId,
        fabricatingMaterialName: _namaBahanBakuInputController.text,
        colorId: _selectedColor,
        fabricatingMaterialUnit: _unitBahanbakuInputController.text,
        fabricatingMaterialMinimumStock: _minStockBahanBakuInputController.text,
        fabricatingMaterialQty: _qtyBahanBakuInputController.text,
        fabricatingMaterialPrice: _hargaBahanBakuInputController.text);
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

      getColors();
    });
  }

  final GlobalKey globalKey = new GlobalKey();

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _kodeBahanBakuInputController.text = widget.fabricatingMaterialCode;
    _namaBahanBakuInputController.text = widget.fabricatingMaterialName;
    _unitBahanbakuInputController.text = widget.fabricatingMaterialUnit;
    _minStockBahanBakuInputController.text =
        widget.fabricatingMaterialMinimumStock;
    _qtyBahanBakuInputController.text = widget.fabricatingMaterialQty;
    _hargaBahanBakuInputController.text = widget.fabricatingMaterialPrice;
    colorFuture = getColors();
    _selectedColor = widget.colorId;
    // print("==============================="+_colors.toString());
    print("++++++++++++++++++++" + widget.colorId.toString());
    // getColors();
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
                child: TextBox(
                  controller: _kodeBahanBakuInputController,
                  placeholder: "Kode Barang Setengah Jadi",
                  enabled: false,
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
                  placeholder: "Masukkan nama bahan setengah jadi",
                  // //maxLines: 2,
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
            //     // placeholder: _colorController.text,
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
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    // for below version 2 use this
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                    // for version 2 and greater youcan also use this
                    // FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: _hargaBahanBakuInputController,
                  placeholder:
                      "Masukkan harga bahan setengah jadi per satuan unit",
                  // //maxLines: 2,
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
                  placeholder: "Masukkan Kg/Drum/Pcs/Pail/Gram",
                  //maxLines: 2,
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
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    // for below version 2 use this
                    FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                    // for version 2 and greater youcan also use this
                    // FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: _qtyBahanBakuInputController,
                  placeholder:
                      "Masukkan qty sesuai dengan satuan unit yang telah ditentukan",
                  //maxLines: 2,
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
                  controller: _minStockBahanBakuInputController,
                  placeholder:
                      "Masukkan minimum stock yang harus dijaga setiap bulannya",
                  //maxLines: 2,
                ),
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
      data: widget.fabricatingMaterialCode, // Content
      width: 200,
      height: 200,
    );
  }
}
