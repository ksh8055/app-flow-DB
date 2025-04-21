import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordHasher {
  /// Generates a secure hash with SHA-256, salt, and key stretching
  static String hash(String password) {
    if (password.isEmpty) throw ArgumentError('Password cannot be empty');
    
    // Use a fixed salt (for demonstration) - in production use dynamic salts
    // Removed DateTime.now() from const initialization
    const salt = "secure_salt_2024"; 
    
    // Key stretching (100,000 iterations)
    var hash = sha256.convert(utf8.encode(password + salt)).toString();
    for (var i = 0; i < 100000; i++) {
      hash = sha256.convert(utf8.encode(hash + salt)).toString();
    }
    
    return 'sha256\$iterations=100000\$$salt\$$hash';
  }

  /// Verifies password against stored hash
  static bool verify(String inputPassword, String storedHash) {
    try {
      final parts = storedHash.split('\$');
      if (parts.length != 4) return false;
      
      final iterations = int.tryParse(parts[1].split('=')[1]) ?? 0;
      final salt = parts[2];
      final originalHash = parts[3];

      // Recompute hash
      var currentHash = sha256.convert(utf8.encode(inputPassword + salt)).toString();
      for (var i = 0; i < iterations; i++) {
        currentHash = sha256.convert(utf8.encode(currentHash + salt)).toString();
      }

      return currentHash == originalHash;
    } catch (e) {
      return false;
    }
  }
}