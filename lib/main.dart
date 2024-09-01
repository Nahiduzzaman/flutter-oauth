import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:oauth_app/router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    //initAppLinks();
    final sub = _appLinks.uriLinkStream.listen((uri) {
      print(uri.toString());
      // Do something (navigation, ...)
    });
  }

  // Future<void> initAppLinks() async {
  //   _appLinks = AppLinks();

  //   // Handle app start by deep link
  // }

  // void _handleAppLink(Uri uri) {
  //   if (uri.toString().startsWith('com.yourapp://login')) {
  //     // Navigate to login screen and clear the stack
  //     _appRouter.pushAndPopUntil(
  //       const LoginRoute(),
  //       predicate: (_) => false,
  //     );
  //   }
  // }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class GoogleSignInPage extends StatefulWidget {
  const GoogleSignInPage({super.key});

  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  static const platform = MethodChannel('com.sso.oauthapp/google_signin');

  Future<void> _handleSignIn() async {
    try {
      final String result = await platform.invokeMethod('signIn');
      final Map<String, dynamic> userData = json.decode(result);
      // Handle the signed-in user data
      print(userData);
    } on PlatformException catch (e) {
      print("Failed to sign in: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('Sign in with Google'),
        onPressed: _handleSignIn,
      ),
    );
  }
}

class AtlassianLogin extends StatefulWidget {
  const AtlassianLogin({super.key});

  @override
  _AtlassianLoginState createState() => _AtlassianLoginState();
}

class _AtlassianLoginState extends State<AtlassianLogin> {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  String? _accessToken;
  String? _userInfo;

  // Atlassian OAuth configuration
  final String _clientId = 'BjZWUuPUvCazsnUrJjscdgUuQBOjmU6C';
  final String _redirectUrl = 'com.sso.oauthapp://oauth2redirect';
  final String _discoveryUrl = 'https://auth.atlassian.com/.well-known/openid-configuration';
  final List<String> _scopes = [
    'openid',
    //'profile',
    //'email',
    //'offline_access',
    'read:jira-user',
    'read:me',
    'read:account',
    'read:jira-work'
  ];

  Future<void> _login() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          discoveryUrl: _discoveryUrl,
          scopes: _scopes,
        ),
      );

      if (result != null) {
        setState(() {
          _accessToken = result.accessToken;
        });
        print('Access Token: $_accessToken');

        // Fetch user info
        await _getUserInfo();
      }
    } catch (e) {
      print('Error during Atlassian login: $e');
    }
  }

  Future<void> _getUserInfo() async {
    final response = await http.get(
      Uri.parse('https://api.atlassian.com/me'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _userInfo = response.body;
      });
      print('User Info: $_userInfo');
    } else {
      print('Failed to get user info: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _accessToken == null
          ? ElevatedButton(
              onPressed: _login,
              child: Text('Login with Atlassian'),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Logged in successfully!'),
                SizedBox(height: 20),
                Text('User Info: ${_userInfo ?? "Loading..."}'),
              ],
            ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  // TODO: Replace with your Auth0 credentials
  static const String _clientId = '9QjrehQ0nWGonO94Ksi8UXdKchvczly2'; // e.g., 'abcdefghijklmnopqrstuvwxyz123456'
  static const String _redirectUrl = 'com.sso.oauthapp://oauth2redirect';
  static const String _issuer = 'https://dev-npbz5t3he2lvw1aq.eu.auth0.com'; // e.g., 'https://dev-xyz12345.auth0.com'

  String? _accessToken;
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Auth0 Login Demo')),
      body: Center(
        child: _isBusy
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _accessToken == null ? _loginAction : _logoutAction,
                child: Text(_accessToken == null ? 'Login' : 'Logout'),
              ),
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
    print(_accessToken);
    // You can also store other tokens like id_token or refresh_token
  }

  Future<void> _logoutAction() async {
    setState(() {
      _accessToken = null;
    });
  }
}
