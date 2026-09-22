import 'package:go_router/go_router.dart';
import 'package:olympia_weekend/screens/home_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, _) => const HomeScreen(),
      ),
    ],
  );
}
