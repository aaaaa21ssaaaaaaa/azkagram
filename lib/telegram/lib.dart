// ignore_for_file: non_constant_identifier_names

part of azkagram;

class ChatPage extends StatefulWidget {
  final Box box;
  final Box box_client;
  final Tdlib tg;
  final Map chat;
  const ChatPage({Key? key, required this.box, required this.box_client, required this.tg, required this.chat}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late Tdlib tg;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isSendText = false;
  bool isVoice = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      tg = widget.tg;
    });
  }

  @override
  Widget build(BuildContext context) {
    var chat_id = 0;
    if (widget.chat["id"] is int) {
      chat_id = widget.chat["id"];
    }
    var path_image = "";
    var titleBar = "";
    var chat_type = "";
    if (widget.chat["title"] is String) {
      titleBar = widget.chat["title"];
    } else {
      titleBar = widget.chat["first_name"];
      if (widget.chat["first_name"] is String) {
        titleBar += " ${widget.chat["first_name"]}";
      }
    }
    if (widget.chat["type"] is String) {
      chat_type = widget.chat["type"];
    }
    debug(json.encode(widget.chat));

    if (widget.chat["profile_photo"] is Map) {
      if (widget.chat["profile_photo"]["path"] is String == false || (widget.chat["profile_photo"]["path"] as String).isEmpty) {
      } else if ((widget.chat["profile_photo"]["path"] as String).isNotEmpty) {
        path_image = widget.chat["profile_photo"]["path"];
      }
    }
    if (path_image.isNotEmpty) {
      var file = File(path_image);
      if (!file.existsSync()) {
        path_image = "";
        // for (var i = 0; i < chats.length; i++) {
        //   if (chats[i] is Map) {
        //     try {
        //       if (chats[i]["id"] = res["id"]) {
        //         chats[i]["profile_photo"]["path"] = null;

        //         setValue("chats", chats);
        //       }
        //     } catch (e) {}
        //   }
        // }
      }
    }
    return ScaffoldSimulate(
      isShowTopBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                child: const Icon(
                  Iconsax.arrow_left,
                  color: Colors.black,
                  size: 25,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                width: 10.0,
              ),
              InkWell(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                onLongPress: () async {
                  print("photo profile");
                },
                onTap: () async {
                  print("photo profile");
                },
                child: chooseWidget(
                  isMain: path_image.isNotEmpty,
                  main: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(1),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                  second: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      color: Colors.yellow,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(1),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        titleBar[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                titleBar,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              InkWell(
                child: const Icon(
                  Iconsax.more,
                  color: Colors.black,
                  size: 25,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('telegram_client').listenable(),
        builder: (BuildContext ctx, Box box, Widget? wget) {
          return ValueListenableBuilder(
            valueListenable: Hive.box(widget.chat["id"].toString().replaceAll(RegExp(r"^-100"), "")).listenable(),
            builder: (BuildContext ctx, Box box_chat, Widget? wget) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  late Widget widget_app = Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      ...List.generate(50, (index) {
                        return Padding(padding: EdgeInsets.all(10), child: Text("count $index"));
                      }),
                    ],
                  );
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
                      child: widget_app,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0)),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 2)],
        ),
        child: TextField(
          minLines: 1,
          maxLines: 5,
          controller: messageController,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (String? res) {
            if (res!.isEmpty) {
              setState(() {
                isSendText = false;
              });
            } else {
              setState(() {
                isSendText = true;
              });
            }
          },
          decoration: InputDecoration(
            hintText: "Type a message",
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(2.5),
              child: InkWell(
                child: const Icon(
                  Iconsax.happyemoji,
                  color: Colors.pink,
                  size: 25,
                ),
                onTap: () {},
              ),
            ),
            suffixIcon: chooseWidget(
              isMain: isSendText,
              main: Padding(
                padding: const EdgeInsets.all(5),
                child: InkWell(
                  child: const Icon(
                    Iconsax.send1,
                    color: Colors.blue,
                    size: 25,
                  ),
                  onLongPress: (){

                  },
                  onTap: () async {
                    tg.debugRequest(
                      "sendMessage",
                      parameters: {
                        "chat_id": chat_id,
                        "text": messageController.text,
                        "parse_mode": "markdown",
                      },
                      callback: (res) {},
                    );
                  },
                ),
              ),
              second: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: (chat_type == "channel") ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                        child: const Icon(
                          Iconsax.notification,
                          color: Colors.blue,
                          size: 25,
                        ),
                        onTap: () async {},
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      child: const Icon(
                        Iconsax.attach_square,
                        color: Colors.blue,
                        size: 25,
                      ),
                      onTap: () async {
                        if (messageController.text.isNotEmpty) {
                        } else {}
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      child: Icon(
                        (isVoice) ? Iconsax.voice_square : Iconsax.video,
                        color: Colors.blue,
                        size: 25,
                      ),
                      onLongPress: () async {
                        if (isVoice) {
                        } else {}
                      },
                      onTap: () async {
                        setState(() {
                          isVoice = (isVoice) ? false : true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class ProfilePage extends StatefulWidget {
  final Box box;
  final Box box_client;
  final Tdlib tg;
  final Map chat;
  const ProfilePage({Key? key, required this.box, required this.box_client, required this.tg, required this.chat}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late Tdlib tg;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isSendText = false;
  bool isVoice = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      tg = widget.tg;
    });
  }

  @override
  Widget build(BuildContext context) {
    var chat_id = 0;
    if (widget.chat["id"] is int) {
      chat_id = widget.chat["id"];
    }
    var path_image = "";
    var titleBar = "";
    var chat_type = "";
    if (widget.chat["title"] is String) {
      titleBar = widget.chat["title"];
    } else {
      titleBar = widget.chat["first_name"];
      if (widget.chat["first_name"] is String) {
        titleBar += " ${widget.chat["first_name"]}";
      }
    }
    if (widget.chat["type"] is String) {
      chat_type = widget.chat["type"];
    }
    debug(json.encode(widget.chat));

    if (widget.chat["profile_photo"] is Map) {
      if (widget.chat["profile_photo"]["path"] is String == false || (widget.chat["profile_photo"]["path"] as String).isEmpty) {
      } else if ((widget.chat["profile_photo"]["path"] as String).isNotEmpty) {
        path_image = widget.chat["profile_photo"]["path"];
      }
    }
    if (path_image.isNotEmpty) {
      var file = File(path_image);
      if (!file.existsSync()) {
        path_image = "";
        // for (var i = 0; i < chats.length; i++) {
        //   if (chats[i] is Map) {
        //     try {
        //       if (chats[i]["id"] = res["id"]) {
        //         chats[i]["profile_photo"]["path"] = null;

        //         setValue("chats", chats);
        //       }
        //     } catch (e) {}
        //   }
        // }
      }
    }
    return ScaffoldSimulate(
      isShowTopBar: false,
      isShowFrame: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                child: const Icon(
                  Iconsax.arrow_left,
                  color: Colors.black,
                  size: 25,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                width: 10.0,
              ),
              InkWell(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                onLongPress: () async {
                  print("photo profile");
                },
                onTap: () async {
                  print("photo profile");
                },
                child: chooseWidget(
                  isMain: path_image.isNotEmpty,
                  main: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(1),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                  second: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      color: Colors.yellow,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(1),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        titleBar[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                titleBar,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              InkWell(
                child: const Icon(
                  Iconsax.more,
                  color: Colors.black,
                  size: 25,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('telegram_client').listenable(),
        builder: (BuildContext ctx, Box box, Widget? wget) {
          return ValueListenableBuilder(
            valueListenable: Hive.box(widget.chat["id"].toString().replaceAll(RegExp(r"^-100"), "")).listenable(),
            builder: (BuildContext ctx, Box box_chat, Widget? wget) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  late Widget widget_app = Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      ...List.generate(50, (index) {
                        return Padding(padding: EdgeInsets.all(10), child: Text("count $index"));
                      }),
                    ],
                  );
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
                      child: widget_app,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0)),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 2)],
        ),
        child: TextField(
          minLines: 1,
          maxLines: 5,
          controller: messageController,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (String? res) {
            if (res!.isEmpty) {
              setState(() {
                isSendText = false;
              });
            } else {
              setState(() {
                isSendText = true;
              });
            }
          },
          decoration: InputDecoration(
            hintText: "Type a message",
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(2.5),
              child: InkWell(
                child: const Icon(
                  Iconsax.happyemoji,
                  color: Colors.pink,
                  size: 25,
                ),
                onTap: () {},
              ),
            ),
            suffixIcon: chooseWidget(
              isMain: isSendText,
              main: Padding(
                padding: const EdgeInsets.all(5),
                child: InkWell(
                  child: const Icon(
                    Iconsax.send1,
                    color: Colors.blue,
                    size: 25,
                  ),
                  onTap: () async {
                    tg.debugRequest(
                      "sendMessage",
                      parameters: {
                        "chat_id": chat_id,
                        "text": messageController.text,
                        "parse_mode": "markdown",
                      },
                      callback: (res) {},
                    );
                  },
                ),
              ),
              second: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: (chat_type == "channel") ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                        child: const Icon(
                          Iconsax.notification,
                          color: Colors.blue,
                          size: 25,
                        ),
                        onTap: () async {},
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      child: const Icon(
                        Iconsax.attach_square,
                        color: Colors.blue,
                        size: 25,
                      ),
                      onTap: () async {
                        if (messageController.text.isNotEmpty) {
                        } else {}
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      child: Icon(
                        (isVoice) ? Iconsax.voice_square : Iconsax.video,
                        color: Colors.blue,
                        size: 25,
                      ),
                      onLongPress: () async {
                        if (isVoice) {
                        } else {}
                      },
                      onTap: () async {
                        setState(() {
                          isVoice = (isVoice) ? false : true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


