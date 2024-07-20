import 'package:encrypt/encrypt.dart';

// Invalid argument(s): Key length not 128/192/256 bits.
const _encryptionKey = 'Bb!1(V&3M%eAgL3A'; //TODO store to FB
final _key = Key.fromUtf8(_encryptionKey);
final _iv = IV.fromLength(16);
final _encryptInstance = Encrypter(AES(_key));

String encryptTextToBase64(String dataToBeEncrypted) {
  final encrypted = _encryptInstance.encrypt(dataToBeEncrypted, iv: _iv);
  return encrypted.base64;
}

String decryptTextFromBase64(String dataToBeDecryptedBase64) {
  final decrypted =
      _encryptInstance.decrypt64(dataToBeDecryptedBase64, iv: _iv);
  return decrypted;
}
