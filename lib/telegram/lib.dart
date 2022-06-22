part of azkagram;



class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.box}) : super(key: key);
  final Box box;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldSimulate(
      body: ValueListenableBuilder(
        valueListenable: Hive.box('telegram_client').listenable(),
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
