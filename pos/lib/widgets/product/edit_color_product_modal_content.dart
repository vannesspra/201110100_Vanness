import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/services/color.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class EditColorModalContent extends StatefulWidget {
  static final GlobalKey<_EditColorModalContentState> globalKey = GlobalKey();
  int colorId;
  String colorCode;
  String colorName;
  String colorDesc;
  EditColorModalContent({
    Key? key,
    required this.colorId,
    required this.colorCode,
    required this.colorName,
    required this.colorDesc,
  }) : super(key: globalKey);

  @override
  State<EditColorModalContent> createState() => _EditColorModalContentState();
}

class _EditColorModalContentState extends State<EditColorModalContent> {
  ColorService _colorService = ColorService();

  final _colorCodeInputController = TextEditingController();
  final _colorNameInputController = TextEditingController();
  final _colorDescInputController = TextEditingController();

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  updateColor() async {
    var response = await _colorService.updateColor(
        colorId: widget.colorId,
        colorName: _colorNameInputController.text,
        colorDesc: _colorDescInputController.text);
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

    _colorCodeInputController.text = widget.colorCode;
    _colorNameInputController.text = widget.colorName;
    _colorDescInputController.text = widget.colorDesc;

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
                controller: _colorCodeInputController,
                placeholder: "Kode Warna",
                enabled: false,
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
            Container(child: const Text("Nama"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _colorNameInputController,
                placeholder: "Masukkan warna yang diinginkan",
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
            Container(child: const Text("Deskripsi\nWarna"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _colorDescInputController,
                placeholder: "Masukkan keterangan tambahan",
                maxLines: 2,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}
