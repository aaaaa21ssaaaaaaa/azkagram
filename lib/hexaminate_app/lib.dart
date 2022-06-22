// ignore_for_file: non_constant_identifier_names

part of azkagram;

class HexaWalletPage extends StatefulWidget {
  const HexaWalletPage({Key? key, required this.box}) : super(key: key);
  final Box box;
  @override
  State<HexaWalletPage> createState() => _HexaWalletPageState();
}

class _HexaWalletPageState extends State<HexaWalletPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldSimulate(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('hexaminate').listenable(),
        builder: (BuildContext ctx, Box box, Widget? wget) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              late Widget widget_app = const Center(
                child: Text("Hello World"),
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
      ),
    );
  }
}

class HexaBlogPage extends StatefulWidget {
  const HexaBlogPage({Key? key, required this.box}) : super(key: key);
  final Box box;

  @override
  State<HexaBlogPage> createState() => _HexaBlogPageState();
}

class _HexaBlogPageState extends State<HexaBlogPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldSimulate(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('hexaminate').listenable(),
        builder: (BuildContext ctx, Box box, Widget? wget) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              late Widget widget_app = const Center(
                child: Text("Hello World"),
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
      ),
    );
  }
}

class HexaShopPage extends StatefulWidget {
  HexaShopPage({Key? key, required this.box}) : super(key: key);
  final Box box;

  @override
  State<HexaShopPage> createState() => _HexaShopPageState();
}

class _HexaShopPageState extends State<HexaShopPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldSimulate(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('hexaminate').listenable(),
        builder: (BuildContext ctx, Box box, Widget? wget) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              late Widget widget_app = const Center(
                child: Text("Hello World"),
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
      ),
    );
  }
}

class HexaSignPage extends StatefulWidget {
  HexaSignPage({Key? key}) : super(key: key);

  @override
  State<HexaSignPage> createState() => _HexaSignPageState();
}

class _HexaSignPageState extends State<HexaSignPage> {
  final TextEditingController usernameTextController = TextEditingController();
  final TextEditingController fullnameTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ScaffoldSimulate(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('hexaminate').listenable(),
        builder: (BuildContext ctx, Box box, Widget? wget) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              late Widget widget_app = const Center(
                child: Text("Hello World"),
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
      ),
    );
  }
}
