import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:oauth_app/auth_service.dart';
import 'package:oauth_app/router.gr.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class LogoutScreen extends StatefulWidget {
  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  late WebViewController controller;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('com.sso.oauthapp.auth://login')) {
              // Logout complete, navigate to login screen
              context.router.pushAndPopUntil(
                const LoginRoute(),
                predicate: (_) => false,
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_authService.logoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Logging out...')),
      body: WebViewWidget(controller: controller),
    );
  }
}
