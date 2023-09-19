import 'package:example/models/user.dart';
import 'package:example/services/user.dart';
import 'package:example/widgets/user/add_user_modal_content.dart';
import 'package:example/widgets/user/edit_user_modal_content.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as Material;

import '../widgets/page.dart';

List<User>? backupUsers;
List<User>? users;
List<User>? searchedUsers;

class UserPage extends StatefulWidget {
  static final GlobalKey<_UserPageState> globalKey = GlobalKey();
  UserPage({Key? key}) : super(key: globalKey);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with PageMixin {
  bool selected = true;
  String? comboboxValue;
  final UserServices _userService = UserServices();
  String? message;
  String? status;
  late Material.DataTableSource _data = DataTable();
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  removeUser({required int userId, required BuildContext context}) async {
    var response = await _userService.removeUser(userId: userId);
    var message = response.message;
    print(message);
  }

  showRemoveUserModal({
    required int userId,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Hapus Akun'),
        content:
            const Text("Apakah anda yakin akan menghapus data pengguna ini?"),
        actions: [
          Button(
            child: const Text('Tidak'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Ya'),
              onPressed: () async {
                await removeUser(userId: userId, context: context);
                setState(() {
                  usersFuture = getUsers();
                });
                AddUserModalContent.globalKey.currentState!.postUser();
              }),
        ],
      ),
    );
  }

  showEditUserModal({
    required int userId,
    required String name,
    required String userName,
    required String password,
    required String role,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Ubah Akun'),
        content: EditUserModalContent(
          userId: userId,
          name: name,
          userName: userName,
          password: password,
          role: role,
        ),
        actions: [
          Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Ubah'),
              onPressed: () {
                EditUserModalContent.globalKey.currentState!.updatetUser();
                setState(() {
                  usersFuture = getUsers();
                });
              }),
          // FilledButton(
          //     child: const Text('Ubah'),
          //     onPressed: () {
          //       AddUserModalContent.globalKey.currentState!.postUser();
          //     }),
        ],
      ),
    );
  }

  showAddUserModal(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500),
        title: const Text('Tambah Akun Baru'),
        content: AddUserModalContent(),
        actions: [
          Button(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
              child: const Text('Tambah'),
              onPressed: () {
                AddUserModalContent.globalKey.currentState!.postUser();
              }),
        ],
      ),
    );
  }

  late Future usersFuture;

  String selectedFilter = "Cari Berdasarkan";
  List filterList = ["Nama Pengguna"];

  getUsers() async {
    var response = await _userService.getUserAccount();
    print(response);
    users = response.data;
    backupUsers = users;
    print("Get to View Customer: ${users}");
    users?.forEach((element) {
      print(element.userName);
    });
    _data = DataTable();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usersFuture = getUsers();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Akun Pengguna'),
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: TextBox(
                      onChanged: (value) {
                        print(value);
                        if (value == "") {
                          print("Value Kosong");
                          setState(() {
                            usersFuture = getUsers();
                          });
                          print("---Searched User---");
                          users!.forEach((element) {
                            print(element.userName);
                          });
                        } else {
                          if (selectedFilter == "Nama Pengguna") {
                            setState(() {
                              users = backupUsers;
                              users = users!
                                  .where(
                                      (user) => user.userName!.contains(value))
                                  .toList();
                              _data = DataTable();
                              print("---Searched Product---");
                              users!.forEach((element) {
                                print(element.userName);
                              });
                            });
                          } else {
                            setState(() {});
                          }
                        }
                      },
                      controller: searchController,
                      placeholder: 'Search',
                      focusNode: searchFocusNode,
                    )),
                const SizedBox(
                  width: 10,
                ),
                ComboBox(
                    placeholder: const Text("Cari Berdasarkan"),
                    value: selectedFilter,
                    items: filterList.map((e) {
                      return ComboBoxItem(
                        child: Text(e),
                        value: e,
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        print(value);
                        selectedFilter = value.toString();
                        print(selectedFilter);
                      });
                    }),
              ],
            ),
            Container(
                child: Button(
              child: const Text("Tambah Pengguna"),
              onPressed: (() async {
                await showAddUserModal(context);
                setState(() {
                  usersFuture = getUsers();
                });
              }),
              style: ButtonStyle(
                  padding: ButtonState.all(const EdgeInsets.only(
                      top: 10, bottom: 10, right: 15, left: 15))),
            ))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: usersFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.connectionState == ConnectionState.done) {
                child = Material.PaginatedDataTable(
                  columns: const [
                    Material.DataColumn(label: Text('Nama Lengkap')),
                    Material.DataColumn(label: Text('Nama Pengguna')),
                    Material.DataColumn(label: Text('Kata Sandi')),
                    Material.DataColumn(label: Text('Hak Akses')),
                    // Material.DataColumn(label: Text('Refresh Token')),
                    Material.DataColumn(label: Text('Aksi')),
                  ],
                  source: _data,
                  columnSpacing: 80,
                  horizontalMargin: 30,
                  rowsPerPage: 8,
                );
              } else {
                child = const Center(
                  heightFactor: 10,
                  child: ProgressRing(),
                );
              }
              return child;
            })
        // Material.PaginatedDataTable(
        //           columns: const [
        //             Material.DataColumn(label: Text('Nama Lengkap')),
        //             Material.DataColumn(label: Text('Nama Pengguna')),
        //             Material.DataColumn(label: Text('Kata Sandi')),
        //             Material.DataColumn(label: Text('Hak Akses')),
        //             // Material.DataColumn(label: Text('Refresh Token')),
        //             Material.DataColumn(label: Text('Aksi')),
        //           ],
        //           source: _data,
        //           columnSpacing: 80,
        //           horizontalMargin: 30,
        //           rowsPerPage: 8,
        //         )
      ],
    );
  }
}

class DataTable extends Material.DataTableSource {
  final List<Map<String, dynamic>> _data = List.generate(
      users?.length ?? 500,
      (index) => {
            "userId": users?[index].userId,
            "name": users?[index].name,
            "userName": users?[index].userName,
            "password": users?[index].password,
            "role": users?[index].role,
            // "refresh_token":users?[index].refresh_token,
          });

  @override
  Material.DataRow? getRow(int index) {
    return Material.DataRow(cells: [
      Material.DataCell(Text(_data[index]['name'].toString())),
      Material.DataCell(Text(_data[index]['userName'].toString())),
      Material.DataCell(Text(_data[index]['password'].toString())),
      Material.DataCell(Text(_data[index]['role'].toString())),
      // Material.DataCell(Text(_data[index]['refresh_token'].toString())),
      Material.DataCell(Material.Row(
        children: [
          IconButton(
              onPressed: () async {
                UserPage.globalKey.currentState!.showEditUserModal(
                    userId: _data[index]['userId'],
                    name: _data[index]['name'],
                    userName: _data[index]['userName'],
                    password: _data[index]['password'],
                    role: _data[index]['role']);
              },
              icon: const Icon(FluentIcons.edit, size: 24.0)),
          if (_data[index]['role'] != "Super Admin")
            IconButton(
                onPressed: () async {
                  await UserPage.globalKey.currentState!
                      .showRemoveUserModal(userId: _data[index]['userId']);
                },
                icon: const Icon(FluentIcons.delete, size: 24.0))
        ],
      ))
    ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _data.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
