// part of azkagram;

// class MainPage extends StatefulWidget {
//   final Box box;
//   final Map get_me;
//   final Tdlib tg;
//   final Box box_client;
//   const MainPage({
//     Key? key,
//     required this.box,
//     required this.get_me,
//     required this.tg,
//     required this.box_client,
//   }) : super(key: key);

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   @override
//   Widget build(BuildContext context) {
//     try {
//     return ValueListenableBuilder(
//       valueListenable: Hive.box("telegram_client").listenable(),
//       builder: (context, Box box, widgets) {
//         return ScaffoldSimulate(
//           body: LayoutBuilder(
//             builder: (BuildContext context, BoxConstraints constraints) {
//               late List<Widget> pageWidgets = [];
//               return SingleChildScrollView(
//                 physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     minHeight: MediaQuery.of(context).size.height,
//                     minWidth: MediaQuery.of(context).size.width,
//                   ),
//                   child: ValueListenableBuilder(
//                     valueListenable: Hive.box("client").listenable(),
//                     builder: (context, Box box_client, widgets) {
//                       late List chats = box_client.get("chats", defaultValue: []);
//                       return Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: MediaQuery.of(context).padding.top,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(15),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   Config.nameApplication,
//                                   style: const TextStyle(
//                                     fontSize: 30,
//                                     fontWeight: FontWeight.w800,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 InkWell(
//                                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                   onTap: () {},
//                                   child: const Padding(
//                                     padding: EdgeInsets.all(5),
//                                     child: Icon(
//                                       Iconsax.search_normal,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.all(10),
//                             child: Text(
//                               "Channels",
//                               style: TextStyle(
//                                 fontSize: 30,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: 250.0,
//                             child: Builder(builder: (ctx) {
//                               var chatChannels = chats.where((res) {
//                                 if (res["type"] == "channel") {
//                                   return true;
//                                 }
//                                 return false;
//                               }).toList();
//                               return ListView.builder(
//                                 physics: const ClampingScrollPhysics(),
//                                 shrinkWrap: true,
//                                 scrollDirection: Axis.horizontal,
//                                 itemCount: chatChannels.length,
//                                 itemBuilder: (BuildContext context, int index) {
//                                   var nick_name = "";
//                                   var member_count = "";
//                                   var path_image = "";
//                                   if (chatChannels[index]["title"] is String) {
//                                     nick_name = chatChannels[index]["title"];
//                                   }
//                                   if (chatChannels[index]["detail"] is Map) {
//                                     if (chatChannels[index]["detail"]["member_count"] is int) {
//                                       member_count = chatChannels[index]["detail"]["member_count"].toString();
//                                     }
//                                   }
//                                   if (nick_name.isEmpty) {
//                                     print(chatChannels[index]);
//                                   }
//                                   var res = chatChannels[index];
//                                   // if (res["profile_photo"] is Map) {
//                                   //   if (res["profile_photo"]["path"] is String == false || (res["profile_photo"]["path"] as String).isEmpty) {
//                                   //     tg.debugRequest("getRemoteFile",
//                                   //         parameters: {
//                                   //           "remote_file_id": res["profile_photo"]["file_id"],
//                                   //           "priority": 1,
//                                   //         },
//                                   //         is_log: false, callback: (ress) {
//                                   //       if (ress is Map) {
//                                   //         if (ress["local"] is Map) {
//                                   //           if (ress["local"]["path"] is String == false || (ress["local"]["path"] as String).isEmpty) {
//                                   //             tg.debugRequest("downloadFile", parameters: {"file_id": ress["id"], "priority": 1});
//                                   //           }
//                                   //           if (ress["local"]["is_downloading_completed"] is bool && ress["local"]["is_downloading_completed"]) {
//                                   //             for (var i = 0; i < chats.length; i++) {
//                                   //               if (chats[i]["id"] == res["id"]) {
//                                   //                 var getPathPhoto = ress["local"]["path"] as String;
//                                   //                 if (getPathPhoto.isNotEmpty) {
//                                   //                   chats[i]["profile_photo"]["path"] = getPathPhoto;
//                                   //                 } else {
//                                   //                   if (getPathPhoto.isNotEmpty) {
//                                   //                     chats[i]["profile_photo"]["path"] = getPathPhoto;
//                                   //                   }
//                                   //                 }

