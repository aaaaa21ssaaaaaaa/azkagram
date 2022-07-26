part of azkagram;

class SignPage extends StatefulWidget {
  final Box box;
  final Tdlib tg;
  final Box box_client;
  const SignPage({
    Key? key,
    required this.box,
    required this.tg,
    required this.box_client,
  }) : super(key: key);

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  late TextEditingController phone_number_controller = TextEditingController();
  late TextEditingController code_controller = TextEditingController();
  late TextEditingController token_bot_controller = TextEditingController();
  late bool isButtonLoad = false;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("telegram_client").listenable(),
      builder: (context, Box box, widgets) {
        late Map state_sign_page = box.get("state_sign_page", defaultValue: {});
        var qr = box.get("qr", defaultValue: "hello world");
        if (qr is String == false) {
          qr = "Hello world";
        } 
        return ScaffoldSimulate(
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              late List<Widget> pageWidgets = [
                TextButton(
                  onPressed: () async {
                    resetStateAll(box: box, stateSign: {"type": "phone_number"});
                  },
                  child: Text("Reset Page"),
                ),
              ];
              if (state_sign_page["type"] == "phone_number") {
                pageWidgets = [
                  formField(
                    controller: phone_number_controller,
                    prefixIcon: Iconsax.call,
                    labelText: "Phone Number",
                    hintText: "628512345678",
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  datas(box: box, stateSign: state_sign_page),
                  buttonData("Send Code", isLoad: isButtonLoad, onPressed: () async {
                    if (!isButtonLoad) {
                      try {
                        setState(() {
                          isButtonLoad = true;
                        });
                        bool isValidPhoneNumber = await validatePhoneNumber(phone_number_controller, context: context);
                        if (isValidPhoneNumber) {
                          var res = await widget.tg.request("setAuthenticationPhoneNumber", parameters: {
                            "phone_number": phone_number_controller.text,
                          });

                          state_sign_page["phone_number"] = phone_number_controller.text;
                          await box.put("state_sign_page", state_sign_page);
                          setState(() {
                            isButtonLoad = false;
                          });
                        } else {
                          setState(() {
                            isButtonLoad = false;
                          });
                        }
                      } catch (e) {
                        setState(() {
                          isButtonLoad = false;
                        });
                        await CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                        );
                      }
                    }
                  }),
                ];
              }
              if (state_sign_page["type"] == "code") {
                pageWidgets = [
                  formField(
                    controller: code_controller,
                    prefixIcon: Iconsax.key,
                    labelText: "Code",
                    hintText: "12345",
                  ),
                  buttonData("Send Code", isLoad: isButtonLoad, onPressed: () async {
                    if (!isButtonLoad) {
                      try {
                        setState(() {
                          isButtonLoad = true;
                        });
                        bool isValidPhoneNumber = await validatePhoneNumber(phone_number_controller, context: context);
                        if (isValidPhoneNumber) {
                          var res = await widget.tg.request("checkAuthenticationCode", parameters: {
                            "code": code_controller.text,
                          });
                          setState(() {
                            isButtonLoad = false;
                          });
                        } else {
                          setState(() {
                            isButtonLoad = false;
                          });
                        }
                      } catch (e) {
                        setState(() {
                          isButtonLoad = false;
                        });
                        await CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                        );
                      }
                    }
                  }),
                  datas(box: box, stateSign: state_sign_page),
                ];
              }
              if (state_sign_page["type"] == "qr_code") {
                pageWidgets = [
                  qrWidget(qr),
                  datas(box: box, stateSign: state_sign_page),
                ];
              }
              if (state_sign_page["type"] == "token_bot") {
                pageWidgets = [
                  formField(
                    controller: token_bot_controller,
                    prefixIcon: Iconsax.key,
                    labelText: "Token Bot",
                    hintText: "1234567890:aajsaksakosakoskoaskoaskoaoksakos",
                  ),
                  buttonData("Send Token", isLoad: isButtonLoad, onPressed: () async {
                    if (!isButtonLoad) {
                      try {
                        setState(() {
                          isButtonLoad = true;
                        });
                        bool isValid = await validateTokenBot(token_bot_controller, context: context);
                        if (isValid) {
                          var res = await widget.tg.request("checkAuthenticationBotToken", parameters: {
                            "token": token_bot_controller.text,
                          });
                          setState(() {
                            isButtonLoad = false;
                          });
                        } else {
                          setState(() {
                            isButtonLoad = false;
                          });
                        }
                      } catch (e) {
                        print(e);
                        setState(() {
                          isButtonLoad = false;
                        });
                        await CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                        );
                      }
                    }
                  }),
                  datas(box: box, stateSign: state_sign_page),
                ];
              }
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pageWidgets,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void resetStateAll({required Box box, required Map stateSign}) async {
    resetStatePhoneNumber(box: box, stateSign: stateSign);
    resetStateCode(box: box, stateSign: stateSign);
    resetStateTokenBot(box: box, stateSign: stateSign);
  }

