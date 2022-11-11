// ignore_for_file: non_constant_identifier_names

library azkagram_config;

import 'dart:convert';

class AzkaGramConfig {
  static int telegram_api_id = 1917085; // create your own telegram at here https://my.telegram.org/auth
  static String telegram_api_hash = "a612212e6ac3ff1f97a99b2e0f050894";  // create your own telegram at here https://my.telegram.org/auth
  static String telegram_database_key = base64.encode(utf8.encode("azkagram_key"));
  static String telegram_device_model = "AzkaGram";
  static String telegram_version = "AzkaGram";
  static Map telegram_cliet_option = {
    "use_file_database": false,
    "use_chat_info_database": false,
    "use_message_database": false,
    "use_secret_chats": false,
    'enable_storage_optimizer': true,
  };
}
