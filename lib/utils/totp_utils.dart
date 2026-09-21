import 'dart:math';

import 'package:crypto/crypto.dart';

class TotpUtils {
  static const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static List<int>? decodeBase32(String input) {
    final normalized =
        input.toUpperCase().replaceAll('=', '').replaceAll(' ', '');
    if (normalized.isEmpty) {
      return null;
    }
    var bits = 0;
    var value = 0;
    final bytes = <int>[];
    for (final char in normalized.codeUnits) {
      final digit = _base32Alphabet.indexOf(String.fromCharCode(char));
      if (digit < 0) {
        return null;
      }
      value = (value << 5) | digit;
      bits += 5;
      if (bits >= 8) {
        bytes.add((value >> (bits - 8)) & 0xFF);
        bits -= 8;
      }
    }
    return bytes;
  }

  static String? generate({
    required String secret,
    int period = 30,
    int digits = 6,
    String algorithm = 'SHA1',
    int? counter,
  }) {
    final secretBytes = decodeBase32(secret);
    if (secretBytes == null || secretBytes.isEmpty) {
      return null;
    }
    final timeCounter =
        counter ?? DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ period;
    return generateFromBytes(
      secretBytes: secretBytes,
      counter: timeCounter,
      digits: digits,
      algorithm: algorithm,
    );
  }

  static String generateFromBytes({
    required List<int> secretBytes,
    required int counter,
    int digits = 6,
    String algorithm = 'SHA1',
  }) {
    final counterBytes = List<int>.filled(8, 0);
    var v = counter;
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = v & 0xFF;
      v >>= 8;
    }
    Hmac hmac;
    switch (algorithm.toUpperCase()) {
      case 'SHA256':
        hmac = Hmac(sha256, secretBytes);
      case 'SHA512':
        hmac = Hmac(sha512, secretBytes);
      default:
        hmac = Hmac(sha1, secretBytes);
    }
    final mac = hmac.convert(counterBytes).bytes;
    final offset = mac[mac.length - 1] & 0x0F;
    final code = ((mac[offset] & 0x7F) << 24) |
        (mac[offset + 1] << 16) |
        (mac[offset + 2] << 8) |
        mac[offset + 3];
    final modulus = pow(10, digits).toInt();
    return (code % modulus).toString().padLeft(digits, '0');
  }
}
