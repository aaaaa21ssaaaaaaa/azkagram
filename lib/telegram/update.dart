part of azkagram;


void tgUpdate(UpdateTd update, {required Box box, required Tdlib tg, required Box box_client}) async {
  getValue(key, defaultvalue) {
    try {
      return box.get(key, defaultValue: defaultvalue);
    } catch (e) {
      return defaultvalue;
    }
  }

  setValue(key, value) {
    return box.put(key, value);
  }

  try {
    await Future.delayed(const Duration(microseconds: 1));
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
          if (authStateType == "authorizationStateWaitPhoneNumber") {}
          if (authStateType == "authorizationStateWaitCode") {}
          if (authStateType == "authorizationStateWaitPassword") {}
          if (authStateType == "authorizationStateReady") {
            bool is_bot = false;
            var getMe = await tg.request("getMe");
            if (getMe["ok"] is bool && getMe["ok"] && getMe["result"] is Map) {
              is_bot = getMe["result"]["is_bot"];
            }
            setValue("is_login", true);
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
          if (authStateType == "authorizationStateWaitOtherDeviceConfirmation") {
            setValue("qr", update.raw["authorization_state"]["link"]);
          }
        }
      }

      if (type == "updateFile") {
        prettyPrintJson(update.raw);
      }

      if (type == "updateConnectionState") {
        if (update.raw["state"]["@type"] == "connectionStateConnecting") {
          setValue("is_no_connection", true);
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
          if (kDebugMode) {
            print(text);
          }
          if (RegExp("/ping", caseSensitive: false).hasMatch(text)) {
            await tg.request("sendMessage", {"chat_id": chat_id, "text": "pong"});
            return;
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
          if (RegExp("/json", caseSensitive: false).hasMatch(text)) {
            await tg.request("sendMessage", {"chat_id": chat_id, "text": "ID: ${msg["message_id"]}\nApi: ${msg["api_message_id"]}"});
            return;
          }
          if (RegExp("/ping", caseSensitive: false).hasMatch(text)) {
            await tg.request("sendMessage", {"chat_id": chat_id, "text": "pong:update"});
            return;
          }
          if (RegExp("/option", caseSensitive: false).hasMatch(text)) {
            await tg.request("sendMessage", {"chat_id": chat_id, "text": json.encode(tg.optionTdlibDefault)});
            return;
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
}
