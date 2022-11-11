 library azkagram_core;

import 'dart:io';

String getTdlib() {
  if (Platform.isWindows) {
    return "libtdjson.dll";
  } else if (Platform.isMacOS || Platform.isIOS) {
    return "libtdjson.dyll";
  }
  return "libtdjson.so";
}
