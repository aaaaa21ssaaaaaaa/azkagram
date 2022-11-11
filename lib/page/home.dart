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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   height: 200,
              //   width: 150,
              //   decoration: BoxDecoration(
              //     color: Colors.black,
              //     borderRadius: BorderRadius.circular(10),
              //     image: DecorationImage(
              //       image: Image.asset("assets/debug/boy.jpeg").image,
              //       fit: BoxFit.fill,
              //     ),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(1),
              //         spreadRadius: 1,
              //         blurRadius: 7,
              //         offset: const Offset(0, 3), // changes position of shadow
              //       ),
              //     ],
              //   ),

              // ),

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
 