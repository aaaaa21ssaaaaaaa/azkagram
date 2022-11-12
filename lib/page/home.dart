part of azkagram_page;

class HomePage extends StatefulWidget {
  final Tdlib tdlib;
  final Database database;
  const HomePage({
    super.key,
    required this.tdlib,
    required this.database,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: context.mediaQueryData.size.height,
            minWidth: context.mediaQueryData.size.width,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 50,
              ),
              Storys(
                onPressed: (index) {
                  print(index);
                },
              ),


              
              
            ],
          ),
        ),
      ),
    );
  }
}
