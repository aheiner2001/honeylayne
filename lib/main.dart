import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/backend.dart';
import 'data/firebase_backend.dart';
import 'data/firebase_config.dart';
import 'data/store.dart';
import 'firebase_options.dart';
import 'pages/about_page.dart';
import 'pages/contact_page.dart';
import 'pages/home_page.dart';
import 'pages/manager_page.dart';
import 'pages/shop_page.dart';
import 'theme/honey_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clean URLs (honeylayne.com/manage) instead of the #-style (/#/manage).
  // Requires the host to rewrite unknown paths to index.html (see firebase.json).
  usePathUrlStrategy();

  HoneyBackend backend = LocalBackend();
  if (kUseFirebase && DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      backend = FirebaseBackend();
    } catch (e, st) {
      // Never blank the site if Firebase has a hiccup — fall back to local.
      debugPrint('FIREBASE_INIT_FAILED: $e');
      debugPrint('$st');
    }
  }

  final store = HoneyStore(backend)..load();
  runApp(HoneyApp(store: store));
}

class HoneyApp extends StatelessWidget {
  final HoneyStore store;
  HoneyApp({super.key, required this.store});

  late final _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomePage()),
      GoRoute(path: '/shop', builder: (_, _) => const ShopPage()),
      GoRoute(
        path: '/shop/:category',
        builder: (_, s) => ShopPage(category: s.pathParameters['category']),
      ),
      GoRoute(path: '/about', builder: (_, _) => const AboutPage()),
      GoRoute(path: '/contact', builder: (_, _) => const ContactPage()),
      GoRoute(path: '/manage', builder: (_, _) => const ManagerPage()),
      // Keep the old link working.
      GoRoute(path: '/manager', redirect: (_, _) => '/manage'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: store,
      child: MaterialApp.router(
        title: 'Honey Layne',
        debugShowCheckedModeBanner: false,
        theme: HoneyTheme.build(),
        routerConfig: _router,
      ),
    );
  }
}
