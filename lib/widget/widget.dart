library azkagram_widget;

import 'package:azkagram/extension/extension.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:universal_io/io.dart';

part 'profile_picture.dart';
part "header.dart";

part "qr.dart";
part "story.dart";

MaterialColor randomColors() {
  List<MaterialColor> colors = [Colors.blue, Colors.blueGrey, Colors.brown, Colors.cyan, Colors.deepOrange, Colors.deepPurple, Colors.green, Colors.grey, Colors.indigo, Colors.lightBlue, Colors.lightGreen, Colors.lime];
  colors.shuffle();
  return colors[0];
}
