part of azkagram_widget;

class Qr extends StatelessWidget {
  final double size;
  final String data;
  final ImageProvider<Object> image;
  const Qr({
    super.key,
    required this.size,
    required this.data,
    this.image = const AssetImage("assets/icons/telegram.png"),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          (size - (size * 3 / 3.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: PrettyQr(
        image: image,
        size: size,
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.M,
        roundEdges: true,
      ),
    );
  }
}
