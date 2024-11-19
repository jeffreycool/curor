import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionService {
  static late final EncryptionService instance; // 单例实例
  late final Encrypter _encrypter; // 加密器
  late final IV _iv; // 初始化向量

  // 初始化方法，接受一个密钥
  static Future<void> initialize(String secretKey) async {
    // 从密钥生成一个 32 字节的 AES 密钥
    final key = Key.fromUtf8(
        sha256.convert(utf8.encode(secretKey)).toString().substring(0, 32));
    final iv = IV.fromLength(16); // 生成一个 16 字节的初始化向量
    final encrypter = Encrypter(AES(key)); // 创建 AES 加密器

    instance = EncryptionService._(encrypter, iv); // 初始化单例
  }

  // 私有构造函数
  EncryptionService._(this._encrypter, this._iv);

  // 加密方法
  String encrypt(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64; // 返回 Base64 编码的加密数据
  }

  // 解密方法
  String decrypt(String encryptedData) {
    return _encrypter.decrypt64(encryptedData, iv: _iv); // 解密并返回原始数据
  }

  // 加密 Map 中的字符串值
  Map<String, dynamic> encryptMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is String) {
        return MapEntry(key, encrypt(value)); // 加密字符串值
      }
      return MapEntry(key, value); // 保持其他类型不变
    });
  }

  // 解密 Map 中的字符串值
  Map<String, dynamic> decryptMap(Map<String, dynamic> encryptedData) {
    return encryptedData.map((key, value) {
      if (value is String) {
        return MapEntry(key, decrypt(value)); // 解密字符串值
      }
      return MapEntry(key, value); // 保持其他类型不变
    });
  }
}
