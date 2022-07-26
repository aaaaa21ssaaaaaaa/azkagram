part of azkagram;

void tgUpdate(UpdateTd update, {required Box box, required Tdlib tg, required Box box_client}) async {
  try {
    getValue(key, defaultvalue, {bool is_client = false}) {
      try {
        if (is_client) {
          return box_client.get(key, defaultValue: defaultvalue);
        }
        return box.get(key, defaultValue: defaultvalue);
      } catch (e) {
        return defaultvalue;
      }
    }

    setValue(key, value, {bool is_client = false}) async {
      await Future.delayed(Duration(milliseconds: 1));
      if (is_client) {
        return await box_client.put(key, value);
      }
      return await box.put(key, value);
    }

    if (!update.raw.containsKey("@extra")) {}
    if (update.raw["@type"] is String) {
      var type = update.raw["@type"];
      if (type == "error") {
        if (RegExp(r"^Can't lock file", caseSensitive: false).hasMatch(update.raw["message"])) {
          if (kDebugMode) {
            print("eror");
          }
          exit(1);
        }
      }
      if (type == "updateAuthorizationState") {
        if (update.raw["authorization_state"] is Map) {
          var authStateType = update.raw["authorization_state"]["@type"];

          if (authStateType != "authorizationStateClosed") {
            await tg.initClient(
              update,
              clientId: update.client_id,
              tdlibParameters: update.client_option,
              isVoid: true,
            );
          }
          if (authStateType == "authorizationStateWaitPhoneNumber") {
            await setValue("isSignPage", true);
            await setValue("state_sign_page", {"type": "phone_number"});
          }
          if (authStateType == "authorizationStateWaitCode") {
            await setValue("isSignPage", true);
            await setValue("state_sign_page", {"type": "code"});
          }
          if (authStateType == "authorizationStateWaitPassword") {
            await setValue("isSignPage", true);
            await setValue("state_sign_page", {"type": "password"});
          }
          if (authStateType == "authorizationStateReady") {
            bool is_bot = false;
            var getMe = await tg.request("getMe");
            if (getMe["ok"] is bool && getMe["ok"] && getMe["result"] is Map) {
              is_bot = getMe["result"]["is_bot"];
            }

            if (!is_bot) {
              tg.debugRequest("getChats", callback: (res) {
                if (res["ok"]) {
                  var result = res["result"] as List;
                  setValue("chats", result, is_client: true);
                }
              });
            }

            await setValue("isSignPage", false);
            List users = getValue("users", []);
            getMe["result"]["is_sign"] = true;
            getMe["result"]["client"] = {
              "client_id": update.client_id,
              "client_option": update.client_option,
            };

            await setValue("client", getMe["result"]);

            for (var i = 0; i < users.length; i++) {
              var loop_data = users[i];
              if (loop_data is Map && loop_data["id"] == getMe["result"]["id"]) {
                users[i] = getMe["result"];
                await setValue("users", users);
                return;
              }
            }
            users.add(getMe["result"]);
            await setValue("users", users);
            return;
          }

          if (authStateType == "authorizationStateClosing") {}

          if (authStateType == "authorizationStateClosed") {}

          if (authStateType == "authorizationStateLoggingOut") {}
          if (authStateType == "authorizationStateWaitOtherDeviceConfirmation") {
            setValue("qr", update.raw["authorization_state"]["link"]);
          }
        }
      }

      if (type == "updateConnectionState") {
        if (update.raw["state"]["@type"] == "connectionStateConnecting") {
          setValue("is_no_connection", true);
        }
      }

      /// update_message
      if (update.raw["@type"] == "updateNewMessage") {
        var message = update.raw["message"];
        if (message["@type"] == "message") {
          Map msg = {};
          Map chatJson = {"id": message["chat_id"], "first_name": "", "title": "", "type": "", "detail": {}, "last_message": {}};
          if (message["is_channel_post"] is bool && message["is_channel_post"]) {
            chatJson["type"] = "channel";
            chatJson["title"] = "";
          } else {
            if (RegExp("^-100", caseSensitive: false).hasMatch(message["chat_id"].toString())) {
              chatJson["type"] = "supergroup";
              chatJson["title"] = "";
            } else if (RegExp("^-", caseSensitive: false).hasMatch(message["chat_id"].toString())) {
              chatJson["type"] = "group";
              chatJson["title"] = "";
            } else {
              chatJson["type"] = "private";
            }
          }

          try {
            var res = await tg.getChat(
              chatJson["id"],
              clientId: update.client_id,
              is_more_detail: true,
            );
            chatJson = res["result"];
            if (chatJson["profile_photo"] is Map){
              
            }
          } catch (e) {}
          msg["is_outgoing"] = message["is_outgoing"] ?? false;
          msg["is_pinned"] = message["is_pinned"] ?? false;
          if (message["sender_id"] is Map) {
            Map fromJson = {"id": 0, "first_name": "", "title": "", "type": "", "detail": {}, "last_message": {}};
            if (message["sender_id"]["user_id"] != null) {
              fromJson["id"] = message["sender_id"]["user_id"];
              try {
                var res = await tg.request(
                  "getUser",
                  parameters: {"chat_id": fromJson["id"]},
                  clientId: update.client_id,
                );
                fromJson = res["result"];
              } catch (e) {}
            }
            if (message["sender_id"]["chat_id"] != null) {
              fromJson["id"] = message["sender_id"]["chat_id"];
              try {
                var res = await tg.request(
                  "getChat",
                  parameters: {"chat_id": fromJson["id"]},
                  clientId: update.client_id,
                );
                fromJson = res["result"];
              } catch (e) {}
            }
            msg["from"] = fromJson;
          }

          msg["chat"] = chatJson;
          msg["date"] = message["date"];
          msg["message_id"] = message["id"];
          try {
            msg["api_message_id"] = tg.getMessageId(message["id"], true);
          } catch (e) {}
          message.forEach((key, value) {
            try {
              if (value is bool) {
                msg[key] = value;
              }
            } catch (e) {}
          });

          if (chatJson["type"] == "channel") {
            if (message["author_signature"].toString().isNotEmpty) {
              msg["author_signature"] = message["author_signature"];
            }
          }

          message["reply_to_message_id"] ??= 0;
          message["reply_in_chat_id"] ??= 0;

          if (message["reply_to_message_id"] != 0 && message["reply_in_chat_id"] != 0) {}

          /// content_update
          if (message["content"] is Map) {
            List oldEntities = [];

            if (message["content"]["@type"] == "messageText") {
              msg["type_content"] = "text";
              if (message["content"]["text"] is Map) {
                if (message["content"]["text"]["@type"] == "formattedText") {
                  msg["text"] = message["content"]["text"]["text"];
                  oldEntities = message["content"]["text"]["entities"];
                }
              }
            }

            if (message["content"]["@type"] == "messagePhoto") {
              msg["type_content"] = "photo";
              if (message["content"]["photo"] is Map) {
                if (message["content"]["photo"]["@type"] == "photo") {
                  var sizePhoto = [];
                  var photo = message["content"]["photo"]["sizes"];
                  for (var i = 0; i < photo.length; i++) {
                    var photoJson = photo[i];
                    var jsonPhoto = {};
                    jsonPhoto["id"] = photoJson["photo"]["id"];
                    if (photoJson["photo"]["local"]["@type"] == "localFile") {
                      jsonPhoto["path"] = photoJson["photo"]["local"]["path"];
                    }
                    if (photoJson["photo"]["remote"]["@type"] == "remoteFile") {
                      jsonPhoto["file_id"] = photoJson["photo"]["remote"]["id"];
                    }
                    if (photoJson["photo"]["remote"]["unique_id"] != null) {
                      jsonPhoto["file_unique_id"] = photoJson["photo"]["remote"]["unique_id"];
                    }
                    jsonPhoto["file_size"] = photoJson["photo"]["size"];
                    jsonPhoto["width"] = photoJson["width"];
                    jsonPhoto["height"] = photoJson["height"];
                    sizePhoto.add(jsonPhoto);
                  }
                  msg["photo"] = sizePhoto;
                }
              }
            }

            if (message["content"]["@type"] == "messageVideo") {
              msg["type_content"] = "video";
              if (message["content"]["video"] is Map) {
                if (message["content"]["video"]["@type"] == "video") {
                  var jsonVideo = {};
                  var contentVideo = message["content"]["video"];
                  jsonVideo["duration"] = contentVideo["duration"];
                  jsonVideo["height"] = contentVideo["height"];
                  jsonVideo["file_name"] = contentVideo["file_name"];
                  jsonVideo["mime_type"] = contentVideo["mime_type"];
                  try {
                    if (message["content"]["video"]["thumbnail"] != null && message["content"]["video"]["thumbnail"]["@type"].toString().toLowerCase() == "thumbnail") {
                      var contentThumb = contentVideo["thumbnail"];
                      var jsonThumb = {};
                      jsonVideo["thumb"] = jsonThumb;
                      jsonThumb["file_id"] = contentThumb["file"]["remote"]["id"];
                      jsonThumb["file_unique_id"] = contentThumb["file"]["remote"]["unique_id"];
                      jsonThumb["file_size"] = contentThumb["file"]["size"];
                      jsonThumb["width"] = contentThumb["width"];
                      jsonThumb["height"] = contentThumb["height"];
                    }
                  } catch (e) {}
                  jsonVideo["file_id"] = contentVideo["video"]["remote"]["id"];
                  jsonVideo["file_size"] = contentVideo["video"]["size"];
                  msg["video"] = jsonVideo;
                }
              }
            }

            if (message["content"]["@type"] == "messageAudio") {
              var typeContent = "audio";
              msg["type_content"] = "audio";
              if (message["content"]["audio"] is Map) {
                if (message["content"]["audio"]["@type"] == "audio") {
                  var jsonContent = {};
                  var contentUpdate = message["content"][typeContent];
                  jsonContent["duration"] = contentUpdate["duration"];
                  jsonContent["title"] = contentUpdate["title"];
                  jsonContent["performer"] = contentUpdate["performer"];
                  jsonContent["file_name"] = contentUpdate["file_name"];
                  jsonContent["mime_type"] = contentUpdate["mime_type"];
                  jsonContent["file_id"] = contentUpdate[typeContent]["remote"]["id"];
                  jsonContent["unique_id"] = contentUpdate[typeContent]["remote"]["unique_id"];
                  jsonContent["file_size"] = contentUpdate[typeContent]["size"];
                  msg[typeContent] = jsonContent;
                }
              }
            }

            if (message["content"]["@type"] == "messageAnimation") {
              var typeContent = "animation";
              msg["type_content"] = "animation";
              if (message["content"]["animation"] is Map) {
                if (message["content"]["animation"]["@type"] == "animation") {
                  var jsonContent = {};
                  var contentUpdate = message["content"][typeContent];
                  jsonContent["duration"] = contentUpdate["duration"];
                  jsonContent["width"] = contentUpdate["width"];
                  jsonContent["height"] = contentUpdate["height"];
                  jsonContent["file_name"] = contentUpdate["file_name"];
                  jsonContent["mime_type"] = contentUpdate["mime_type"];
                  jsonContent["mime_type"] = contentUpdate["mime_type"];
                  jsonContent["has_stickers"] = contentUpdate["has_stickers"];

                  try {
                    if (message["content"][typeContent]["thumbnail"] != null && message["content"][typeContent]["thumbnail"]["@type"].toString().toLowerCase() == "thumbnail") {
                      var contentThumb = contentUpdate["thumbnail"];
                      var jsonThumb = {};
                      jsonThumb["file_id"] = contentThumb["file"]["remote"]["id"];
                      jsonThumb["file_unique_id"] = contentThumb["file"]["remote"]["unique_id"];
                      jsonThumb["file_size"] = contentThumb["file"]["size"];
                      jsonThumb["width"] = contentThumb["width"];
                      jsonThumb["height"] = contentThumb["height"];
                      jsonContent["thumb"] = jsonThumb;
                    }
                  } catch (e) {}
                  jsonContent["file_id"] = contentUpdate[typeContent]["remote"]["id"];
                  jsonContent["unique_id"] = contentUpdate[typeContent]["remote"]["unique_id"];
                  jsonContent["file_size"] = contentUpdate[typeContent]["size"];
                  msg[typeContent] = jsonContent;
                }
              }
            }

            if (message["content"]["@type"] == "messageContact") {
              var typeContent = "contact";
              msg["type_content"] = typeContent;
              if (message["content"][typeContent] is Map) {
                if (message["content"][typeContent]["@type"] == typeContent) {
                  var jsonContent = {};
                  var contentUpdate = message["content"][typeContent];
                  jsonContent["phone_number"] = contentUpdate["phone_number"];
                  jsonContent["first_name"] = contentUpdate["first_name"];
                  jsonContent["last_name"] = contentUpdate["last_name"];
                  jsonContent["vcard"] = contentUpdate["vcard"];
                  jsonContent["user_id"] = contentUpdate["user_id"];
                  msg[typeContent] = jsonContent;
                }
              }
            }

            if (message["content"]["@type"] == "messagePoll") {
              var typeContent = "poll";
              msg["type_content"] = typeContent;
              if (message["content"][typeContent] is Map) {
                if (message["content"][typeContent]["@type"] == typeContent) {
                  var jsonContent = {};
                  var contentUpdate = message["content"][typeContent];
                  jsonContent["id"] = contentUpdate["id"];
                  jsonContent["question"] = contentUpdate["question"];
                  jsonContent["options"] = contentUpdate["options"];
                  jsonContent["total_voter_count"] = contentUpdate["total_voter_count"];
                  jsonContent["recent_voter_user_ids"] = contentUpdate["recent_voter_user_ids"];
                  jsonContent["is_anonymous"] = contentUpdate["is_anonymous"];
                  jsonContent["type"] = contentUpdate["type"];
                  jsonContent["open_period"] = contentUpdate["open_period"];
                  jsonContent["close_date"] = contentUpdate["close_date"];
                  jsonContent["is_closed"] = contentUpdate["is_closed"];
                  msg[typeContent] = jsonContent;
                }
              }
            }

            if (message["content"]["@type"] == "messageDocument") {
              var typeContent = "document";
              msg["type_content"] = typeContent;
              if (message["content"][typeContent] is Map) {
                if (message["content"][typeContent]["@type"] == typeContent) {
                  var jsonContent = {};
                  var contentUpdate = message["content"][typeContent];
                  jsonContent["file_name"] = contentUpdate["file_name"];
                  jsonContent["mime_type"] = contentUpdate["mime_type"];

                  jsonContent["file_id"] = contentUpdate[typeContent]["remote"]["id"];
                  jsonContent["unique_id"] = contentUpdate[typeContent]["remote"]["unique_id"];
                  jsonContent["file_size"] = contentUpdate[typeContent]["size"];
                  msg[typeContent] = jsonContent;
                }
              }
            }

            if (message["content"]["@type"] == "messageSticker") {
              var typeContent = "sticker";
              msg["type_content"] = typeContent;
              if (message["content"][typeContent] is Map) {
                if (message["content"][typeContent]["@type"] == typeContent) {
                  var jsonContent = {};
                  var contentUpdate = message["content"][typeContent];
                  jsonContent["set_id"] = contentUpdate["set_id"];
                  jsonContent["width"] = contentUpdate["width"];
                  jsonContent["height"] = contentUpdate["height"];
                  jsonContent["emoji"] = contentUpdate["emoji"];
                  jsonContent["is_animated"] = contentUpdate["is_animated"];
                  jsonContent["is_mask"] = contentUpdate["is_mask"];

                  try {
                    if (message["content"][typeContent]["thumbnail"] != null && message["content"][typeContent]["thumbnail"]["@type"].toString().toLowerCase() == "thumbnail") {
                      var contentThumb = contentUpdate["thumbnail"];
                      var jsonThumb = {};
                      jsonThumb["file_id"] = contentThumb["file"]["remote"]["id"];
                      jsonThumb["file_unique_id"] = contentThumb["file"]["remote"]["unique_id"];
                      jsonThumb["file_size"] = contentThumb["file"]["size"];
                      jsonThumb["width"] = contentThumb["width"];
                      jsonThumb["height"] = contentThumb["height"];
                      jsonContent["thumb"] = jsonThumb;
                    }
                  } catch (e) {}

                  jsonContent["file_id"] = contentUpdate[typeContent]["remote"]["id"];
                  jsonContent["unique_id"] = contentUpdate[typeContent]["remote"]["unique_id"];
                  jsonContent["file_size"] = contentUpdate[typeContent]["size"];
                  msg[typeContent] = jsonContent;
                }
              }
            }

            if (message["content"]["@type"] == "messageVoiceNote") {
              var typeContent = "voice_note";
              msg["type_content"] = typeContent;
              if (message["content"][typeContent] is Map) {
                if (message["content"][typeContent]["@type"] == "voiceNote") {
                  var jsonContent = {};
                  var contentUpdate = message["content"][typeContent];

                  jsonContent["duration"] = contentUpdate["duration"];
                  jsonContent["waveform"] = contentUpdate["waveform"];
                  jsonContent["mime_type"] = contentUpdate["mime_type"];

                  jsonContent["file_id"] = contentUpdate["voice"]["remote"]["id"];
                  jsonContent["unique_id"] = contentUpdate["voice"]["remote"]["unique_id"];
                  jsonContent["file_size"] = contentUpdate["voice"]["size"];
                  msg["voice"] = jsonContent;
                }
              }
            }
            if (message["content"]["@type"] == "messageChatJoinByLink") {
              msg["type_content"] = "new_member";
              Map newMemberFrom = msg["from"];
              try {
                newMemberFrom.remove("detail");
              } catch (e) {}
              msg["new_members"] = [newMemberFrom];
            }

            // caption
            if (message["content"]["caption"] is Map) {
              if (message["content"]["caption"]["@type"] == "formattedText") {
                if (message["content"]["caption"]["text"].toString().isNotEmpty) {
                  msg["caption"] = message["content"]["caption"]["text"];
                }
                oldEntities = message["content"]["caption"]["entities"];
              }
            }

            List newEntities = [];
            for (var i = 0; i < oldEntities.length; i++) {
              var dataEntities = oldEntities[i];
              try {
                var jsonEntities = {};
                jsonEntities["offset"] = dataEntities["offset"];
                jsonEntities["length"] = dataEntities["length"];
                if (dataEntities["type"]["@type"] != null) {
                  var typeEntities = dataEntities["type"]["@type"].toString().toLowerCase().replaceAll(RegExp("textEntityType", caseSensitive: false), "").replaceAll(RegExp("textUrl", caseSensitive: false), "text_link").replaceAll(RegExp("bot_command", caseSensitive: false), "bot_command").replaceAll(RegExp("mentionname", caseSensitive: false), "text_mention");
                  jsonEntities["type"] = typeEntities;
                  if (dataEntities["type"]["url"] != null) {
                    jsonEntities["url"] = dataEntities["type"]["url"];
                  }
                  if (typeEntities == "text_mention" && dataEntities["type"]["user_id"] != null) {
                    var entitiesUserId = dataEntities["type"]["user_id"];
                    var fromJson = {"id": entitiesUserId};
                    jsonEntities["user"] = fromJson;
                  }
                }
                newEntities.add(jsonEntities);
              } catch (e) {}
            }
            msg["entities"] = newEntities;
          }
          var user_id = msg["from"]["id"];
          var chat_id = msg["chat"]["id"];
          var from_id = msg["from"]["id"];

          List chats = getValue("chats", [], is_client: true);
          bool is_found = false;
          for (var i = 0; i < chats.length; i++) {
            var loop_data = chats[i];
            if (loop_data is Map && loop_data["id"] == chat_id) {
              is_found = true;
              chats.removeAt(i);
              Map chat = msg["chat"];
              chats.insert(0, {...chat, "last_message": msg});
              await setValue("chats", chats, is_client: true);
            }
          }
          if (!is_found) {
            Map chat = msg["chat"];
            chats.insert(0, {...chat, "last_message": msg});
            await setValue("chats", chats, is_client: true);
          }
          late List chatMessages = [];
          late String chatId = chat_id.toString().replaceAll(RegExp(r"^(-100|-)", caseSensitive: false), "replace");
          try {
            chatMessages = getValue(chatId, [], is_client: true);
          } catch (e) {}
          chatMessages.add(msg);
          await setValue(chatId, chatMessages, is_client: true);
        }
      }
    }
  } catch (e) {
    debug(e);
  }
}
