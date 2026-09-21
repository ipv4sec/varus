import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecretCrypto {
  static const _storageKey = 'varus_master_key';
  static const _prefix = 'enc:v1:';
  static const _backupRounds = 10000;

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static encrypt.Key? _masterKey;

  static bool get isReady => _masterKey != null;

  /// 读取或生成主密钥（Android Keystore）。
  /// Keystore 不可用时降级为明文模式，应用仍可用。
  static Future<void> init() async {
    if (_masterKey != null) {
      return;
    }
    try {
      var stored = await _secureStorage.read(key: _storageKey);
      if (stored == null) {
        final random = Random.secure();
        stored = base64Encode(
            List<int>.generate(32, (_) => random.nextInt(256)));
        await _secureStorage.write(key: _storageKey, value: stored);
      }
      _masterKey = encrypt.Key.fromBase64(stored);
    } catch (_) {
      _masterKey = null;
    }
  }

  static bool isEncrypted(String value) => value.startsWith(_prefix);

  /// 加密 secret，格式 enc:v1:<ivB64>:<dataB64>；密钥不可用时原样返回。
  static String encryptSecret(String plaintext) {
    final key = _masterKey;
    if (key == null) {
      return plaintext;
    }
    final iv = encrypt.IV.fromSecureRandom(16);
    final data =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc))
            .encrypt(plaintext, iv: iv);
    return '$_prefix${iv.base64}:${data.base64}';
  }

  /// 解密 secret；非加密格式或解密失败时原样返回。
  static String decryptSecret(String stored) {
    if (!isEncrypted(stored)) {
      return stored;
    }
    final key = _masterKey;
    if (key == null) {
      return stored;
    }
    try {
      final parts = stored.substring(_prefix.length).split(':');
      if (parts.length != 2) {
        return stored;
      }
      final iv = encrypt.IV.fromBase64(parts[0]);
      final data = encrypt.Encrypted.fromBase64(parts[1]);
      return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc))
          .decrypt(data, iv: iv);
    } catch (_) {
      return stored;
    }
  }

  /// 备份导出：PBKDF2(password, salt) 派生密钥后 AES-CBC 加密。
  static Map<String, dynamic> encryptBackup(
      String plaintextJson, String password) {
    final random = Random.secure();
    final salt =
        Uint8List.fromList(List<int>.generate(16, (_) => random.nextInt(256)));
    final key = encrypt.Key(_pbkdf2(password, salt, _backupRounds));
    final iv = encrypt.IV.fromSecureRandom(16);
    final data =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc))
            .encrypt(plaintextJson, iv: iv);
    return {
      'format': 'varus-backup',
      'v': 1,
      'salt': base64Encode(salt),
      'iv': iv.base64,
      'data': data.base64,
    };
  }

  /// 备份导入：密码错误或格式损坏返回 null。
  static String? decryptBackup(Map<String, dynamic> backup, String password) {
    try {
      final salt = base64Decode(backup['salt'] as String);
      final iv = encrypt.IV.fromBase64(backup['iv'] as String);
      final data = encrypt.Encrypted.fromBase64(backup['data'] as String);
      final key = encrypt.Key(_pbkdf2(password, salt, _backupRounds));
      return encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc))
          .decrypt(data, iv: iv);
    } catch (_) {
      return null;
    }
  }

  /// PBKDF2-HMAC-SHA256 单块实现（dkLen=32=hLen）。
  static Uint8List _pbkdf2(String password, List<int> salt, int rounds) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final block1 = Uint8List.fromList([...salt, 0, 0, 0, 1]);
    var u = Uint8List.fromList(hmac.convert(block1).bytes);
    final result = Uint8List.fromList(u);
    for (var i = 1; i < rounds; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return result;
  }
}
