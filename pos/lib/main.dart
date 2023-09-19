import 'dart:async';
import 'dart:ui';
import 'package:example/screens/activity_log_screen.dart';
import 'package:example/screens/adjustment_screen.dart';
import 'package:example/screens/fabricatingMaterial_screen.dart';
import 'package:example/screens/forms/auto_suggest_box.dart';
import 'package:example/screens/material_purchase_screen.dart';
import 'package:example/screens/material_screen.dart';
import 'package:example/screens/customer_screen.dart';
import 'package:example/screens/delivery_screen.dart';
import 'package:example/screens/material_spending.dart';
import 'package:example/screens/payment_screen.dart';
import 'package:example/screens/production_screen.dart';
import 'package:example/screens/sales_order.dart';
import 'package:example/screens/sales_screen.dart';
import 'package:example/screens/supplier_screen.dart';
import 'package:example/screens/product_color.dart';
import 'package:example/screens/product_type.dart';
import 'package:example/screens/user_screen.dart';
import 'package:example/services/auth.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as Material;
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/link.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/home.dart';
import 'screens/product_screen.dart';
import 'screens/settings.dart';

import 'routes/forms.dart' deferred as forms;
import 'routes/inputs.dart' deferred as inputs;
import 'routes/navigation.dart' deferred as navigation;
import 'routes/surfaces.dart' deferred as surfaces;
import 'routes/theming.dart' deferred as theming;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:flutter/material.dart" as FlutterMaterial;
import 'dart:io';

import 'theme.dart';
import 'widgets/deferred_widget.dart';

const String appTitle = 'Point Of Sales Desktop App';
AuthService _authService = AuthService();

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

