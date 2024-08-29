import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:1337';
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:1337';
  } else if (Platform.isIOS) {
    return 'http://localhost:1337';
  } else {
    return 'http://localhost:1337';
  }
}