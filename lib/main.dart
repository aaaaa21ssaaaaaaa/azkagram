// ignore_for_file: non_constant_identifier_names, unused_local_variable, use_build_context_synchronously, duplicate_ignore, dead_code

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:telegram_client/telegram_client.dart';
import 'package:simulate/simulate.dart';
import 'package:path_provider/path_provider.dart';

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
  debug(appSupport.path);
  Box<dynamic> box = await Hive.openBox('telegram_client');
  Widget typePage;
  List users = box.get("users", defaultValue: []);
  for (var i = 0; i < users.length; i++) {
    var loop_data = users[i];
    if (loop_data is Map && loop_data["is_sign"] is bool && loop_data["is_sign"]) {
      Tdlib tg = Tdlib("libtdjson.so", {
        'database_directory': "${appSupport.path}/$i/",
        'files_directory': "${appSupport.path}/$i/",
      });
      tg.on("update", (UpdateTd update) {
        try {
          if (update.raw["@type"] is String) {
            var type = update.raw["@type"];
            if (type == "error") {
              if (RegExp(r"^Can't lock file", caseSensitive: false).hasMatch(update.raw["message"])) {
                print("eror");
                exit(1);
              }
            }
          }
        } catch (e) {
          debug(e);
        }
      });
      await tg.initIsolate();
      typePage = MainPage(box: box, get_me: loop_data, tg: tg);
      return autoSimulateApp(home: typePage, debugShowCheckedModeBanner: false);
    }
  }
  Tdlib tg = Tdlib("libtdjson.so", {
    'database_directory': "${appSupport.path}/${(users.isEmpty) ? 0 : users.length + 1}/",
    'files_directory': "${appSupport.path}/${(users.isEmpty) ? 0 : users.length + 1}/",
  });

  tg.on("update", (UpdateTd update) {
    try {
      if (update.raw["@type"] is String) {
        var type = update.raw["@type"];
        if (type == "error") {
          if (RegExp(r"^Can't lock file", caseSensitive: false).hasMatch(update.raw["message"])) {
            print("eror");
            exit(1);
          }
        }
      }
    } catch (e) {
      debug(e);
    }
  });

  await tg.initIsolate();
  typePage = SignPage(box: box, tg: tg);
  return autoSimulateApp(home: typePage, debugShowCheckedModeBanner: false);
}

class SignPage extends StatefulWidget {
  final Box box;
  final Tdlib tg;
  const SignPage({Key? key, required this.box, required this.tg}) : super(key: key);

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  late Tdlib tg;
  late String status_tdlib = "helo";
  late bool is_no_connection = false;
  dynamic getValue(key, {dynamic defaultValue}) {
    try {
      return widget.box.get(key, defaultValue: defaultValue);
    } catch (e) {
      return defaultValue;
    }
  }

  setValue(key, value) {
    return widget.box.put(key, value);
  }

