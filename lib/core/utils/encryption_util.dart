import 'dart:developer';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionUtil {
  static String validJsonString(String originalString) {
    String vj = originalString
        .replaceAllMapped(
          RegExp(r'text:\s*([^]+?)(?=,\s*date:|$)'),
          (match) => 'text: "${match.group(1)}"',
        )
        .replaceAllMapped(
          RegExp(r'date:\s*([^,}]+)'),
          (match) => 'date: "${match.group(1)}"',
        )
        .replaceAllMapped(
          RegExp(r'([a-zA-Z_]+):'),
          (match) => '"${match.group(1)}":',
        );

    return vj;
  }

  static Future<String?> encryptJson(String json, String userEmail) async {
    try {
      final encryptedEmail = encryptEmail(userEmail);

      if (encryptedEmail == null) {
        throw Exception("Error in encryption");
      }
      final key = encrypt.Key.fromUtf8((encryptedEmail * 10).substring(0, 32));
      final iv = encrypt.IV.fromSecureRandom(16);

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      final encrypted = encrypter.encrypt(json, iv: iv);
      return "${iv.base64}:${encrypted.base64}";
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static Future<String?> decryptJson(
      String encryptedJson, String userEmail) async {
    try {
      final encryptedEmail = encryptEmail(userEmail);
      if (encryptedEmail == null) {
        throw Exception("Error in encryption");
      }
      final key = encrypt.Key.fromUtf8((encryptedEmail * 10).substring(0, 32));

      final parts = encryptedJson.split(":");
      if (parts.length != 2) {
        throw Exception("Invalid encrypted data format");
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedContent = parts[1];

      final encrypter =
          encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

      final decrypted = encrypter.decrypt64(encryptedContent, iv: iv);
      return decrypted;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  static String? encryptEmail(String userEmail) {
    String key = dotenv.env['ENCRYPT_KEY']!;
    return ('$key$userEmail' * 3).substring(0, 32);
  }
}
