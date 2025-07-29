import 'dart:async'; // Required for Future
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Required for secure storage

// Consider using a secure storage solution like flutter_secure_storage
// to store sensitive information like tokens.
class TokenService {
  // TODO: Implement the methods for TokenService, like getToken()

  // Create storage
  static final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    // Read value 
    final token = await _storage.read(key: _tokenKey);
    return token; 
  }

  static Future<void> saveToken(String token) async {
    // Write value 
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> deleteToken() async {
    // Delete value 
    await _storage.delete(key: _tokenKey);
  }
} 