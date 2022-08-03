// ignore_for_file: non_constant_identifier_names

part of azkagram;

class TelegramApp extends StatefulWidget {
  final Box box;
  final Map get_me;
  final Tdlib tg;
  final Box box_client;
  const TelegramApp({
    Key? key,
    required this.box,
    required this.get_me,
    required this.tg,
    required this.box_client,
  }) : super(key: key);

  @override
  State<TelegramApp> createState() => _TelegramAppState();
}

class _TelegramAppState extends State<TelegramApp> {
  late int count = 0;
  ScrollController scrollController = ScrollController();
  late bool isShowBottomBar = true;
  late int indexPage = 0;
  late Map stateData = {};
  @override
  void initState() {
    super.initState();
  }

  Notify notify = Notify();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("telegram_client").listenable(),
      builder: (context, Box box, widgets) {
        return ValueListenableBuilder(
          valueListenable: Hive.box("client").listenable(),
          builder: (context, Box box_client, widgets) {
            late List chats = [];
            try {
              chats = box_client.get("chats", defaultValue: []);
            } catch (e) {}

            return ScaffoldSimulate(
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: const AlwaysScrollableScrollPhysics()),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pageChats(chats: chats),
                  ),
                ),
              ),
              bottomNavigationBar: NavigationBar(box: widget.box),
            );
          },
        );
      },
    );
  }

  List<Widget> pageChats({required List<dynamic> chats}) {
    try {
      return [pageHome(chats: chats)][indexPage];
    } catch (e) {
      return [
        Center(
          child: Text("error: ${e.toString()}"),
        )
      ];
    }
  }

  List<Widget> pageHome({required List<dynamic> chats}) {
    return [
      Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Text(
              Config.nameApplication,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTap: () async {},
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Iconsax.search_normal,
                ),
              ),
            ),
          ],
        ),
      ),
      ...pageChat(ignoreTypes: ["channel"], title: "Channels", chats: chats, isHorizontal: true),
      ...pageChat(ignoreTypes: ["channel"], title: "Chats", chats: chats),
    ];
  }

  List<Widget> pageChat({required List<String> ignoreTypes, required String title, required List chats, bool isHorizontal = false}) {
    late List<Widget> widgets = [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
    if (chats.isEmpty) {
      return [];
    }
    late List<Widget> resChats = [];
    if (isHorizontal) {
      resChats.add(SizedBox(
        height: 250.0,
        child: Builder(builder: (ctx) {
          var chatChannels = chats.where((res) {
            if (res["type"] == "channel") {
              return true;
            }
            return false;
          }).toList();
          return ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: chatChannels.length,
            itemBuilder: (BuildContext context, int index) {
              late Map res = chatChannels[index];
              late String nick_name = "";
              late String member_count = "";
              late String path_image = "";
              late Map profile_photo = {};
              if (chatChannels[index]["title"] is String) {
                nick_name = chatChannels[index]["title"];
              }
              if (chatChannels[index]["detail"] is Map) {
                if (chatChannels[index]["detail"]["member_count"] is int) {
                  member_count = chatChannels[index]["detail"]["member_count"].toString();
                }
              }
              if (res["profile_photo"] is Map) {
                profile_photo = res["profile_photo"];
                if (profile_photo["path"] is String && (profile_photo["path"] as String).isNotEmpty) {
                  path_image = profile_photo["path"];
                  if (File(path_image).existsSync()) {
                    path_image = "";
                  }
                }
              }
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 250,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
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
                  child: Stack(
                    children: [
                      profilePictures(profile_photo: profile_photo, path_image: path_image, nick_name: nick_name, tg: widget.tg, clientId: widget.tg.client_id, height: 250, width: 150),
                      Positioned(
                        top: 15,
                        left: 15,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const ui.Color.fromARGB(198, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "live",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const ui.Color.fromARGB(197, 131, 131, 131),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  member_count,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: double.infinity,
                              maxHeight: double.infinity,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const ui.Color.fromARGB(197, 136, 136, 136),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              nick_name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ));
    } else {
      resChats = chats.where((res) {
        if (ignoreTypes.contains(res["type"])) {
          return false;
        }
        return true;
      }).map((res) {
        var nick_name = "undefined";

        if (res["type"] == "private") {
          if (res["first_name"] is String && (res["first_name"] as String).isNotEmpty) {
            nick_name = res["first_name"];
          }
        } else {
          if (res['title'] is String && (res["title"] as String).isNotEmpty) {
            nick_name = res["title"];
          }
        }

        late Map last_message = {};
        var type_content = "";
        late String message = "";
        late bool isFile = false;
        late String path_image = "";
        late String content = "";
        late Map profile_photo = {};
        if (res["profile_photo"] is Map) {
          profile_photo = res["profile_photo"];
          if (profile_photo["path"] is String && (profile_photo["path"] as String).isNotEmpty) {
            path_image = profile_photo["path"];
            if (File(path_image).existsSync()) {
              path_image = "";
            }
          }
        }
        if (res["last_message"] is Map && (res["last_message"] as Map).isNotEmpty) {
          last_message = res["last_message"];
          if (last_message["type_content"] is String && (last_message["type_content"] as String).isNotEmpty) {
            type_content = last_message["type_content"];
          }
        }
        if (last_message["text"] is String && (last_message["text"] as String).isNotEmpty) {
          message = last_message["text"];
        }
        if (last_message["caption"] is String && (last_message["caption"] as String).isNotEmpty) {
          message = last_message["caption"];
        }

        if (last_message["caption"] is String) {
          isFile = true;
          message = last_message["caption"];
        }
        int unread_count = 0;
        var date = "";
        late String chat_type = "private";
        if (res["type"] is String) {
          chat_type = res["type"];
        }
        if (last_message["date"] is int) {
          date = last_message["date"].toString();
        }
        if (res["detail"] is Map) {
          if (res["detail"]["unread_count"] is int) {
            unread_count = res["detail"]["unread_count"];
          }
        }
        return Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            onLongPress: () async {
              prettyPrintJson(res);
            },
            onTap: () async {
              prettyPrintJson(res);
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
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
                  Visibility(
                    visible: isFile,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              color: randomColors(),
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
                          Positioned(
                            top: 15,
                            right: 15,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: double.infinity,
                                maxHeight: double.infinity,
                              ),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const ui.Color.fromARGB(199, 158, 158, 158),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                chat_type,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                        onLongPress: () async {
                          print("photo profile");
                        },
                        onTap: () async {
                          print("photo profile");
                        },
                        child: profilePictures(
                          profile_photo: profile_photo,
                          path_image: path_image,
                          nick_name: nick_name,
                          tg: widget.tg,
                          clientId: widget.tg.client_id,
                          height: 50,
                          width: 50,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                nick_name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                (date is int) ? date.toString() : "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                ),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const ui.Color.fromARGB(198, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  chat_type,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity,
                                ),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const ui.Color.fromARGB(198, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  (last_message["is_outgoing"] is bool && last_message["is_outgoing"]) ? "Outgoing" : "Incomming",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: message.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: ui.Color.fromARGB(255, 48, 48, 48),
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList();
    }
    if (resChats.isEmpty) {
      return [];
    }
    widgets.addAll(resChats);

    return widgets;
  }

  Widget profilePictures({required Map profile_photo, required String path_image, required String nick_name, required Tdlib tg, required int clientId, required double height, required double width}) {
    return FutureBuilder(
      future: (profile_photo.isNotEmpty)
          ? tg.appRequest("getRemoteFile",
              parameters: {
                "remote_file_id": profile_photo["file_id"],
              },
              clientId: clientId)
          : null,
      builder: (context, snapshot) {
        late Widget child = const CircularProgressIndicator();
        if (snapshot.connectionState == ConnectionState.waiting) {
          child = const CircularProgressIndicator();
        }
        if (snapshot.hasError) {}
        if (snapshot.hasData) {
          var getRemoteFile = snapshot.data;
          if (getRemoteFile is Map) {
            if (getRemoteFile["local"]["path"] is String && (getRemoteFile["local"]["path"] as String).isEmpty) {
              if (getRemoteFile["local"]["is_downloading_active"] == false) {
                return FutureBuilder(
                  future: tg.appRequest("downloadFile", parameters: {"file_id": getRemoteFile["id"], "priority": 1}, clientId: clientId),
                  builder: (context, snapshot) {
                    late Widget child = const CircularProgressIndicator();
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      child = const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {}
                    if (snapshot.hasData) {
                      var getRemoteFile = snapshot.data;
                      if (getRemoteFile is Map) {
                        if (getRemoteFile["local"]["path"] is String && (getRemoteFile["local"]["path"] as String).isEmpty) {
                          if (getRemoteFile["local"]["is_downloading_active"] == false) {}
                        }
                        if (getRemoteFile["local"]["is_downloading_completed"] == true) {
                          path_image = getRemoteFile["local"]["path"];
                        }
                      }
                      child = Text(
                        nick_name[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }
                    return profilePicture(path_image: path_image, child: child, height: height, width: width);
                  },
                );
              }
            }
            if (getRemoteFile["local"]["is_downloading_completed"] == true) {
              path_image = getRemoteFile["local"]["path"];
            }
          }
        }
        child = Text(
          nick_name[0],
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        );
        return profilePicture(path_image: path_image, child: child, height: height, width: width);
      },
    );
  }

  Widget profilePicture({required String path_image, required Widget child, required double width, required double height}) {
    if (File(path_image).existsSync() == false) {
      path_image = "";
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: randomColors(),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        image: (path_image.isNotEmpty)
            ? DecorationImage(
                fit: BoxFit.cover,
                image: Image.file(File(path_image)).image,
                onError: (errDetails, error) {},
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Visibility(
        visible: path_image.isEmpty,
        child: Center(child: child),
      ),
    );
  }

  Widget NavigationBar({required Box box}) {
    List items = [
      {"icon": const Icon(Iconsax.message, color: Colors.black), "title": const Text("Message"), "selectedColor": Colors.black, "type": "home"},
      {"icon": const Icon(Iconsax.call, color: Colors.black), "title": const Text("Call"), "selectedColor": Colors.black, "type": "news"},
      {"icon": const Icon(Iconsax.gallery, color: Colors.black), "title": const Text("Chat"), "selectedColor": Colors.black, "type": "chat"},
      {"icon": const Icon(Iconsax.profile_2user, color: Colors.black), "title": const Text("Me"), "selectedColor": Colors.black, "type": "me"}
    ];

    Color? selectedItemColor;
    Color? unselectedItemColor;
    double? selectedColorOpacity;

    onTap(int index) async { 
      if (items[index]["type"] == "home") {
        stateData.clear();
        await box.put("is_contains_app_bar", false);
        await box.put("is_contains_navigation_bar", true);
        await box.put("type_page", "home");
      }
      if (items[index]["type"] == "chat") {
        stateData.clear();
        // if (is_potrait) {
        //   setValue("is_contains_app_bar", true);
        // }
        // setValue("is_contains_navigation_bar", true);
        // setValue("type_page", "chat");
      }
      if (items[index]["type"] == "news") {
        stateData.clear();
        await box.put("is_contains_app_bar", false);
        await box.put("is_contains_navigation_bar", true);
        await box.put("type_page", "news");
      }
      if (items[index]["type"] == "settings") {
        stateData.clear();
        await box.put("is_contains_app_bar", false);
        await box.put("is_contains_navigation_bar", true);
        await box.put("type_page", "settings");
      }
      if (items[index]["type"] == "me") {
        stateData.clear();
        await box.put("is_contains_app_bar", false);
        await box.put("is_contains_navigation_bar", true);
        await box.put("type_page", "me");
      }
      setState(() {
        indexPage = index;
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
        minWidth: (MediaQuery.of(context).orientation == Orientation.portrait) ? MediaQuery.of(context).size.width : 0.0,
        minHeight: !(MediaQuery.of(context).orientation == Orientation.portrait) ? MediaQuery.of(context).size.height : 0.0,
      ),
      padding: const EdgeInsets.all(2),
      child: Material(
        type: MaterialType.card,
        color: Colors.white,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(20),
        child: chooseWidget(
          isMain: (MediaQuery.of(context).orientation == Orientation.portrait),
          main: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widgetNavigation,
          ),
          second: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: widgetNavigation,
          ),
        ),
      ),
    );
  }
}

// class ChatPage extends StatefulWidget {
//   final Box box;
//   final Box box_client;
//   final Tdlib tg;
//   final Map chat;
//   const ChatPage({Key? key, required this.box, required this.box_client, required this.tg, required this.chat}) : super(key: key);

//   @override
//   ChatPageState createState() => ChatPageState();
// }

// class ChatPageState extends State<ChatPage> {
//   late Tdlib tg;
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//   bool isSendText = false;
//   bool isVoice = true;

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       tg = widget.tg;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var chat_id = 0;
//     if (widget.chat["id"] is int) {
//       chat_id = widget.chat["id"];
//     }
//     var path_image = "";
//     var titleBar = "";
//     var chat_type = "";
//     if (widget.chat["title"] is String) {
//       titleBar = widget.chat["title"];
//     } else {
//       titleBar = widget.chat["first_name"];
//       if (widget.chat["first_name"] is String) {
//         titleBar += " ${widget.chat["first_name"]}";
//       }
//     }
//     if (widget.chat["type"] is String) {
//       chat_type = widget.chat["type"];
//     }
//     debug(json.encode(widget.chat));

//     if (widget.chat["profile_photo"] is Map) {
//       if (widget.chat["profile_photo"]["path"] is String == false || (widget.chat["profile_photo"]["path"] as String).isEmpty) {
//       } else if ((widget.chat["profile_photo"]["path"] as String).isNotEmpty) {
//         path_image = widget.chat["profile_photo"]["path"];
//       }
//     }
//     if (path_image.isNotEmpty) {
//       var file = File(path_image);
//       if (!file.existsSync()) {
//         path_image = "";
//         // for (var i = 0; i < chats.length; i++) {
//         //   if (chats[i] is Map) {
//         //     try {
//         //       if (chats[i]["id"] = res["id"]) {
//         //         chats[i]["profile_photo"]["path"] = null;

//         //         setValue("chats", chats);
//         //       }
//         //     } catch (e) {}
//         //   }
//         // }
//       }
//     }
//     return ScaffoldSimulate(
//       isShowTopBar: false,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: SafeArea(
//           minimum: const EdgeInsets.all(10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               InkWell(
//                 child: const Icon(
//                   Iconsax.arrow_left,
//                   color: Colors.black,
//                   size: 25,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               const SizedBox(
//                 width: 10.0,
//               ),
//               InkWell(
//                 borderRadius: BorderRadius.all(Radius.circular(25)),
//                 onLongPress: () async {
//                   print("photo profile");
//                 },
//                 onTap: () async {
//                   print("photo profile");
//                 },
//                 child: chooseWidget(
//                   isMain: path_image.isNotEmpty,
//                   main: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.all(Radius.circular(25)),
//                       image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(1),
//                           spreadRadius: 1,
//                           blurRadius: 7,
//                           offset: const Offset(0, 3), // changes position of shadow
//                         ),
//                       ],
//                     ),
//                   ),
//                   second: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.all(Radius.circular(25)),
//                       color: Colors.yellow,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(1),
//                           spreadRadius: 1,
//                           blurRadius: 7,
//                           offset: const Offset(0, 3), // changes position of shadow
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         titleBar[0],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 width: 10.0,
//               ),
//               Text(
//                 titleBar,
//                 style: const TextStyle(
//                   color: Colors.blueGrey,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               Spacer(),
//               InkWell(
//                 child: const Icon(
//                   Iconsax.more,
//                   color: Colors.black,
//                   size: 25,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: Hive.box('telegram_client').listenable(),
//         builder: (BuildContext ctx, Box box, Widget? wget) {
//           return ValueListenableBuilder(
//             valueListenable: Hive.box(widget.chat["id"].toString().replaceAll(RegExp(r"^-100"), "")).listenable(),
//             builder: (BuildContext ctx, Box box_chat, Widget? wget) {
//               late List msg = box_chat.get("msg", defaultValue: []);
//               return LayoutBuilder(
//                 builder: (BuildContext context, BoxConstraints constraints) {
//                   late Widget widget_app = Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Flexible(
//                         child: MediaQuery.removePadding(
//                           context: context,
//                           removeTop: true,
//                           child: ListView.builder(
//                             controller: scrollController,
//                             physics: const BouncingScrollPhysics(
//                               parent: AlwaysScrollableScrollPhysics(),
//                             ),
//                             reverse: true,
//                             itemCount: msg.length,
//                             itemBuilder: (context, index) {
//                               var res = msg[index];
//                               bool isOutgoing = false;
//                               Alignment aligment = Alignment.centerLeft;
//                               if (res["is_outgoing"] is bool && res["is_outgoing"]) {
//                                 isOutgoing = true;
//                                 aligment = Alignment.centerRight;
//                               }
//                               var type_content = "";
//                               var message = "";
//                               if (res["type_content"] == "text") {
//                                 type_content = res["type_content"];
//                               }
//                               if (type_content == "text") {
//                                 message = res["text"];
//                               }
//                               return Align(
//                                 alignment: aligment,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(10),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       boxShadow: [
//                                         BoxShadow(color: Colors.black38, blurRadius: 2),
//                                       ],
//                                       borderRadius: isOutgoing
//                                           ? const BorderRadius.only(
//                                               topRight: Radius.circular(11),
//                                               topLeft: Radius.circular(11),
//                                               bottomRight: Radius.circular(0),
//                                               bottomLeft: Radius.circular(11),
//                                             )
//                                           : const BorderRadius.only(
//                                               topRight: Radius.circular(11),
//                                               topLeft: Radius.circular(11),
//                                               bottomRight: Radius.circular(11),
//                                               bottomLeft: Radius.circular(0),
//                                             ),
//                                     ),
//                                     padding: const EdgeInsets.all(10),
//                                     child: Text(message),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.all(Radius.circular(0)),
//                             boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 2)],
//                           ),
//                           child: TextField(
//                             minLines: 1,
//                             maxLines: 5,
//                             controller: messageController,
//                             textCapitalization: TextCapitalization.sentences,
//                             onChanged: (String? res) {
//                               if (res!.isEmpty) {
//                                 setState(() {
//                                   isSendText = false;
//                                 });
//                               } else {
//                                 setState(() {
//                                   isSendText = true;
//                                 });
//                               }
//                             },
//                             decoration: InputDecoration(
//                               hintText: "Type a message",
//                               hintStyle: const TextStyle(
//                                 color: Colors.grey,
//                               ),
//                               border: InputBorder.none,
//                               prefixIcon: Padding(
//                                 padding: const EdgeInsets.all(2.5),
//                                 child: InkWell(
//                                   child: const Icon(
//                                     Iconsax.happyemoji,
//                                     color: Colors.pink,
//                                     size: 25,
//                                   ),
//                                   onTap: () {},
//                                 ),
//                               ),
//                               suffixIcon: chooseWidget(
//                                 isMain: isSendText,
//                                 main: Padding(
//                                   padding: const EdgeInsets.all(5),
//                                   child: InkWell(
//                                     child: const Icon(
//                                       Iconsax.send1,
//                                       color: Colors.blue,
//                                       size: 25,
//                                     ),
//                                     onLongPress: () {},
//                                     onTap: () async {
//                                       tg.debugRequest(
//                                         "sendMessage",
//                                         parameters: {
//                                           "chat_id": chat_id,
//                                           "text": messageController.text,
//                                           "parse_mode": "markdown",
//                                         },
//                                         callback: (res) {},
//                                       );
//                                       setState(() {
//                                         messageController.clear();
//                                       });
//                                     },
//                                   ),
//                                 ),
//                                 second: Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Visibility(
//                                       visible: (chat_type == "channel") ? true : false,
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                                         child: InkWell(
//                                           child: const Icon(
//                                             Iconsax.notification,
//                                             color: Colors.blue,
//                                             size: 25,
//                                           ),
//                                           onTap: () async {},
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                                       child: InkWell(
//                                         child: const Icon(
//                                           Iconsax.attach_square,
//                                           color: Colors.blue,
//                                           size: 25,
//                                         ),
//                                         onTap: () async {
//                                           if (messageController.text.isNotEmpty) {
//                                           } else {}
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                   return widget_app;
//                   return SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(
//                       parent: BouncingScrollPhysics(),
//                     ),
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
//                       child: widget_app,
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class ProfilePage extends StatefulWidget {
//   final Box box;
//   final Box box_client;
//   final Tdlib tg;
//   final Map chat;
//   const ProfilePage({Key? key, required this.box, required this.box_client, required this.tg, required this.chat}) : super(key: key);

//   @override
//   ProfilePageState createState() => ProfilePageState();
// }

// class ProfilePageState extends State<ProfilePage> {
//   late Tdlib tg;
//   final TextEditingController messageController = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//   bool isSendText = false;
//   bool isVoice = true;

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       tg = widget.tg;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var chat_id = 0;
//     if (widget.chat["id"] is int) {
//       chat_id = widget.chat["id"];
//     }
//     var path_image = "";
//     var titleBar = "";
//     var chat_type = "";
//     if (widget.chat["title"] is String) {
//       titleBar = widget.chat["title"];
//     } else {
//       titleBar = widget.chat["first_name"];
//       if (widget.chat["first_name"] is String) {
//         titleBar += " ${widget.chat["first_name"]}";
//       }
//     }
//     if (widget.chat["type"] is String) {
//       chat_type = widget.chat["type"];
//     }
//     debug(json.encode(widget.chat));

//     if (widget.chat["profile_photo"] is Map) {
//       if (widget.chat["profile_photo"]["path"] is String == false || (widget.chat["profile_photo"]["path"] as String).isEmpty) {
//       } else if ((widget.chat["profile_photo"]["path"] as String).isNotEmpty) {
//         path_image = widget.chat["profile_photo"]["path"];
//       }
//     }
//     if (path_image.isNotEmpty) {
//       var file = File(path_image);
//       if (!file.existsSync()) {
//         path_image = "";
//         // for (var i = 0; i < chats.length; i++) {
//         //   if (chats[i] is Map) {
//         //     try {
//         //       if (chats[i]["id"] = res["id"]) {
//         //         chats[i]["profile_photo"]["path"] = null;

//         //         setValue("chats", chats);
//         //       }
//         //     } catch (e) {}
//         //   }
//         // }
//       }
//     }
//     return ScaffoldSimulate(
//       isShowTopBar: false,
//       isShowFrame: true,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: SafeArea(
//           minimum: const EdgeInsets.all(10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               InkWell(
//                 child: const Icon(
//                   Iconsax.arrow_left,
//                   color: Colors.black,
//                   size: 25,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               const SizedBox(
//                 width: 10.0,
//               ),
//               InkWell(
//                 borderRadius: BorderRadius.all(Radius.circular(25)),
//                 onLongPress: () async {
//                   print("photo profile");
//                 },
//                 onTap: () async {
//                   print("photo profile");
//                 },
//                 child: chooseWidget(
//                   isMain: path_image.isNotEmpty,
//                   main: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.all(Radius.circular(25)),
//                       image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(1),
//                           spreadRadius: 1,
//                           blurRadius: 7,
//                           offset: const Offset(0, 3), // changes position of shadow
//                         ),
//                       ],
//                     ),
//                   ),
//                   second: Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: const BorderRadius.all(Radius.circular(25)),
//                       color: Colors.yellow,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(1),
//                           spreadRadius: 1,
//                           blurRadius: 7,
//                           offset: const Offset(0, 3), // changes position of shadow
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         titleBar[0],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(
//                 width: 10.0,
//               ),
//               Text(
//                 titleBar,
//                 style: const TextStyle(
//                   color: Colors.blueGrey,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               Spacer(),
//               InkWell(
//                 child: const Icon(
//                   Iconsax.more,
//                   color: Colors.black,
//                   size: 25,
//                 ),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: Hive.box('telegram_client').listenable(),
//         builder: (BuildContext ctx, Box box, Widget? wget) {
//           return ValueListenableBuilder(
//             valueListenable: Hive.box(widget.chat["id"].toString().replaceAll(RegExp(r"^-100"), "")).listenable(),
//             builder: (BuildContext ctx, Box box_chat, Widget? wget) {
//               return LayoutBuilder(
//                 builder: (BuildContext context, BoxConstraints constraints) {
//                   late Widget widget_app = Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: MediaQuery.of(context).padding.top,
//                       ),
//                       ...List.generate(50, (index) {
//                         return Padding(padding: EdgeInsets.all(10), child: Text("count $index"));
//                       }),
//                     ],
//                   );
//                   return SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(
//                       parent: BouncingScrollPhysics(),
//                     ),
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height, minWidth: MediaQuery.of(context).size.width),
//                       child: widget_app,
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.all(Radius.circular(0)),
//           boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 2)],
//         ),
//         child: TextField(
//           minLines: 1,
//           maxLines: 5,
//           controller: messageController,
//           textCapitalization: TextCapitalization.sentences,
//           onChanged: (String? res) {
//             if (res!.isEmpty) {
//               setState(() {
//                 isSendText = false;
//               });
//             } else {
//               setState(() {
//                 isSendText = true;
//               });
//             }
//           },
//           decoration: InputDecoration(
//             hintText: "Type a message",
//             hintStyle: const TextStyle(
//               color: Colors.grey,
//             ),
//             border: InputBorder.none,
//             prefixIcon: Padding(
//               padding: const EdgeInsets.all(2.5),
//               child: InkWell(
//                 child: const Icon(
//                   Iconsax.happyemoji,
//                   color: Colors.pink,
//                   size: 25,
//                 ),
//                 onTap: () {},
//               ),
//             ),
//             suffixIcon: chooseWidget(
//               isMain: isSendText,
//               main: Padding(
//                 padding: const EdgeInsets.all(5),
//                 child: InkWell(
//                   child: const Icon(
//                     Iconsax.send1,
//                     color: Colors.blue,
//                     size: 25,
//                   ),
//                   onTap: () async {
//                     tg.debugRequest(
//                       "sendMessage",
//                       parameters: {
//                         "chat_id": chat_id,
//                         "text": messageController.text,
//                         "parse_mode": "markdown",
//                       },
//                       callback: (res) {},
//                     );
//                   },
//                 ),
//               ),
//               second: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Visibility(
//                     visible: (chat_type == "channel") ? true : false,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: InkWell(
//                         child: const Icon(
//                           Iconsax.notification,
//                           color: Colors.blue,
//                           size: 25,
//                         ),
//                         onTap: () async {},
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: InkWell(
//                       child: const Icon(
//                         Iconsax.attach_square,
//                         color: Colors.blue,
//                         size: 25,
//                       ),
//                       onTap: () async {
//                         if (messageController.text.isNotEmpty) {
//                         } else {}
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: InkWell(
//                       child: Icon(
//                         (isVoice) ? Iconsax.voice_square : Iconsax.video,
//                         color: Colors.blue,
//                         size: 25,
//                       ),
//                       onLongPress: () async {
//                         if (isVoice) {
//                         } else {}
//                       },
//                       onTap: () async {
//                         setState(() {
//                           isVoice = (isVoice) ? false : true;
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
