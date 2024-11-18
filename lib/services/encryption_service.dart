import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionService {
  static late final EncryptionService instance;
  late final Encrypter _encrypter;
  late final IV _iv;

  static Future<void> initialize(String secretKey) async {
    final key = Key.fromUtf8(
        sha256.convert(utf8.encode(secretKey)).toString().substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    instance = EncryptionService._(encrypter, iv);
  }

  EncryptionService._(this._encrypter, this._iv);

  String encrypt(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  String decrypt(String encryptedData) {
    return _encrypter.decrypt64(encryptedData, iv: _iv);
  }

  Map<String, dynamic> encryptMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is String) {
        return MapEntry(key, encrypt(value));
      }
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> decryptMap(Map<String, dynamic> encryptedData) {
    return encryptedData.map((key, value) {
      if (value is String) {
        return MapEntry(key, decrypt(value));
      }
      return MapEntry(key, value);
    });
  }
}
