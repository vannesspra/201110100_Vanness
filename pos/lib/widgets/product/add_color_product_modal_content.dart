import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/services/color.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class AddColorModalContent extends StatefulWidget {
  static final GlobalKey<_AddColorModalContentState> globalKey = GlobalKey();
  AddColorModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddColorModalContent> createState() => _AddColorModalContentState();
}

class _AddColorModalContentState extends State<AddColorModalContent> {
  //List
  List<Color>? existingColors;

  //Service
  ColorService _colorService = ColorService();

  //Future
  late Future colorFuture;

  //Text Editing Controller / For Post
  final _colorCodeInputController = TextEditingController();
  final _colorNameInputController = TextEditingController();
  final _colorDescInputController = TextEditingController();

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  postColor() async {
    var response = await _colorService.postColor(
      colorCode: _colorCodeInputController.text,
      colorName: _colorNameInputController.text,
      colorDesc: _colorDescInputController.text,
    );
    print(response.message);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        colorFuture = getColors();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;
    });
  }

  getColors() async {
    var response = await _colorService.getColors();
    existingColors = response.data;
    _colorCodeInputController.text =
        "W${(existingColors!.length + 1).toString().padLeft(5, "0")}";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    colorFuture = getColors();
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
              future: colorFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      controller: _colorCodeInputController,
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
            ))
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
