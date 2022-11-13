// ignore_for_file: unused_local_variable, duplicate_ignore

import 'package:azkagram/config/config.dart';
import 'package:azkagram/core/core.dart';
import 'package:azkagram/page/page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simulate/simulate.dart';

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telegram_client/telegram_client.dart';
import "package:path/path.dart" as p;

import 'azkagram.dart';

void main() async {
  initSimulate();
  WidgetsFlutterBinding.ensureInitialized();
  Directory appSupport = await getApplicationSupportDirectory();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  if (kDebugMode) {
    appSupport = Directory(p.join(appSupport.path, "debug"));
  }
  Hive.init(appSupport.path);
  Box box = await Hive.openBox("azkagram", path: appSupport.path);
  final Tdlib tdlib = Tdlib(
    getTdlib(),
    clientOption: {
      'api_id': AzkaGramConfig.telegram_api_id,
      'api_hash': AzkaGramConfig.telegram_api_hash,
      'database_directory': appSupport.path,
      'files_directory': appSupport.path,
      'system_language_code': 'en',
      'new_verbosity_level': 0,
      'application_version': AzkaGramConfig.telegram_version,
      'device_model': AzkaGramConfig.telegram_device_model,
      'system_version': Platform.operatingSystemVersion,
      "database_key": AzkaGramConfig.telegram_database_key,
      ...AzkaGramConfig.telegram_cliet_option,
    },
    delayInvoke: const Duration(milliseconds: 1),
  );
  await tdlib.initIsolate();

  runApp(
    App(
      tdlib: tdlib,
    ),
  );
}

class App extends StatelessWidget {
  final Tdlib tdlib;
  const App({
    super.key,
    required this.tdlib,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Simulate(
        home: AzkaGramApp(
          tdlib: tdlib,
        ),
      ),
    );
  }
}
