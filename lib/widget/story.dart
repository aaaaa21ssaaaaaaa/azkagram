part of azkagram_widget;

class Storys extends StatelessWidget {
  final void Function(int index) onPressed;
  const Storys({Key? key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.mediaQueryData.size.width,
      height: 250,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        primary: false,
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(15),
            child: StoryPicture(
              pathImage: "assets/debug/girl.jpg",
              height: 250,
              width: 150,
              onPressed: () {
                onPressed.call(index);
              },
            ),
          );
        },
      ),
    );
  }
}

class StoryPicture extends StatelessWidget {
  final String pathImage;
  final String nick_name;
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final String status;
  final int count;
  final void Function()? onPressed;
  const StoryPicture({
    super.key,
    required this.pathImage,
    required this.width,
    required this.height,
    this.status = "-",
    this.count = 0,
    this.nick_name = "-",
    this.borderRadius,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Stack(
        children: [
          ProfilePicture(
            pathImage: pathImage,
            nick_name: nick_name,
            width: width,
            height: height,
            onPressed: onPressed,
          ),
          Positioned(
            top: 15,
            left: 15,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 2,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(198, 0, 0, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(197, 131, 131, 131),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                ),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(197, 136, 136, 136),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  nick_name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