  late int counts = 0;
  late Map<dynamic, dynamic> state_data;
  final TextEditingController codeTextController = TextEditingController();
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController phoneNumberTextController = TextEditingController();
  final TextEditingController tokenBotTextController = TextEditingController();
  final TextEditingController fullnameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController newpasswordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      tg = widget.tg;
    });
    counts = getValue("count", defaultValue: 0);
    Map<String, dynamic> state_data_sign_default = {"username": "", "password": "", "type_page": "signin", "is_verified": "", "secret_word": "", "words": "", "add_secret_word": []};
    try {
      state_data = getValue("state_data_sign", defaultValue: state_data_sign_default);
    } catch (e) {
      setValue("state_data_sign", state_data_sign_default);
      state_data = state_data_sign_default;
    }
    usernameTextController.text = state_data["username"];
    passwordTextController.text = state_data["password"];
    tg.on("update", (UpdateTd update) {
      try {
        if (update.raw["@type"] is String) {
          var type = update.raw["@type"];

          if (type == "updateAuthorizationState") {
            if (update.raw["authorization_state"] is Map) {
              var authStateType = update.raw["authorization_state"]["@type"];
              if (authStateType == "authorizationStateWaitPhoneNumber") {
                setState(() {
                  state_data["type_page"] = "signin";
                  setValue("state_data_sign", state_data);
                });
              }
              if (authStateType == "authorizationStateWaitCode") {
                setState(() {
                  state_data["type_page"] = "code";
                  setValue("state_data_sign", state_data);
                });
              }
              if (authStateType == "authorizationStateWaitPassword") {
                setState(() {
                  state_data["type_page"] = "password";
                });
              }
              if (authStateType == "authorizationStateReady") {
                setState(() {
                  state_data["type_page"] = "main_menu";
                  setValue("state_data_sign", state_data);
                });
              }

              if (authStateType == "authorizationStateClosing") {}

              if (authStateType == "authorizationStateClosed") {}

              if (authStateType == "authorizationStateLoggingOut") {}
            }
          }
          if (type == "updateConnectionState") {
            if (update.raw["state"]["@type"] == "connectionStateConnecting") {
              if (is_no_connection = false) {
                setState(() {
                  is_no_connection = true;
                });
              }
            }
            if (update.raw["state"]["@type"] == "connectionStateConnecting") {}
          }
          if (type == "error") {
            if (update.raw["message"] == "Unauthorized") {}
          }
        }
      } catch (e) {
        debug(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool is_potrait = MediaQuery.of(context).orientation == Orientation.portrait;
    debug(state_data["type_page"]);
    showPopUp(titleName, valueBody) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(titleName),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(valueBody ?? "Error"),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Mengerti'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    showLoaderDialog() {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ScaffoldSimulate(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    }

    return ScaffoldSimulate(
      backgroundColor: const Color.fromARGB(255, 235, 234, 255),
      body: LayoutBuilder(builder: (BuildContext ctx, constraints) {
        Widget type_sign_page = Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                usernameTextController.clear();
                passwordTextController.clear();
                state_data["type_page"] = "signin";
                setValue("state_data_sign", state_data);
              });
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
        List<Widget> usernameField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: usernameTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }

                    if (!RegExp(r"^[a-z]+$", caseSensitive: false).hasMatch(text)) {
                      return "Tolong isi username dengan benar ya! contoh: azka";
                    }
                    print(text);
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: 'username',
                    labelText: "Username",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.profile_2user,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> phoneNumberField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: phoneNumberTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }

                    if (!RegExp(r"^[0-9]+$", caseSensitive: false).hasMatch(text)) {
                      return "Tolong isi dengan angka ya!";
                    }
                    if (text.length < 5) {
                      return "Tolong isi dengan benar ya!";
                    }
                    print(text);
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: '62xxxxxxxxx',
                    labelText: "Phone Number",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.card,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> tokenBotField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: tokenBotTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }

                    if (!RegExp(r"^[0-9]:.*$", caseSensitive: false).hasMatch(text)) {
                      return "Tolong isi dengan benar ya";
                    }
                    print(text);
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: '1234567890:abbcdefghijklmnopqrstuvwxyz',
                    labelText: "Token Bot",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.card,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> codeField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: codeTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }

                    if (!RegExp(r"^[0-9]+$", caseSensitive: false).hasMatch(text)) {
                      return "Tolong isi dengan benar ya";
                    }
                    if (text.length != 5) {
                      return "Panjang code harus 5";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: '12345',
                    labelText: "Code",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.card,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> passwordField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: passwordTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }
                    if (text == "email") {
                      return 'Please enter a valid email';
                    }
                    print(text);
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: 'password1234',
                    labelText: "Password",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.key,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> newpasswordField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: newpasswordTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }
                    if (text == "email") {
                      return 'Please enter a valid email';
                    }
                    print(text);
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: 'newpassword123',
                    labelText: "New Password",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.key,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> fullNameField() {
          return [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: fullnameTextController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? text) {
                    if (text == null || text.isEmpty) {
                      return 'Can\'t be empty';
                    }
                    if (text == "email") {
                      return 'Please enter a valid email';
                    }
                    print(text);
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0.0),
                    hintText: 'fullname',
                    labelText: "Full Name",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.personalcard,
                      color: Colors.black,
                      size: 18,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }

        List<Widget> titlePage(String title, String description) {
          return [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ];
        }

        if (state_data["type_page"] == "signin") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Phone Number", "Please typing your phone number"),
              const SizedBox(
                height: 20,
              ),
              ...phoneNumberField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      var res = await tg.request("setAuthenticationPhoneNumber", {
                        "phone_number": phoneNumberTextController.text,
                      });

                      debug(res);
                    } catch (e) {
                      debug(e);
                    }
                  },
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Send Code",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signup";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin_token_bot";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn Bot',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state_data["type_page"] == "signup") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Phone Number", "Please typing your phone number"),
              const SizedBox(
                height: 20,
              ),
              ...phoneNumberField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {},
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Send Code",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signup";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin_token_bot";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn Bot',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state_data["type_page"] == "code") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Account Code", "Tolong kirim kode telegram dari Nomor: ${phoneNumberTextController.text}"),
              const SizedBox(
                height: 20,
              ),
              ...codeField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      var res = await tg.request("checkAuthenticationCode", {
                        "code": codeTextController.text,
                      });
                      var get_me = await tg.getMe();
                      List getUsers = getValue("users", defaultValue: []);
                      for (var i = 0; i < getUsers.length; i++) {
                        var loop_data = getUsers[i];
                        if (loop_data is Map && loop_data["id"] == get_me["result"]["id"]) {
                          getUsers[i]["is_sign"] = true;
                          setValue("users", getUsers);
                          Navigator.pushReplacement<void, void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => MainPage(
                                box: widget.box,
                                get_me: loop_data,
                                tg: tg,
                              ),
                            ),
                          );
                          return;
                        }
                      }
                      get_me["result"]["is_sign"] = true;
                      getUsers.add(get_me["result"]);
                      setValue("users", getUsers);

                      Navigator.pushReplacement<void, void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => MainPage(
                            box: widget.box,
                            get_me: get_me,
                            tg: tg,
                          ),
                        ),
                      );

                      return;
                    } catch (e) {
                      debug(e);
                    }
                  },
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Check Code",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signup";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin_token_bot";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn Bot',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state_data["type_page"] == "password") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Account Password", "Tolong isi password telegram dari Nomor: ${phoneNumberTextController.text}"),
              const SizedBox(
                height: 20,
              ),
              ...passwordField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {},
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Check Password",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signup";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin_token_bot";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn Bot',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else if (state_data["type_page"] == "signin_token_bot") {
          type_sign_page = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: is_no_connection,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              ...titlePage("Your Token Bot", "Please confirm your token bot from @botfather"),
              const SizedBox(
                height: 20,
              ),
              ...tokenBotField(),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MaterialButton(
                  onPressed: () async {
                    try {
                      var res = await tg.request("checkAuthenticationBotToken", {
                        "token": tokenBotTextController.text,
                      });
                      var get_me = await tg.getMe();
                      List getUsers = getValue("users", defaultValue: []);
                      for (var i = 0; i < getUsers.length; i++) {
                        var loop_data = getUsers[i];
                        if (loop_data is Map && loop_data["id"] == get_me["result"]["id"]) {
                          getUsers[i]["is_sign"] = true;
                          setValue("users", getUsers);
                          Navigator.pushReplacement<void, void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => MainPage(
                                box: widget.box,
                                get_me: loop_data,
                                tg: tg,
                              ),
                            ),
                          );
                          return;
                        }
                      }
                      get_me["result"]["is_sign"] = true;
                      getUsers.add(get_me["result"]);
                      setValue("users", getUsers);
                      Navigator.pushReplacement<void, void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => MainPage(
                            box: widget.box,
                            get_me: get_me,
                            tg: tg,
                          ),
                        ),
                      );

                      return;
                    } catch (e) {
                      debug(e);
                    }
                  },
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signqr";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'Sign Qr',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          usernameTextController.clear();
                          passwordTextController.clear();
                          state_data["type_page"] = "signin";
                          setValue("state_data_sign", state_data);
                        });
                      },
                      child: const Text(
                        'SignIn User',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }

        if (is_potrait) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
              child: type_sign_page,
            ),
          );
        } else {
          return ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
              child: Container(
                height: constraints.maxHeight / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          "assets/icons/app.png",
                          scale: 5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
                          child: type_sign_page,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
                    child: type_sign_page,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight),
                    child: type_sign_page,
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}