  void resetStateTokenBot({required Box box, required Map stateSign}) async {
    setState(() {
      token_bot_controller.clear();
      stateSign["token_bot"] = "";
      box.put("state_sign_page", stateSign);
    });
  }

  void resetStateCode({required Box box, required Map stateSign}) async {
    setState(() {
      code_controller.clear();
      stateSign["code"] = "";
      box.put("state_sign_page", stateSign);
    });
  }

  void resetStatePhoneNumber({required Box box, required Map stateSign}) async {
    setState(() {
      phone_number_controller.clear();
      stateSign["phone_number"] = "";
      box.put("state_sign_page", stateSign);
    });
  }

  Future<bool> validatePhoneNumber(TextEditingController controller, {required BuildContext context}) async {
    var text = controller.text;
    if (text.isEmpty) {
      await CoolAlert.show(
        context: context,
        type: CoolAlertType.info,
        title: "Phone Number",
        text: "Tolong isi phone number terlebih dahulu ya",
      );
      return false;
    }
    if (!RegExp(r"^[0-9]+$", caseSensitive: false).hasMatch(text)) {
      await CoolAlert.show(
        context: context,
        type: CoolAlertType.info,
        title: "Phone Number",
        text: "Format phone_number salah",
      );
      return false;
    }
    return true;
  }

  Future<bool> validateTokenBot(TextEditingController controller, {required BuildContext context}) async {
    var text = controller.text;
    if (text.isEmpty) {
      await CoolAlert.show(
        context: context,
        type: CoolAlertType.info,
        title: "Token Bot",
        text: "Tolong isi token bot terlebih dahulu ya",
      );
      return false;
    }
    if (!RegExp(r"^[0-9]+:.*$", caseSensitive: false).hasMatch(text)) {
      await CoolAlert.show(
        context: context,
        type: CoolAlertType.info,
        title: "Token Bot",
        text: "Format token_bot salah",
      );
      return false;
    }
    return true;
  }

  qrWidget(String text) {
    return Padding(
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
        child: Image(image: QrCodes.widget(text).image),
      ),
    );
  }

  datas({required Box box, required Map stateSign}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () async {
              try {
                await widget.tg.invoke("requestQrCodeAuthentication", parameters: {
                  "other_user_ids": [],
                });
                setState(() {
                  stateSign["type"] = "qr_code";
                  box.put("state_sign_page", stateSign);
                });
              } catch (e) { 
              }
            },
            child: Text("QRCode"),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                stateSign["type"] = "token_bot";
                box.put("state_sign_page", stateSign);
              });
            },
            child: Text("Bot"),
          ),
        ],
      ),
    );
  }

  buttonData(
    String title, {
    bool isLoad = false,
    required void Function()? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: MaterialButton(
        onPressed: onPressed,
        color: Colors.blue,
        height: 50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.only(
          left: 25,
          right: 25,
        ),
        child: Center(
          child: chooseWidget(
            isMain: !isLoad,
            main: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            second: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget formField({
    TextEditingController? controller,
    String? hintText,
    String? labelText,
    String? Function(String?)? validator,
    required IconData prefixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Padding(
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
          controller: controller,
          cursorColor: Colors.black,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0.0),
            hintText: hintText,
            labelText: labelText,
            labelStyle: const TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            prefixIcon: Icon(
              prefixIcon,
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
    );
  }
}
