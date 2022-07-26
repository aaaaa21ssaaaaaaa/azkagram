part of azkagram;

/// QrCodes
class QrCodes {
  static Image widget(String text) {
    late List<int> bytesQrCode = [];
    var qrcode = Encoder.encode(text, ErrorCorrectionLevel.h);
    var matrix = qrcode.matrix!;
    var scale = 10;
    var image = img.Image(matrix.width * scale, matrix.height * scale);
    for (var x = 0; x < matrix.width; x++) {
      for (var y = 0; y < matrix.height; y++) {
        if (matrix.get(x, y) == 1) {
          img.fillRect(image, x * scale, y * scale, x * scale + scale, y * scale + scale, 0xFF000000);
        }
      }
    }
    bytesQrCode = img.encodePng(image);
    return Image.memory(Uint8List.fromList(bytesQrCode));
  }
}

///
///

void debug(Object? data) {
  if (kDebugMode) {
    print(data);
  }
}

void debugFunction(Tdlib tg, {required String method, Map<String, dynamic>? parameters, bool is_sync = false, bool is_raw = false}) async {
  try {
    parameters ??= {};
    if (is_sync) {
      debug(tg.invokeSync(method, parameters: parameters));
    } else {
      if (is_raw) {
        debug(await tg.invoke(method, parameters: parameters));
      } else {
        debug(await tg.request(method, parameters: parameters));
      }
    }
  } catch (e) {
    debug(e);
  }
}

List prettyPrintJson(var input, {bool is_log = kDebugMode}) {
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
          isShowFrame: false,
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
                padding: const EdgeInsets.all(5),
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

MaterialColor randomColors() {
  List<MaterialColor> colors = [
    Colors.blue, Colors.blueGrey, Colors.brown,
    Colors.cyan, Colors.deepOrange, Colors.deepPurple,
    Colors.green, Colors.grey, Colors.indigo,
    Colors.lightBlue, Colors.lightGreen, Colors.lime
  ];
  colors.shuffle();
  return colors[0];
}
