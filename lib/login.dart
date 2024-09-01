import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth_app/auth_service.dart';
import 'package:oauth_app/main.dart';
import 'package:oauth_app/router.gr.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // TODO: Replace with your Auth0 credentials
  static const String _clientId = '9QjrehQ0nWGonO94Ksi8UXdKchvczly2'; // e.g., 'abcdefghijklmnopqrstuvwxyz123456'

  // if this url is not same as you entered on the web version, you will get callback url mismatch error
  static const String _redirectUrl = 'com.sso.oauthapp.auth://oauth2redirect';
  static const String _issuer = 'https://dev-npbz5t3he2lvw1aq.eu.auth0.com'; // e.g., 'https://dev-xyz12345.auth0.com'

  String? _accessToken;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    setState(() {
      _isBusy = true;
    });

    final String? accessToken = await authService.getValidAccessToken();

    setState(() {
      _isBusy = false;
      _accessToken = accessToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auth0 Login Demo')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GoogleSignInPage(),
          AtlassianLogin(),
          Center(
            child: _isBusy
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _accessToken == null ? _loginAction : _logoutAction,
                    child: Text(_accessToken == null ? 'Login' : 'Logout'),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _loginAction() async {
    setState(() {
      _isBusy = true;
    });

    try {
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer,
          scopes: ['openid', 'profile', 'email'],
          promptValues: _accessToken == null ? ['login'] : null,
          additionalParameters: {
            'android_package_name': 'com.sso.oauthapp',
          },
        ),
      );

      if (result != null) {
        _processAuthResponse(result);
        setState(() {
          _isBusy = false;
        });
      }
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        _isBusy = false;
      });
    }
  }

  void _processAuthResponse(AuthorizationTokenResponse response) {
    setState(() {
      _accessToken = response.accessToken;
    });
    secureStorage.write(key: 'accessToken', value: _accessToken);
    context.router.push(const HomeRoute());
    print(_accessToken);
    // You can also store other tokens like id_token or refresh_token
  }

  Future<void> _logoutAction() async {
    await secureStorage.deleteAll();
    setState(() {
      _accessToken = null;
    });
  }
}
