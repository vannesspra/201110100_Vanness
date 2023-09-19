import 'dart:math';

import 'package:example/models/color.dart';
import 'package:example/models/product_color.dart';
import 'package:example/models/product_type.dart';
import 'package:example/services/color.dart';
import 'package:example/services/product.dart';
import 'package:example/services/profile.dart';
import 'package:example/services/type.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class AddProfileModalContent extends StatefulWidget {
  static final GlobalKey<_AddProfileModalContentState> globalKey = GlobalKey();

  AddProfileModalContent({
    Key? key,
  }) : super(key: globalKey);

  @override
  State<AddProfileModalContent> createState() => _AddProfileModalContentState();
}

class _AddProfileModalContentState extends State<AddProfileModalContent> {
  //Service
  ProfileService _profileService = ProfileService();

  //Future
  late Future profileFuture;

  //Text Editing Controller / For Post
  final _companyNameInputController = TextEditingController();
  final _companyAddressInputController = TextEditingController();
  final _companyPhoneNumberInputController = TextEditingController();
  final _companyWebsiteInputController = TextEditingController();
  final _companyEmailInputController = TextEditingController();
  final _companyContactPersonInputController = TextEditingController();
  final _companyContactPersonNumberInputController = TextEditingController();

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";

  createProfile() async {
    var response = await _profileService.createProfile(
        companyName: _companyNameInputController.text,
        companyAddress: _companyAddressInputController.text,
        companyEmail: _companyEmailInputController.text,
        companyWebsite: _companyWebsiteInputController.text,
        companyContactPerson: _companyContactPersonInputController.text,
        companyPhoneNumber: _companyPhoneNumberInputController.text,
        companyContactPersonNumber:
            _companyContactPersonNumberInputController.text);
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
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: TextBox(
                controller: _companyNameInputController,
                placeholder: "Nama Perusahaan",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: TextBox(
                controller: _companyAddressInputController,
                placeholder: "Alamat Perusahaan",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: TextBox(
                controller: _companyPhoneNumberInputController,
                placeholder: "No. Tlp Perusahaan",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: TextBox(
                controller: _companyWebsiteInputController,
                placeholder: "Website Perusahaan",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: TextBox(
                controller: _companyEmailInputController,
                placeholder: "Email Perusahaan",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: TextBox(
                controller: _companyContactPersonInputController,
                placeholder: "Ctc Person",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              child: TextBox(
                controller: _companyContactPersonNumberInputController,
                placeholder: "Nomor Ctc Person",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
