part of azkagram_page;

class ChatPage extends StatefulWidget {
  final Tdlib tdlib;
  final Database database;
  const ChatPage({
    super.key,
    required this.tdlib,
    required this.database,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
