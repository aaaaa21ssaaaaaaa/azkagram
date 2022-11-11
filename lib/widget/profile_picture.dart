// ignore_for_file: non_constant_identifier_names

part of azkagram_widget;

class ProfilePicture extends StatelessWidget {
  final String pathImage;
  final String nick_name;
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
    final void Function()? onPressed;
  const ProfilePicture({
    super.key,
    required this.pathImage,
    required this.width,
    required this.height,
    this.nick_name = "-",
    this.borderRadius,
   required this.onPressed,
  });

  String get path_image {
    File file = File(pathImage);
    if (file.existsSync() == false) {
      return "";
    }
    return file.path;
  }

  File get file {
    return File(pathImage);
  }

  @override
  Widget build(BuildContext context) {
    late DecorationImage? image;
    if (path_image.isNotEmpty) {
      image = DecorationImage(
        fit: BoxFit.cover,
        image: Image.file(file).image,
        onError: (errDetails, error) {},
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: randomColors(),
        borderRadius: borderRadius ??
            BorderRadius.circular(
              15,
            ),
        image: image,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: MaterialButton(
        clipBehavior: Clip.antiAlias,
        minWidth: 0,
        onPressed: onPressed,
        child: Visibility(
          visible: path_image.isEmpty,
          child: Center(
            child: Text(
              nick_name.characters.first,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
