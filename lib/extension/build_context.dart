part of azkagram_extension;

extension BuildContextExtension on BuildContext {
  MediaQueryData get mediaQueryData {
    return MediaQuery.of(this);
  }

  Orientation get orientation {
    return mediaQueryData.orientation;
  }


}
