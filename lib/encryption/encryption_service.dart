import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final String _secretKey =
      "chave-secreta-32-bits!"; // Exatamente 32 caracteres

  // Gera uma chave AES de 32 bytes
  static encrypt.Key _generateKey() {
    final keyBytes = utf8.encode(_secretKey);
    final key = sha256.convert(keyBytes).bytes.sublist(0, 32);
    return encrypt.Key(Uint8List.fromList(key));
  }

  // Criptografar mensagem
  static String encryptMessage(String message) {
    final key = _generateKey();
    final iv = encrypt.IV.fromLength(16); // IV aleatório de 16 bytes

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(message, iv: iv);

    // Concatena IV + mensagem criptografada e converte para Base64
    final encryptedData = iv.bytes + encrypted.bytes;
    return base64.encode(encryptedData);
  }

  // Descriptografar mensagem
  static String decryptMessage(String encryptedMessage) {
    try {
      // Verifica se a mensagem realmente está criptografada
      if (!_isBase64(encryptedMessage)) {
        return encryptedMessage; // Retorna o texto original
      }

      // Ajusta padding se necessário
      encryptedMessage = _padBase64(encryptedMessage);

      final key = _generateKey();
      final decodedData = base64.decode(encryptedMessage);

      if (decodedData.length < 16) {
        throw FormatException(
          "Dados codificados são muito curtos para conter um IV válido.",
        );
      }

      // Extrai o IV (primeiros 16 bytes)
      final iv = encrypt.IV(Uint8List.fromList(decodedData.sublist(0, 16)));
      final encryptedBytes = Uint8List.fromList(decodedData.sublist(16));

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(encryptedBytes),
        iv: iv,
      );

      return decrypted;
    } catch (e) {
      print("Erro ao descriptografar: $e");
      return encryptedMessage; // Retorna a mensagem original para evitar falhas
    }
  }

  // Verifica se a string é um Base64 válido
  static bool _isBase64(String str) {
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Regex.hasMatch(str) && (str.length % 4 == 0);
  }

  // Adiciona padding se necessário
  static String _padBase64(String str) {
    while (str.length % 4 != 0) {
      str += "=";
    }
    return str;
  }
}