//                                   //                 setState(() {
//                                   //                   setValue("chats", chats);
//                                   //                 });
//                                   //               }
//                                   //             }
//                                   //           }
//                                   //         }
//                                   //       }
//                                   //     });
//                                   //   } else if ((res["profile_photo"]["path"] as String).isNotEmpty) {
//                                   //     path_image = res["profile_photo"]["path"];
//                                   //   }
//                                   // }

//                                   // if (path_image.isNotEmpty) {
//                                   //   var file = File(path_image);
//                                   //   if (!file.existsSync()) {
//                                   //     path_image = "";
//                                   //     for (var i = 0; i < chats.length; i++) {
//                                   //       if (chats[i] is Map) {
//                                   //         try {
//                                   //           if (chats[i]["id"] = chatChannels[index]["id"]) {
//                                   //             chats[i]["profile_photo"]["path"] = null;
//                                   //             setValue("chats", chats);
//                                   //           }
//                                   //         } catch (e) {
//                                   //           debug(e);
//                                   //         }
//                                   //       }
//                                   //     }
//                                   //   }
//                                   // }
//                                   return Padding(
//                                     padding: const EdgeInsets.all(10),
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(30),
//                                         color: Colors.white,
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: Colors.grey.withOpacity(1),
//                                             spreadRadius: 1,
//                                             blurRadius: 7,
//                                             offset: const Offset(0, 3), // changes position of shadow
//                                           ),
//                                         ],
//                                       ),
//                                       child: Stack(
//                                         children: [
//                                           chooseWidget(
//                                             isMain: path_image.isNotEmpty,
//                                             main: Container(
//                                               width: 150,
//                                               decoration: BoxDecoration(
//                                                 borderRadius: const BorderRadius.all(Radius.circular(30)),
//                                                 image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.grey.withOpacity(1),
//                                                     spreadRadius: 1,
//                                                     blurRadius: 7,
//                                                     offset: const Offset(0, 3), // changes position of shadow
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                             second: Container(
//                                               width: 150,
//                                               height: 250,
//                                               decoration: BoxDecoration(
//                                                 color: Colors.blue,
//                                                 borderRadius: const BorderRadius.all(Radius.circular(30)),
//                                                 boxShadow: [
//                                                   BoxShadow(
//                                                     color: Colors.grey.withOpacity(1),
//                                                     spreadRadius: 1,
//                                                     blurRadius: 7,
//                                                     offset: const Offset(0, 3), // changes position of shadow
//                                                   ),
//                                                 ],
//                                               ),
//                                               child: const Center(
//                                                 child: Text(
//                                                   "no Image",
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.w800,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Positioned(
//                                             top: 15,
//                                             left: 15,
//                                             child: Row(
//                                               children: [
//                                                 Padding(
//                                                   padding: const EdgeInsets.only(right: 2),
//                                                   child: Container(
//                                                     constraints: const BoxConstraints(
//                                                       maxWidth: double.infinity,
//                                                       maxHeight: double.infinity,
//                                                     ),
//                                                     padding: const EdgeInsets.all(10),
//                                                     decoration: BoxDecoration(
//                                                       color: const ui.Color.fromARGB(198, 0, 0, 0),
//                                                       borderRadius: BorderRadius.circular(10),
//                                                     ),
//                                                     child: const Text(
//                                                       "live",
//                                                       style: TextStyle(
//                                                         color: Colors.white,
//                                                         fontWeight: FontWeight.w700,
//                                                         fontSize: 15,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Padding(
//                                                   padding: const EdgeInsets.only(left: 2),
//                                                   child: Container(
//                                                     constraints: const BoxConstraints(
//                                                       maxWidth: double.infinity,
//                                                       maxHeight: double.infinity,
//                                                     ),
//                                                     padding: const EdgeInsets.all(10),
//                                                     decoration: BoxDecoration(
//                                                       color: const ui.Color.fromARGB(197, 131, 131, 131),
//                                                       borderRadius: BorderRadius.circular(10),
//                                                     ),
//                                                     child: Text(
//                                                       member_count,
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontWeight: FontWeight.w700,
//                                                         fontSize: 15,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Positioned(
//                                             bottom: 15,
//                                             left: 15,
//                                             child: Padding(
//                                               padding: const EdgeInsets.only(right: 2),
//                                               child: Container(
//                                                 constraints: const BoxConstraints(
//                                                   maxWidth: double.infinity,
//                                                   maxHeight: double.infinity,
//                                                 ),
//                                                 padding: const EdgeInsets.all(10),
//                                                 decoration: BoxDecoration(
//                                                   color: const ui.Color.fromARGB(197, 136, 136, 136),
//                                                   borderRadius: BorderRadius.circular(10),
//                                                 ),
//                                                 child: Text(
//                                                   nick_name,
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.w700,
//                                                     fontSize: 15,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             }),
//                           ),

//                           ///
//                           const Padding(
//                             padding: EdgeInsets.all(10),
//                             child: Text(
//                               "Chats",
//                               style: TextStyle(
//                                 fontSize: 30,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                           ),


//                           ...chats.where((res) {
//                             if (res["type"] != "channel") {
//                               return true;
//                             }
//                             return false;
//                           }).map((res) {

//                             var nick_name = "";
//                             if (res["type"] == "private") {
//                               nick_name = res["first_name"];
//                             } else {
//                               if (res['title'] is String) {
//                                 nick_name = res["title"];
//                               }
//                             }

//                             Map last_message = {};
//                             var type_content = "";
//                             var message = "";
//                             bool isFile = false;
//                             var path_image = "";
//                             var content = "";
//                             if (last_message["text"] is String) {
//                               message = last_message["text"];
//                             }

//                             if (res["last_message"] is Map && (res["last_message"] as Map).isNotEmpty) {
//                               last_message = res["last_message"];
//                               if (last_message["type_content"] is String && (last_message["type_content"] as String).isNotEmpty) {
//                                 type_content = last_message["type_content"];
//                               }
//                             }
//                             if (last_message["caption"] is String) {
//                               isFile = true;
//                               message = last_message["caption"];
//                             }
//                             int unread_count = 0;
//                             var date = "";
//                             var chat_type = "private";
//                             if (res["type"] is String) {
//                               chat_type = res["type"];
//                             }
//                             if (last_message["date"] is int) {
//                               date = last_message["date"].toString();
//                             }
//                             if (res["detail"] is Map) {
//                               if (res["detail"]["unread_count"] is int) {
//                                 unread_count = res["detail"]["unread_count"];
//                               }
//                             }
//                             return Padding(
//                               padding: const EdgeInsets.all(10),
//                               child: InkWell(
//                                 borderRadius: const BorderRadius.all(Radius.circular(25)),
//                                 onLongPress: () async {
//                                   print("long tap");
//                                 },
//                                 onTap: () async {
//                                   await Hive.openBox(res["id"].toString().replaceAll(RegExp(r"-100"), ""), path: widget.tg.client_option["user_path"]);
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (BuildContext context) => ChatPage(
//                                         box: widget.box,
//                                         tg: widget.tg,
//                                         box_client: widget.box_client,
//                                         chat: res,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(15),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(25),
//                                     color: Colors.white,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(1),
//                                         spreadRadius: 1,
//                                         blurRadius: 7,
//                                         offset: const Offset(0, 3), // changes position of shadow
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Visibility(
//                                         visible: isFile,
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(bottom: 15),
//                                           child: Stack(
//                                             children: [
//                                               Container(
//                                                 width: MediaQuery.of(context).size.width,
//                                                 height: 200,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: const BorderRadius.all(Radius.circular(20)),
//                                                   image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(content)).image),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.grey.withOpacity(1),
//                                                       spreadRadius: 1,
//                                                       blurRadius: 7,
//                                                       offset: const Offset(0, 3), // changes position of shadow
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Positioned(
//                                                 top: 15,
//                                                 right: 15,
//                                                 child: Container(
//                                                   constraints: const BoxConstraints(
//                                                     maxWidth: double.infinity,
//                                                     maxHeight: double.infinity,
//                                                   ),
//                                                   padding: const EdgeInsets.all(8),
//                                                   decoration: BoxDecoration(
//                                                     color: const ui.Color.fromARGB(199, 158, 158, 158),
//                                                     borderRadius: BorderRadius.circular(10),
//                                                   ),
//                                                   child: Text(
//                                                     chat_type,
//                                                     style: const TextStyle(
//                                                       color: Colors.white,
//                                                       fontWeight: FontWeight.w700,
//                                                       fontSize: 15,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         children: [
//                                           InkWell(
//                                             borderRadius: const BorderRadius.all(Radius.circular(25)),
//                                             onLongPress: () async {
//                                               print("photo profile");
//                                             },
//                                             onTap: () async {
//                                               print("photo profile");
//                                             },
//                                             child: chooseWidget(
//                                               isMain: path_image.isNotEmpty,
//                                               main: Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: const BorderRadius.all(Radius.circular(15)),
//                                                   image: DecorationImage(fit: BoxFit.cover, image: Image.file(File(path_image)).image),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.grey.withOpacity(1),
//                                                       spreadRadius: 1,
//                                                       blurRadius: 7,
//                                                       offset: const Offset(0, 3), // changes position of shadow
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               second: Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: const BorderRadius.all(Radius.circular(15)),
//                                                   color: Colors.yellow,
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.grey.withOpacity(1),
//                                                       spreadRadius: 1,
//                                                       blurRadius: 7,
//                                                       offset: const Offset(0, 3), // changes position of shadow
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: Center(
//                                                   child: Text(
//                                                     nick_name[0],
//                                                     style: const TextStyle(
//                                                       fontWeight: FontWeight.w800,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(10),
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: [
//                                                   Text(
//                                                     nick_name,
//                                                     style: const TextStyle(
//                                                       fontSize: 17,
//                                                       fontWeight: FontWeight.w800,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   Text(
//                                                     (date is int) ? date.toString() : "",
//                                                     maxLines: 2,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                           Expanded(
//                                             child: Padding(
//                                               padding: const EdgeInsets.all(10),
//                                               child: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: [
//                                                   Container(
//                                                     constraints: const BoxConstraints(
//                                                       maxWidth: double.infinity,
//                                                       maxHeight: double.infinity,
//                                                     ),
//                                                     padding: const EdgeInsets.all(5),
//                                                     decoration: BoxDecoration(
//                                                       color: const ui.Color.fromARGB(198, 0, 0, 0),
//                                                       borderRadius: BorderRadius.circular(5),
//                                                     ),
//                                                     child: Text(
//                                                       chat_type,
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontWeight: FontWeight.w700,
//                                                         fontSize: 15,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   Container(
//                                                     constraints: const BoxConstraints(
//                                                       maxWidth: double.infinity,
//                                                       maxHeight: double.infinity,
//                                                     ),
//                                                     padding: const EdgeInsets.all(5),
//                                                     decoration: BoxDecoration(
//                                                       color: const ui.Color.fromARGB(198, 0, 0, 0),
//                                                       borderRadius: BorderRadius.circular(5),
//                                                     ),
//                                                     child: Text(
//                                                       (last_message["is_outgoing"] is bool && last_message["is_outgoing"]) ? "Outgoing" : "Incomming",
//                                                       style: const TextStyle(
//                                                         color: Colors.white,
//                                                         fontWeight: FontWeight.w700,
//                                                         fontSize: 15,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Visibility(
//                                         visible: message.isNotEmpty,
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(5),
//                                           child: Text(
//                                             message,
//                                             style: const TextStyle(
//                                               color: ui.Color.fromARGB(255, 48, 48, 48),
//                                               fontWeight: FontWeight.w800,
//                                             ),
//                                             maxLines: 4,
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 10,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );

//                           }),

//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () async {
//               prettyPrintJson(widget.box_client.get("chats"));
//             },
//             child: Icon(Iconsax.activity),
//           ),
//         );
//       },
//     );
//   } catch (e){
//     return Scaffold(body: Center(
//       child: Text("error"),
//     ));
//   }
//   }
// }
