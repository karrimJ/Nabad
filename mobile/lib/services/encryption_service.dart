import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FieldEncryptionService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyPrefix = 'nabad_enc_key_';

  String get _storageKey {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('User must be signed in to use encryption');
    return '$_keyPrefix$uid';
  }

  Future<enc.Key> _getOrCreateKey() async {
    String? b64 = await _storage.read(key: _storageKey);

    if (b64 == null) {
      final random = Random.secure();
      final bytes = Uint8List.fromList(
        List<int>.generate(32, (_) => random.nextInt(256)),
      );
      b64 = base64Encode(bytes);
      await _storage.write(key: _storageKey, value: b64);
    }

    return enc.Key(base64Decode(b64));
  }

  Future<String> encrypt(String? plaintext) async {
    if (plaintext == null || plaintext.isEmpty) return '';

    final key = await _getOrCreateKey();
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${base64Encode(iv.bytes)}:${encrypted.base64}';
  }

  Future<String> decrypt(String? ciphertext) async {
    if (ciphertext == null || ciphertext.isEmpty) return '';

    if (!ciphertext.contains(':')) return ciphertext;

    try {
      final parts = ciphertext.split(':');
      if (parts.length != 2) return ciphertext;

      final key = await _getOrCreateKey();
      final iv = enc.IV(base64Decode(parts[0]));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (_) {
      return '';
    }
  }

  Future<void> deleteKey() async {
    await _storage.delete(key: _storageKey);
  }
}