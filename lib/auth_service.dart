import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _clientId = '9QjrehQ0nWGonO94Ksi8UXdKchvczly2'; // e.g., 'abcdefghijklmnopqrstuvwxyz123456'
  static const String _redirectUrl = 'com.sso.oauthapp.auth://login';
  static const String _auth0Domain = 'dev-npbz5t3he2lvw1aq.eu.auth0.com'; // e.g., 'https://dev-xyz12345.auth0.com'

  String get logoutUrl => 'https://$_auth0Domain/v2/logout?client_id=$_clientId&returnTo=$_redirectUrl';

  Future<void> clearTokens() async {
    // Clear stored tokens
    await _secureStorage.deleteAll();
  }

  Future<String?> getValidAccessToken() async {
    final String? accessToken = await _secureStorage.read(key: 'accessToken');
    final String? refreshToken = await _secureStorage.read(key: 'refreshToken');

    if (accessToken == null && refreshToken == null) {
      return null; // User needs to login
    }

    // TODO: Check if access token is expired. If yes, use refresh token to get a new one.
    // For simplicity, we're just returning the stored access token here.
    // In a real app, you'd want to check the expiration and refresh if necessary.

    return accessToken;
  }
}
