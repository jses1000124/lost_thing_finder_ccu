// web_specific.dart
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

void setExternalUserId(String userId) {
  if (kIsWeb) {
    js.context.callMethod('setExternalUserId', [userId]);
  }
}
