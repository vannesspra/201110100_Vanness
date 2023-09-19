import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/services/color.dart';
import 'package:example/services/customer.dart';
import 'package:example/services/product.dart';
import 'package:example/services/type.dart';
import 'package:example/services/user.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class AddUserModalContent extends StatefulWidget {
  static final GlobalKey<_AddUserModalContentState> globalKey = GlobalKey();
  AddUserModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddUserModalContent> createState() => _AddUserModalContentState();
}

class _AddUserModalContentState extends State<AddUserModalContent> {
  //Service
  UserServices _userService = UserServices();

  //Text Editing Controller / For Post
  final _nameInputController = TextEditingController();
  final _userNameInputController = TextEditingController();
  final _passwordInputController = TextEditingController();

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  postUser() async {
    var response = await _userService.postUser(
      name: _nameInputController.text,
      userName: _userNameInputController.text,
      password: _passwordInputController.text,
      role: selectedRole,
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

  bool checked = false;

  String selectedRole = "";
  List filterList = [
    'Admin',
    'Divisi Penjualan',
    'Divisi Persediaan',
    'Divisi Pembelian'
  ];
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
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama Lengkap"),
              TextBox(
                controller: _nameInputController,
                placeholder: "Nama Lengkap",
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Pengguna"),
              TextBox(
                controller: _userNameInputController,
                placeholder: "Nama Pengguna",
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Password"),
              TextBox(
                controller: _passwordInputController,
                placeholder: "Password",
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hak Akses"),
            ComboBox(
                placeholder: const Text("Hak Akses"),
                value: selectedRole,
                items: filterList.map((e) {
                  return ComboBoxItem(
                    child: Text(e),
                    value: e,
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    print(value);
                    selectedRole = value.toString();
                    print(selectedRole);
                  });
                }),
          ],
        ),
      ],
    );
  }
}
