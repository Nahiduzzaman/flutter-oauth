import 'package:auto_route/auto_route.dart';
import 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: true, path: '/login'),
        AutoRoute(page: HomeRoute.page, path: '/home'),
        AutoRoute(page: LogoutRoute.page, path: '/home'),
        // Add other routes as needed
      ];
}
