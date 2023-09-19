import 'dart:math';
import 'package:date_format/date_format.dart';
import 'package:example/models/delivery.dart';
import 'package:example/services/delivery.dart';
import 'package:example/services/order.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AddDeliveryModalContent extends StatefulWidget {
  static final GlobalKey<_AddDeliveryModalContentState> globalKey = GlobalKey();
  AddDeliveryModalContent({Key? key}) : super(key: globalKey);

  @override
  State<AddDeliveryModalContent> createState() =>
      _AddDeliveryModalContentState();
}

class _AddDeliveryModalContentState extends State<AddDeliveryModalContent> {
  //Time
  DateTime deliveryDate = DateTime.now();

  //Service
  DeliveryService _deliveryService = DeliveryService();

  //List
  List<Delivery>? existingDelivery;

  //Late
  late Future deliveryFuture;

  //Time
  final now = DateTime.now();

  //Text Editing Controller / For Post
  final _deliveryCodeInputController = TextEditingController();
  final _carPlatInputController = TextEditingController();
  final _senderNameInputController = TextEditingController();
  final _deliveryDescInputController = TextEditingController();

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageOrder = "";
  String _messageTitle = "";
  String _messageContent = "";

  // getTypes() async {
  //   var response = await _typeService.getTypes();
  //   _productTypes = response.data;
  //   print("Get to View: ${_productTypes}");
  //   for (var element in _productTypes) {
  //     print(element.typeName);
  //   }
  // }

  // getColors() async {
  //   var response = await _colorService.getColors();
  //   _colors = response.data;
  //   print("Get to View: ${_colors}");

  //   for (var element in _colors) {
  //     print(element.colorName);
  //     _productColorTreeItems.add(TreeViewItem(
  //         content: Text(element.colorName!), value: element.colorId));
  //   }

  //   _productColorsTree = [
  //     TreeViewItem(
  //         lazy: true,
  //         // Ensure the list is modifiable.

  //         content: const Text("Warna Produk"),
  //         value: -1,
  //         children: _productColorTreeItems)
  //   ];
  // }

  postDelivery(List orders) async {
    var response = await _deliveryService.postDelivery(
        deliveryDate: deliveryDate,
        deliveryCode: _deliveryCodeInputController.text,
        carPlatNumber: _carPlatInputController.text,
        senderName: _senderNameInputController.text,
        deliveryDesc: _deliveryDescInputController.text,
        orders: orders);
    print(response.message);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";

        deliveryFuture = getDelivery();
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
      }

      if (response.data != null) {
        _messageOrder = response.data;
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;
    });
  }

  getDelivery() async {
    var response = await _deliveryService.getDeliveries();
    existingDelivery = response.data;
    _deliveryCodeInputController.text = "DO/ACC/${(formatDate(now, [
          mm,
          yy
        ]).toString())}/${(existingDelivery!.length + 1).toString().padLeft(5, "0")}";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deliveryFuture = getDelivery();
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
              future: deliveryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      controller: _deliveryCodeInputController,
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
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: const Text("Nomor Plat Mobil"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _carPlatInputController,
                placeholder: "Masukkan nomor plat mobil",
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
            Container(child: const Text("Nama Pengirim"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
              child: TextBox(
                controller: _senderNameInputController,
                placeholder: "Masukkan nama pengirim",
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
            Container(child: const Text("Tanggal"), width: 100),
            Container(
              child: const Text(":"),
              width: 10,
            ),
            Expanded(
                child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: DatePicker(
                selected: deliveryDate,
                onChanged: (value) => setState(() => deliveryDate = value),
              ),
            )),
          ],
        ),
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
                maxLines: 2,
                controller: _deliveryDescInputController,
                placeholder: "Masukkan deskripsi tambahan",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
