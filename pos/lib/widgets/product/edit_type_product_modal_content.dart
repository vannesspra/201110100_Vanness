import 'dart:ffi';
import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/services/color.dart';
import 'package:example/services/product.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class EditTypeModalContent extends StatefulWidget {
  static final GlobalKey<_EditTypeModalContentState> globalKey = GlobalKey();
  int typeId;
  String typeCode;
  String typeName;
  String typeDesc;
  EditTypeModalContent({
    Key? key,
    required this.typeId,
    required this.typeCode,
    required this.typeName,
    required this.typeDesc,
  }) : super(key: globalKey);

  @override
  State<EditTypeModalContent> createState() => _EditTypeModalContentState();
}

class _EditTypeModalContentState extends State<EditTypeModalContent> {
  TypeService _typeService = TypeService();

  final _typeCodeInputController = TextEditingController();
  final _typeNameInputController = TextEditingController();
  final _typeDescInputController = TextEditingController();

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  updateType() async {
    var response = await _typeService.updateType(
        typeId: widget.typeId,
        typeName: _typeNameInputController.text,
        typeDesc: _typeDescInputController.text);
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
    super.initState();

    _typeCodeInputController.text = widget.typeCode;
    _typeNameInputController.text = widget.typeName;
    _typeDescInputController.text = widget.typeDesc;

    bool checked = false;
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
                readOnly: true,
                enabled: false,
                controller: _typeCodeInputController,
                placeholder:
                    "Diinput manual sesuai dengan barang apa yang akan diinput",
                // maxLines: 2,
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
            Container(child: const Text("Jenis Produk"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: TextBox(
                  controller: _typeNameInputController,
                  placeholder: "Masukkan jenis produk (Busa,Sadel,Lapis,PLat)",
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
            Container(child: const Text("Deskripsi Jenis Produk"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextBox(
                  controller: _typeDescInputController,
                  placeholder: "Masukkan deskripsi jenis produk",
                  maxLines: 2,
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