class MyCustomScrollBehavior extends ScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  setPathUrlStrategy();

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(755, 545));
      await windowManager.setMinimumSize(const Size(350, 600));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());

  DeferredWidget.preload(forms.loadLibrary);
  DeferredWidget.preload(inputs.loadLibrary);
  DeferredWidget.preload(navigation.loadLibrary);
  DeferredWidget.preload(surfaces.loadLibrary);
  DeferredWidget.preload(theming.loadLibrary);
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  //Controller
  final _userNameInputController = TextEditingController();
  final _passwdInputController = TextEditingController();

  //Post Response Message
  bool _messageStatusOpen = false;
  InfoBarSeverity _messageStatus = InfoBarSeverity.info;
  String _messageTitle = "";
  String _messageContent = "";
  String _errorType = "";

  late bool _passwordVisible;

  login() async {
    var response = await _authService.login(
      userName: _userNameInputController.text,
      password: _passwdInputController.text,
    );
    print(response);
    setState(() {
      if (response.status == "success") {
        _messageStatus = InfoBarSeverity.success;
        _messageTitle = "Sukses";
      } else if (response.status == "error") {
        _messageStatus = InfoBarSeverity.error;
        _messageTitle = "Error";
        _errorType = response.type!;
      }
      _messageContent = response.message!;
      _messageStatusOpen = true;
    });
  }

  @override
  void initState() {
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMaterial.MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: ((context, child) {
        return FlutterMaterial.Scaffold(
          body: Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.jpg',
                  ),
                  Text(
                    "Form Login",
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(
                    width: 400,
                    child: FlutterMaterial.TextField(
                      onTap: () {
                        setState(() {
                          _messageTitle = "";
                          _messageContent = "";
                          _errorType = "";
                        });
                      },
                      controller: _userNameInputController,
                      decoration: FlutterMaterial.InputDecoration(
                        hintText: "Username",
                        errorText:
                            _messageTitle == "Error" && _errorType == "auth"
                                ? _messageContent
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: FlutterMaterial.TextField(
                        onTap: () {
                          setState(() {
                            _messageTitle = "";
                            _messageContent = "";
                            _errorType = "";
                          });
                        },
                        controller: _passwdInputController,
                        obscureText: !_passwordVisible,
                        decoration: FlutterMaterial.InputDecoration(
                            errorText: _messageTitle == "Error" &&
                                    _errorType == "password"
                                ? _messageContent
                                : null,
                            hintText: "Password",
                            suffixIcon: FlutterMaterial.IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible
                                    ? FlutterMaterial.Icons.visibility
                                    : FlutterMaterial.Icons.visibility_off,
                                color: FlutterMaterial.Theme.of(context)
                                    .primaryColorDark,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 400,
                    child: FlutterMaterial.ElevatedButton(
                      onPressed: () async {
                        await login();
                        if (_messageTitle == "Sukses") {
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.info(
                              message: _messageContent,
                            ),
                          );
                          Timer(Duration(seconds: 5), () {
                            Navigator.push(
                                context,
                                FlutterMaterial.MaterialPageRoute(
                                    builder: (_) => MyHomePage()));
                          });
                        }
                      },
                      child: Text("Masuk"),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 400,
                    child: FlutterMaterial.ElevatedButton(
                      style: FlutterMaterial.ButtonStyle(),
                      onPressed: () {
                        exit(0);
                      },
                      child: Text("Keluar"),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          scrollBehavior: MyCustomScrollBehavior(),
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          theme: ThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen() ? 2.0 : 0.0,
            ),
          ),
          locale: appTheme.locale,
          builder: (context, child) {
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: child!,
              ),
            );
          },
          initialRoute: '/',
          routes: {'/': (context) => const LoginForm()},
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  bool value = false;

  int index = 0;

  final viewKey = GlobalKey();

  final key = GlobalKey();
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  void resetSearch() => searchController.clear();
  String get searchValue => searchController.text;
  final List<NavigationPaneItem> originalItems = [
    PaneItem(
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: HomePage(),
    ),
    PaneItem(
      icon: const Icon(
        Material.Icons.add_to_queue_outlined,
        size: 15,
      ),
      title: const Text('User Account'),
      body: UserPage(),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(
        Material.Icons.person_outline,
        size: 15,
      ),
      title: const Text('Customer'),
      body: CustomerPage(),
    ),
    PaneItem(
      icon: const Icon(
        Material.Icons.groups_outlined,
        size: 15,
      ),
      title: const Text('Supplier'),
      body: SupplierPage(),
    ),
    PaneItemSeparator(),
    // PaneItemExpander(
    //     icon: const Icon(
    //       Material.Icons.queue,
    //       size: 15,
    //     ),
    //     title: const Text('Bahan Baku'),
    //     body: BahanBakuPage(),
    //     items: [
    //       // PaneItem(
    //       //   icon: const Icon(
    //       //     Material.Icons.add_to_queue_outlined,
    //       //     size: 15,
    //       //   ),
    //       //   title: const Text('Pembelian Bahan Baku'),
    //       //   body: MaterialPurchasePage(),
    //       // ),
    //       PaneItem(
    //         icon: const Icon(
    //           Material.Icons.remove_from_queue_outlined,
    //           size: 15,
    //         ),
    //         title: const Text('Pengeluaran Bahan Baku'),
    //         body: MaterialSpendingPage(),
    //       ),
    //     ]),
    PaneItem(
      icon: const Icon(
        Material.Icons.color_lens,
        size: 15,
      ),
      title: const Text('Warna'),
      body: ColorPage(),
    ),
    PaneItem(
      icon: const Icon(
        Material.Icons.queue,
        size: 15,
      ),
      title: const Text('Bahan Baku'),
      body: BahanBakuPage(),
    ),
    PaneItem(
      icon: const Icon(
        Material.Icons.queue_sharp,
        size: 15,
      ),
      title: const Text('Bahan Setengah Jadi'),
      body: FabricatingMaterialPage(),
    ),
    PaneItemExpander(
        icon: const Icon(
          Material.Icons.shopping_cart_outlined,
          size: 15,
        ),
        title: const Text('Produk'),
        body: ProductPage(),
        items: [
          // PaneItem(
          //   icon: const Icon(
          //     Material.Icons.add_shopping_cart_outlined,
          //     size: 15,
          //   ),
          //   title: const Text('Produksi Produk'),
          //   body: const ProductionPage(),
          // ),
          // PaneItem(
          //     icon: const Icon(Material.Icons.color_lens),
          //     body: ColorPage(),
          //     title: const Text('Warna Produk')),
          PaneItem(
              icon: const Icon(Material.Icons.type_specimen),
              body: TypePage(),
              title: const Text('Jenis Produk')),
        ]),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(
        Material.Icons.add_shopping_cart_outlined,
        size: 15,
      ),
      title: const Text('Produksi'),
      body: ProductionPage(),
    ),
    PaneItem(
      icon: const Icon(
        Material.Icons.remove_from_queue_outlined,
        size: 15,
      ),
      title: const Text('Pengeluaran'),
      body: MaterialSpendingPage(),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.add_to_shopping_list),
      title: const Text('Sales Order'),
      body: OrderPage(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.delivery_truck),
      title: const Text('Delivery Order'),
      body: const DeliveryPage(),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.invoice),
      title: const Text('Sales'),
      body: SalePage(),
    ),
    PaneItem(
        icon: const Icon(FluentIcons.inbox),
        title: const Text('Purchase'),
        body: MaterialPurchasePage()),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.payment_card),
      title: const Text('Payment'),
      body: PaymentPage(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.edit_table),
      title: const Text('Penyesuaian'),
      body: AdjustmentPage(),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.history),
      title: const Text('Log Activity'),
      body: LogPage(),
    ),
  ];
  final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.settings),
      title: const Text('Settings'),
      body: Settings(),
    ),
    _LinkPaneItemAction(
      icon: const Icon(FluentIcons.open_source),
      title: const Text('Source code'),
      link: 'https://github.com/bdlukaa/fluent_ui',
      body: const SizedBox.shrink(),
    ),
    // TODO: mobile widgets, Scrollbar, BottomNavigationBar, RatingBar
  ];
  late List<NavigationPaneItem> items = originalItems;

  refreshToken() async {
    var res = await _authService.refreshToken();

    // print(Jwt.parseJwt(res.data));
  }

  @override
  void initState() {
    windowManager.addListener(this);
    refreshToken();
    searchController.addListener(() {
      setState(() {
        if (searchValue.isEmpty) {
          items = originalItems;
        } else {
          items = [...originalItems, ...footerItems]
              .whereType<PaneItem>()
              .where((item) {
                assert(item.title is Text);
                final text = (item.title as Text).data!;
                return text.toLowerCase().contains(searchValue.toLowerCase());
              })
              .toList()
              .cast<NavigationPaneItem>();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final theme = FluentTheme.of(context);
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: () {
          if (kIsWeb) {
            return const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            );
          }
          return const DragToMoveArea(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            ),
          );
        }(),
        actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: ToggleSwitch(
              content: const Text('Dark Mode'),
              checked: FluentTheme.of(context).brightness.isDark,
              onChanged: (v) {
                if (v) {
                  appTheme.mode = ThemeMode.dark;
                } else {
                  appTheme.mode = ThemeMode.light;
                }
              },
            ),
          ),
          if (!kIsWeb) const WindowButtons(),
        ]),
      ),
      pane: NavigationPane(
        selected: () {
          // if not searching, return the current index
          if (searchValue.isEmpty) return index;

          final indexOnScreen = items.indexOf(
            [...originalItems, ...footerItems]
                .whereType<PaneItem>()
                .elementAt(index),
          );
          if (indexOnScreen.isNegative) return null;
          return indexOnScreen;
        }(),
        onChanged: (i) {
          // If searching, the values will have different indexes
          if (searchValue.isNotEmpty) {
            final equivalentIndex = [...originalItems, ...footerItems]
                .whereType<PaneItem>()
                .toList()
                .indexOf(items[i] as PaneItem);
            i = equivalentIndex;
          }
          resetSearch();
          setState(() => index = i);
        },
        header: SizedBox(
          height: kOneLineTileHeight,
          child: ShaderMask(
            shaderCallback: (rect) {
              final color = appTheme.color.defaultBrushFor(theme.brightness);
              return LinearGradient(
                colors: [
                  color,
                  color,
                ],
              ).createShader(rect);
            },
            // child: const FlutterLogo(
            //   style: FlutterLogoStyle.horizontal,
            //   size: 80.0,
            //   textColor: Colors.white,
            //   duration: Duration.zero,
            // ),
          ),
        ),
        displayMode: appTheme.displayMode,
        indicator: () {
          switch (appTheme.indicator) {
            case NavigationIndicators.end:
              return const EndNavigationIndicator();
            case NavigationIndicators.sticky:
            default:
              return const StickyNavigationIndicator();
          }
        }(),
        items: items,
        autoSuggestBox: TextBox(
          key: key,
          controller: searchController,
          placeholder: 'Search',
          focusNode: searchFocusNode,
        ),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: searchValue.isNotEmpty ? [] : footerItems,
      ),
      onOpenSearch: () {
        searchFocusNode.requestFocus();
      },
    );
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('Confirm close'),
            content: const Text('Are you sure you want to close this window?'),
            actions: [
              FilledButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.destroy();
                },
              ),
              Button(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _LinkPaneItemAction extends PaneItem {
  _LinkPaneItemAction({
    required super.icon,
    required this.link,
    required super.body,
    super.title,
  });

  final String link;

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    bool? autofocus,
    int? itemIndex,
  }) {
    return Link(
      uri: Uri.parse(link),
      builder: (context, followLink) => super.build(
        context,
        selected,
        followLink,
        displayMode: displayMode,
        showTextOnTop: showTextOnTop,
        itemIndex: itemIndex,
        autofocus: autofocus,
      ),
    );
  }
}