class MainPage extends StatefulWidget {
  final Tdlib tg;
  const MainPage({Key? key, required this.box, required this.get_me, required this.tg}) : super(key: key);
  final Box box;
  final Map get_me;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Tdlib tg;
  late String status_tdlib = "helo";
  late bool is_no_connection = false;

  late Map get_me_data = {"state": "succes", "sign": true, "token": "", "id": "", "username": "", "first_name": "", "last_name": "", "password": "", "is_verified": true, "secret_word": "", "random_secret_word": ""};
  getValue(key, defaultvalue) {
    try {
      return widget.box.get(key, defaultValue: defaultvalue);
    } catch (e) {
      return defaultvalue;
    }
  }

  setValue(key, value) {
    return widget.box.put(key, value);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      tg = widget.tg;
    });

    tg.on("update", (UpdateTd update) async {
      try {
        if (!update.raw.containsKey("@extra")) {}
        if (update.raw["@type"] is String) {
          var type = update.raw["@type"];

          if (type == "updateAuthorizationState") {
            if (update.raw["authorization_state"] is Map) {
              var authStateType = update.raw["authorization_state"]["@type"];
              if (authStateType == "authorizationStateWaitPhoneNumber") {}
              if (authStateType == "authorizationStateWaitCode") {}
              if (authStateType == "authorizationStateWaitPassword") {}
              if (authStateType == "authorizationStateReady") {
                bool is_bot = false;
                if (widget.get_me["is_bot"] is bool) {
                  is_bot = widget.get_me["is_bot"];
                }
                if (!is_bot) {
                  tg.debugRequest("getChats", callback: (res) {
                    if (res["ok"]) {
                      var result = res["result"] as List;
                      setValue("chats", result);
                    }
                  });
                }
              }

              if (authStateType == "authorizationStateClosing") {}

              if (authStateType == "authorizationStateClosed") {}

              if (authStateType == "authorizationStateLoggingOut") {}
            }
          }

          if (type == "updateConnectionState") {
            if (update.raw["state"]["@type"] == "connectionStateConnecting") {
              setState(() {
                is_no_connection = true;
              });
            }
          }

          var update_api = await update.raw_api;
          if (update_api["update_channel_post"] is Map) {
            var msg = update_api["update_channel_post"];
            var chat_id = msg["chat"]["id"];
            var text = msg["text"];
            var is_outgoing = false;
            if (msg["is_outgoing"] is bool && msg["is_outgoing"]) {
              is_outgoing = msg["is_outgoing"];
            }
            if (text is String && text.isNotEmpty) {
              print(text);
              if (RegExp("/ping", caseSensitive: false).hasMatch(text)) {
                return await tg.request("sendMessage", {"chat_id": chat_id, "text": "pong"});
              }
            }
          }
          if (update_api["update_message"] is Map) {
            var msg = update_api["update_message"];
            var text = msg["text"];
            var caption = msg["caption"];
            var msg_id = msg["message_id"];
            var user_id = msg["from"]["id"];
            var chat_id = msg["chat"]["id"];
            var from_id = msg["from"]["id"];
            var is_outgoing = false;
            if (msg["is_outgoing"] is bool && msg["is_outgoing"]) {
              is_outgoing = msg["is_outgoing"];
            }

            if (text is String && text.isNotEmpty) {
              if (RegExp("/ping", caseSensitive: false).hasMatch(text)) {
                return await tg.request("sendMessage", {"chat_id": chat_id, "text": "pong"});
              }
            }
            List chats = getValue("chats", []);
            bool is_found = false;
            for (var i = 0; i < chats.length; i++) {
              var loop_data = chats[i];
              if (loop_data is Map && loop_data["id"] == chat_id) {
                is_found = true;
                chats.removeAt(i);
                Map chat = msg["chat"];
                chats.insert(0, {...chat, "last_message": msg});
                setValue("chats", chats);
              }
            }
            if (!is_found) {
              Map chat = msg["chat"];
              chats.insert(0, {...chat, "last_message": msg});
              setValue("chats", chats);
            }
          }
        }
      } catch (e) {
        debug(e);
      }
    });
  }

  showPopUp([titleName, valueBody]) {
    showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(50),
          child: ScaffoldSimulate(
            backgroundColor: Colors.transparent,
            primary: false,
            body: Builder(builder: (BuildContext context) {
              debug(getValue("count", 1));
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: const Color(0xffF0F8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 100; i++) ...[
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: Text("Hello world"),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            }),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  setValue("count", getValue("count", 0) + 1);
                });
              },
              child: const Icon(Iconsax.close_circle),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /*
    tg.debugRequest("getRemoteFile",
        parameters: {
          "remote_file_id": "AwACAgUAAxkBAAN8YqVN653lIV7Zc8_MszVvUBrw6bkAAmQGAAK4CilV3hjjY2xMfoEkBA",
        },
        is_log: true,
        callback: (res) async {});
    tg.debugRequest(
      "sendVideo",
      parameters: {
        "chat_id": 5299353665,
        "video": "/home/hexaminate/Videos/doc_2022-06-11_12-03-29.mp4",
        "caption": "Hello wrld",
      },
      is_log: true,
    );
    */
    bool is_darkmode = getValue("is_darkmode", false);
    Color color_page = (is_darkmode) ? Colors.black : Colors.white;
    Color color_main = (is_darkmode) ? Colors.white : Colors.black;
    String typePage = getValue("type_page", "home");
    if (typePage == "home") {
      setValue("is_contains_navigation_bar", true);
    }
    String subtypePage = getValue("subtype_page", "brainly");
    int indexPage = getValue("index_page", 0);
    bool is_potrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (typePage == "chat") {
      if (!is_potrait) {
        setValue("is_contains_app_bar", false);
      } else {
        setValue("is_contains_app_bar", true);
      }
    }

    chatAppBar() {
      return Container(
        color: color_page,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: is_potrait,
              child: InkWell(
                child: const Icon(
                  Iconsax.arrow_left,
                  color: Colors.black,
                  size: 25,
                ),
                onTap: () {
                  setState(() {
                    setValue("is_contains_app_bar", false);
                    setValue("is_contains_navigation_bar", true);
                    setValue("type_page", "home");
                    setValue("index_page", 0);
                  });
                },
              ),
            ),
            Visibility(
              visible: is_potrait,
              child: const SizedBox(
                width: 10.0,
              ),
            ),
            /*
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueGrey[100],
                          backgroundImage: AssetImage(""),
                        ),
                        */
            const SizedBox(
              width: 10.0,
            ),
            const Text(
              "Hexa-Assistent",
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    Widget NavigationBar() {
      List items = [
        {"icon": const Icon(Iconsax.message, color: Colors.black), "title": const Text("Message"), "selectedColor": Colors.black, "type": "home"},
        {"icon": const Icon(Iconsax.call, color: Colors.black), "title": const Text("Call"), "selectedColor": Colors.black, "type": "news"},
        {"icon": const Icon(Iconsax.gallery, color: Colors.black), "title": const Text("Chat"), "selectedColor": Colors.black, "type": "chat"},
        {"icon": const Icon(Iconsax.profile_2user, color: Colors.black), "title": const Text("Me"), "selectedColor": Colors.black, "type": "me"}
      ];

      Color? selectedItemColor;
      Color? unselectedItemColor;
      double? selectedColorOpacity;

      onTap(int index) {
        if (items[index]["type"] == "home") {
          setValue("is_contains_app_bar", false);
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "home");
        }
        if (items[index]["type"] == "chat") {
          if (is_potrait) {
            setValue("is_contains_app_bar", true);
          }
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "chat");
        }
        if (items[index]["type"] == "news") {
          setValue("is_contains_app_bar", false);
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "news");
        }
        if (items[index]["type"] == "settings") {
          setValue("is_contains_app_bar", false);
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "settings");
        }
        if (items[index]["type"] == "me") {
          setValue("is_contains_app_bar", false);
          setValue("is_contains_navigation_bar", true);
          setValue("type_page", "me");
        }
        setState(() {
          setValue("index_page", index);
        });
      }

      List<Widget> widgetNavigation = items.map((item) {
        return TweenAnimationBuilder<double>(
          tween: Tween(
            end: items.indexOf(item) == indexPage ? 1.0 : 0.0,
          ),
          curve: Curves.easeOutQuint,
          duration: const Duration(milliseconds: 500),
          builder: (context, t, _) {
            final selectedColor = item["selectedColor"] ?? selectedItemColor ?? Theme.of(context).primaryColor;

            final unselectedColor = item["unselectedColor"] ?? unselectedItemColor ?? Theme.of(context).iconTheme.color;

            return Material(
              color: Color.lerp(
                selectedColor.withOpacity(
                  0.0,
                ),
                selectedColor.withOpacity(
                  selectedColorOpacity ?? 0.1,
                ),
                t,
              ),
              shape: const StadiumBorder(),
              child: InkWell(
                onTap: () async {
                  var index_count = items.indexOf(item);
                  onTap.call(index_count);
                },
                customBorder: const StadiumBorder(),
                focusColor: selectedColor.withOpacity(0.1),
                highlightColor: selectedColor.withOpacity(
                  0.1,
                ),
                splashColor: selectedColor.withOpacity(
                  0.1,
                ),
                hoverColor: selectedColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ) -
                      EdgeInsets.only(
                        right: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ).right *
                            t,
                      ),
                  child: Row(
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          color: Color.lerp(
                            unselectedColor,
                            selectedColor,
                            t,
                          ),
                          size: 24,
                        ),
                        child: items.indexOf(item) == indexPage ? item["activeIcon"] ?? item["icon"] : item["icon"],
                      ),
                      ClipRect(
                        child: SizedBox(
                          height: 20,
                          child: Align(
                            alignment: const Alignment(-0.2, 0.0),
                            widthFactor: t,
                            child: Padding(
                              padding: EdgeInsets.only(left: const EdgeInsets.symmetric(vertical: 10, horizontal: 16).right / 2, right: const EdgeInsets.symmetric(vertical: 10, horizontal: 16).right),
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  color: Color.lerp(selectedColor.withOpacity(0.0), selectedColor, t),
                                  fontWeight: FontWeight.w600,
                                ),
                                child: item["title"],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList();
      return Container(
        constraints: BoxConstraints(
          minWidth: is_potrait ? MediaQuery.of(context).size.width : 0.0,
          minHeight: !is_potrait ? MediaQuery.of(context).size.height : 0.0,
        ),
        padding: const EdgeInsets.all(2),
        child: Material(
          type: MaterialType.card,
          color: Colors.white,
          shadowColor: Colors.black,
          borderRadius: BorderRadius.circular(20),
          child: is_potrait
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widgetNavigation,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: widgetNavigation,
                ),
        ),
      );
    }

    return ScaffoldSimulate(
      backgroundColor: color_page,
      body: ValueListenableBuilder(
        valueListenable: Hive.box('telegram_client').listenable(),
        builder: (context, box, widget) {
          return LayoutBuilder(builder: (BuildContext ctx, constraints) {
            List<Map<String, dynamic>> messages = [
              {"is_outgoing": true, "content": "hello world"},
            ];
            Widget bodyLandscape(Widget mainBody) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(child: NavigationBar()),
                  Expanded(flex: 4, child: mainBody),
                ],
              );
            }

            if (typePage == "home") {
              List chats = getValue("chats", []);
              Widget bodyHome() {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  ...chats.map((res) {
                    var nick_name = "";
                    Map last_message = {};
                    var type_content = "";
                    if (res["last_message"] is Map && (res["last_message"] as Map).isNotEmpty) {
                      last_message = res["last_message"];
                      if (last_message["type_content"] is String && (last_message["type_content"] as String).isNotEmpty) {
                        type_content = last_message["type_content"];
                      }
                    }
                    print(res["id"]);
                    int unread_count = 0;
                    var date = "";
                    if (last_message["date"] is int) {
                      date = last_message["date"].toString();
                    }
                    if (res["type"] == "private") {
                      nick_name = res["first_name"];
                    } else {
                      nick_name = res["title"];
                    }
                    if (res["detail"] is Map) {
                      if (res["detail"]["unread_count"] is int) {
                        unread_count = res["detail"]["unread_count"];
                      }
                    }
                    return InkWell(
                      onTap: () async {
                        debugPopUp(context, res);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                "assets/icons/app.png",
                                scale: 12,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nick_name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    (type_content == "text") ? last_message["text"] : "Unsupported",
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Visibility(
                                      visible: (unread_count != 0),
                                      child: Text(
                                        unread_count.toString(),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ]);
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: is_potrait ? ConstrainedBox(constraints: BoxConstraints(minWidth: constraints.maxHeight, minHeight: constraints.maxHeight), child: bodyHome()) : bodyLandscape(bodyHome()),
              );
            }
            if (typePage == "feature") {}
            if (typePage == "chat") {
              Widget bodyChat = Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    /*
                
            image: DecorationImage(
              image: AssetImage(
                "assets/images/nft.jpg",
              ),
              fit: BoxFit.cover,
            ),
            */
                    ),
                child: Column(
                  children: [
                    Visibility(
                      visible: !is_potrait,
                      child: chatAppBar(),
                    ),
                    Expanded(
                      child: ListView.builder(
                        primary: false,
                        itemCount: messages.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.only(top: 10),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              if (kDebugMode) {
                                print("tap");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                right: 5.0,
                                left: 5.0,
                                bottom: 10,
                              ),
                              child: Align(
                                alignment: (messages[index]["is_outgoing"] ? Alignment.topRight : Alignment.topLeft),
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 45,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: messages[index]["is_outgoing"]
                                        ? BorderRadius.only(
                                            topRight: Radius.circular((messages.length == (index + 1)) ? 0 : 11),
                                            topLeft: const Radius.circular(11),
                                            bottomRight: Radius.circular((index == 0)
                                                ? (messages.length == 1)
                                                    ? 11
                                                    : 0
                                                : 11),
                                            bottomLeft: const Radius.circular(11),
                                          )
                                        : BorderRadius.only(
                                            topRight: const Radius.circular(11),
                                            topLeft: Radius.circular((messages.length == (index + 1)) ? 0 : 11),
                                            bottomRight: const Radius.circular(11),
                                            bottomLeft: Radius.circular((index == 0)
                                                ? (messages.length == 1)
                                                    ? 11
                                                    : 0
                                                : 11),
                                          ),
                                    color: (messages[index]["is_outgoing"] ? Colors.blue[200] : Colors.grey.shade200),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    messages[index]["content"],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(
                        maxHeight: 150.0,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xffFFFFFF),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            spreadRadius: 0,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 100,
                        minLines: 1,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                              child: const Icon(
                                Iconsax.happyemoji,
                                color: Colors.pink,
                                size: 25,
                              ),
                              onTap: () {},
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: InkWell(
                              child: const Icon(
                                Iconsax.send_1,
                                color: Colors.blue,
                                size: 25,
                              ),
                              onTap: () {},
                            ),
                          ),
                          hintText: "Typing here",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onChanged: (text) {},
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              );
              if (is_potrait) {
                return bodyChat;
              } else {
                return bodyLandscape(bodyChat);
              }
            }
            debug(typePage);
            if (typePage == "settings") {
              Widget contentListSettings(String title, {required void Function() onPressed, required IconData icon, double? vertical, double? horizontal}) {
                return MaterialButton(
                  onPressed: onPressed,
                  padding: EdgeInsets.symmetric(horizontal: horizontal ?? 20, vertical: vertical ?? 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(icon),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Iconsax.arrow_right_1),
                    ],
                  ),
                );
              }

              Widget bodyChat = SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: is_potrait,
                      child: chatAppBar(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(1),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            contentListSettings("App Features", onPressed: () {}, icon: Iconsax.message_question),
                            contentListSettings("Settings", onPressed: () {}, icon: Iconsax.setting),
                            Row(
                              children: const [Expanded(child: Divider())],
                            ),
                            contentListSettings("App Features", onPressed: () {}, icon: Iconsax.message_question),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (is_potrait) {
                return bodyChat;
              } else {
                return bodyLandscape(bodyChat);
              }
            }

            if (is_potrait) {
              return Text(
                "hello world",
                style: TextStyle(color: color_main),
              );
            } else {
              return bodyLandscape(Text(
                "hello world",
                style: TextStyle(color: color_main),
              ));
            }
          });
        },
      ),
      floatingActionButton: Visibility(
        visible: true,
        child: Builder(builder: (BuildContext ctx) {
          return FloatingActionButton(
            onPressed: () {},
            child: Icon(Iconsax.activity),
          );
        }),
      ),
      appBar: getValue("is_contains_app_bar", false)
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Builder(builder: (ctx) {
                if (typePage == "chat") {
                  return chatAppBar();
                }
                return Container();
              }),
            )
          : null,
      bottomNavigationBar: Visibility(
        visible: (getValue("is_contains_navigation_bar", true) && is_potrait),
        child: Builder(
          builder: (ctx) {
            return NavigationBar();
            return const Text("keko");
          },
        ),
      ),
    );
  }
}

void debug(Object? data) {
  if (kDebugMode) {
    print(data);
  }
}

void debugFunction(Tdlib tg, {required String method, Map<String, dynamic>? parameters, bool is_sync = false, bool is_raw = false}) async {
  try {
    parameters ??= {};
    if (is_sync) {
      debug(tg.invokeSync(method, parameters));
    } else {
      if (is_raw) {
        debug(await tg.invoke(method, parameters));
      } else {
        debug(await tg.request(method, parameters));
      }
    }
  } catch (e) {
    debug(e);
  }
}

List prettyPrintJson(var input, {bool is_log = false}) {
  try {
    if (input is String) {
    } else {
      input = json.encode(input);
    }
    const JsonDecoder decoder = JsonDecoder();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final dynamic object = decoder.convert(input);
    final dynamic prettyString = encoder.convert(object);
    List result = prettyString.split('\n');
    if (is_log) {
      for (var element in result) {
        debug(element);
      }
    }
    return result;
  } catch (e) {
    debug(e);
    return ["error"];
  }
}

void debugPopUp(BuildContext context, var res, {bool is_log = false}) {
  showDialog(
    context: context,
    builder: (context) {
      List results = prettyPrintJson(res, is_log: is_log);
      return Padding(
        padding: const EdgeInsets.all(50),
        child: ScaffoldSimulate(
          backgroundColor: Colors.transparent,
          primary: false,
          body: Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: const Color(0xffF0F8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(5),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: results.map((e) {
                      return Text(e);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
