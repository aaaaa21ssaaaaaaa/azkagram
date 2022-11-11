library azkagram;

import 'dart:convert';

import 'package:azkagram/database/database.dart';
import 'package:azkagram/page/page.dart';
import 'package:azkagram/widget/widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:galaxeus_lib/galaxeus_lib.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:telegram_client/tdlib/tdlib.dart';
import 'package:hive/hive.dart';

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices {
    return {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.trackpad,
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
    };
  }
}

class AzkaGramApp extends StatefulWidget {
  final Tdlib tdlib;
  const AzkaGramApp({
    super.key,
    required this.tdlib,
  });

  @override
  State<AzkaGramApp> createState() => _AzkaGramAppState();
}

class _AzkaGramAppState extends State<AzkaGramApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("azkagram").listenable(),
      builder: (ctx, Box box, w) {
        late ThemeMode themeMode = ThemeMode.light;
        String getThemeMode = box.get("theme_mode", defaultValue: "auto");
        if (getThemeMode == "auto") {
          themeMode = ThemeMode.light;
        } else if (getThemeMode == "dark") {
          themeMode = ThemeMode.dark;
        }
        return MaterialApp(
          home: AzkaGram(
            tdlib: widget.tdlib,
          ),
          scrollBehavior: MyScrollBehavior(),
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              toolbarHeight: 0,
              color: Colors.white,
              shadowColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.grey,
            primaryColor: Colors.white,
            backgroundColor: const Color(0xFFE5E5E5),
            dividerColor: Colors.white54,
            textTheme: const TextTheme(
              headline1: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              subtitle1: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            appBarTheme: const AppBarTheme(
              toolbarHeight: 0,
              color: Colors.black,
              shadowColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
            ),
            brightness: Brightness.dark,
            primarySwatch: Colors.grey,
            primaryColor: const Color.fromARGB(255, 255, 255, 255),
            backgroundColor: const Color(0xFF212121),
            dividerColor: Colors.black12,
            scaffoldBackgroundColor: Colors.black,
          ),
          themeMode: themeMode,
        );
      },
    );
  }
}

class AzkaGram extends StatefulWidget {
  final Tdlib tdlib;
  const AzkaGram({
    super.key,
    required this.tdlib,
  });

  @override
  State<AzkaGram> createState() => _AzkaGramState();
}

class _AzkaGramState extends State<AzkaGram> {
  late bool isLogin = false;
  @override
  void initState() {
    super.initState();
    task();
  }

  void task() async {
    widget.tdlib.on(widget.tdlib.event_update, callback);
  }

  dynamic callback(UpdateTd update) async {
    final Tdlib tg = widget.tdlib;
    Future(() async {
      if (update.raw["@type"] == "updateAuthorizationState") {
        if (update.raw["authorization_state"] is Map) {
          var authStateType = update.raw["authorization_state"]["@type"];

          await tg.initClient(
            update,
            clientId: update.client_id,
            tdlibParameters: update.client_option,
            isVoid: true,
          );

          if (authStateType == "authorizationStateWaitRegistration") {
            if (update.raw["authorization_state"]["terms_of_service"] is Map) {
              Map terms_of_service = update.raw["authorization_state"]["terms_of_service"] as Map;
              if (terms_of_service["text"] is Map) {}
            }
          }

          if (authStateType == "authorizationStateLoggingOut") {}
          if (authStateType == "authorizationStateClosed") {
            print("close: ${update.client_id}");
          }
          if (authStateType == "authorizationStateWaitPhoneNumber") {
            /// use this if tdlib function not found method
            // await tg.invoke(
            //   "setAuthenticationPhoneNumber",
            //   parameters: {
            //     "phone_number": phone_number,
            //   },
            //   clientId: update.client_id,
            // );

            /// use call api if you can't see official docs
            ///

            /// use this if you wan't login as bot
            // await tg.callApi(
            //   tdlibFunction: TdlibFunction.checkAuthenticationBotToken(
            //     token: "1213141541:samksamksmaksmak",
            //   ),
            //   clientId: update.client_id, // add this if your project more one client
            // );

          }
          if (authStateType == "authorizationStateWaitCode") {
            // await tg.invoke(
            //   "checkAuthenticationCode",
            //   parameters: {
            //     "code": code,
            //   },
            //   clientId: update.client_id,
            // );

          }
          if (authStateType == "authorizationStateWaitPassword") {
            // await tg.invoke(
            //   "checkAuthenticationPassword",
            //   parameters: {
            //     "password": password,
            //   },
            //   clientId: update.client_id,
            // );

          }

          if (authStateType == "authorizationStateReady") {
            Map get_me = await tg.getMe(clientId: update.client_id);
            print("\n\n${jsonToMessage((get_me["result"] as Map), jsonFullMedia: {})}");
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomePage(
      tdlib: widget.tdlib,
      database: Database(),
    );
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Qr(size: 250, data: "Hello world test widgaksasmaksmakskmakmskaskmakmskamskamksmaksmkamskamkset")],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await widget.tdlib.invoke(
            "getCurrentState",
            parameters: {},
            clientId: widget.tdlib.client_id,
          );
          print(json.encode(res));
        },
        child: Icon(Icons.abc),
      ),
    );
  }
}
