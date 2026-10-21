import 'package:flutter/foundation.dart';

class PlatformFeatures {
  static bool get useVapeWebLinks =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}
