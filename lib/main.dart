// ignore_for_file: non_constant_identifier_names, unused_local_variable, use_build_context_synchronously, duplicate_ignore, dead_code

library azkagram;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:floating_navigation_bar/floating_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:play/play.dart';
import 'package:telegram_client/telegram_client.dart';
import 'package:simulate/simulate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:notify_inapp/notify_inapp.dart';

part 'config.dart';

part 'hexaminate_app/lib.dart';
part 'telegram/lib.dart';
part 'games/lib.dart';
part 'extra_features/lib.dart';
part 'util/lib.dart';
part 'telegram/update.dart';

part "telegram/sign.dart";

bool is_debug = false;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory appSupport = await getApplicationSupportDirectory();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  Hive.init(appSupport.path);
  Box<dynamic> box = await Hive.openBox('telegram_client');

  Box<dynamic> box_hexaminate = await Hive.openBox("hexaminate");
  Audio audio = Audio();
  List users = box.get("users", defaultValue: []);
  for (var i = 0; i < users.length; i++) {
    var loop_data = users[i];
    if (loop_data is Map && loop_data["is_sign"] is bool && loop_data["is_sign"]) {
      var user_path = "${appSupport.path}/client_$i/";
      Box<dynamic> box_client = await Hive.openBox("client", path: user_path);
      Tdlib tg = Tdlib(
        "libtdjson.so",
        clientOption: {
          'api_id': Config.appId,
          'api_hash': Config.apphash,
          "path_application": appSupport.path,
          "index_user": i,
          'database_directory': user_path,
          'files_directory': user_path,
          'user_path': user_path,
        },
        count_request_loop: 1000,
        delayUpdate: Duration(milliseconds: 1),
      );
      tg.on("update", (UpdateTd update) {
        tgUpdate(update, box: box, tg: tg, box_client: box_client, audio: audio);
      });
      await tg.initIsolate();

      return runSimulate(
        home: Telegram(
          box: box,
          tg: tg,
          box_client: box_client,
          get_me: loop_data,
        ),
        debugShowCheckedModeBanner: false,
      );
    }
  }
  var index_user = (users.isEmpty) ? 0 : (users.length + 1);
  var user_path = "${appSupport.path}/client_$index_user/";
  var dir = Directory(user_path);
  if (await dir.exists()) {
    dir.deleteSync(recursive: true);
  }
  Box<dynamic> box_client = await Hive.openBox("client", path: user_path);
  Tdlib tg = Tdlib(
    "libtdjson.so",
    clientOption: {
      'api_id': Config.appId,
      'api_hash': Config.apphash,
      "path_application": appSupport.path,
      "index_user": index_user,
      'database_directory': user_path,
      'files_directory': user_path,
      'user_path': user_path,
    },
    count_request_loop: 1000,
    delayUpdate: Duration(milliseconds: 1),
  );

  tg.on("update", (UpdateTd update) {
    tgUpdate(update, box: box, tg: tg, box_client: box_client, audio: audio);
  });

  await tg.initIsolate();
  return runSimulate(
    home: Telegram(box: box, tg: tg, box_client: box_client),
    debugShowCheckedModeBanner: false,
  );
}

class Telegram extends StatefulWidget {
  final Box box;
  final Tdlib tg;
  final Box box_client;
  final Map? get_me;
  Telegram({Key? key, required this.box, required this.tg, required this.box_client, this.get_me}) : super(key: key);

  @override
  State<Telegram> createState() => _TelegramState();
}

class _TelegramState extends State<Telegram> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("telegram_client").listenable(),
      builder: (context, Box box, widgets) {
        var isSignPage = box.get("isSignPage", defaultValue: true);
        if (isSignPage) {
          return SignPage(box: widget.box, tg: widget.tg, box_client: widget.box_client);
        } else {
          late Map getMe = {};
          if (widget.get_me != null) {
            getMe = widget.get_me ?? {};
          }
          if (getMe.isEmpty) {
            var getDataMe = box.get("getMe", defaultValue: {});
            if (getDataMe is Map && getDataMe.isNotEmpty) {
              getMe = getDataMe;
            }
          }
          return TelegramApp(
            box: widget.box,
            tg: widget.tg,
            box_client: widget.box_client,
            get_me: getMe,
          );
        }
      },
    );
  }
}
