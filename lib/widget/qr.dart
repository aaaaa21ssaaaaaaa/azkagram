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
        borderRadius: BorderRadius.circular((size - (size * 3 / 3.3))),
        boxShadow: const [
          BoxShadow(color: Colors.black87, spreadRadius: 0.2, blurRadius: 0.2),
          BoxShadow(color: Colors.black54, spreadRadius: 0.5, blurRadius: 0.5),
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
