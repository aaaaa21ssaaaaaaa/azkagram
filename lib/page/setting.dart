part of azkagram_page;

class SettingPage extends StatefulWidget {
  final Tdlib tdlib;
  final Database database;
  const SettingPage({
    super.key,
    required this.tdlib,
    required this.database,
  });

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
