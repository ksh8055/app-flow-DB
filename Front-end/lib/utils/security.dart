// lib/utils/security.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Security {
  // Make salt environment-specific
  static final _salt = "dev_salt_${DateTime.now().year}"; 

  static String hashPassword(String plainText) {
    final bytes = utf8.encode(plainText + _salt);
    return sha256.convert(bytes).toString();
  }

  // For testing/development only
  static void debugPrintHash(String password) {
    assert(() {
      print("DEV HASH: ${hashPassword(password)}");
      return true;
    }());
  }
}