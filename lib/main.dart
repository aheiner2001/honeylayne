import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool authEnabled = false;
  if (kUseFirebase && DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      backend = FirebaseBackend();
      authEnabled = true;
    } catch (e, st) {
      // Never blank the site if Firebase has a hiccup — fall back to local.
      debugPrint('FIREBASE_INIT_FAILED: $e');
      debugPrint('$st');
    }
  }

  final store = HoneyStore(backend, authEnabled: authEnabled);
  runApp(HoneyApp(store: store));
}

class HoneyApp extends StatefulWidget {
  final HoneyStore store;
  const HoneyApp({super.key, required this.store});

  @override
  State<HoneyApp> createState() => _HoneyAppState();
}

class _HoneyAppState extends State<HoneyApp> {
  bool _ready = false;

  late final _router = GoRouter(
    routes: [
      _page('/', const HomePage()),
      _page('/shop', const ShopPage()),
      GoRoute(
        path: '/shop/:category',
        pageBuilder: (_, s) => NoTransitionPage(
            child: ShopPage(category: s.pathParameters['category'])),
      ),
      _page('/about', const AboutPage()),
      _page('/contact', const ContactPage()),
      _page('/manage', const ManagerPage()),
      // Keep the old link working.
      GoRoute(path: '/manager', redirect: (_, _) => '/manage'),
    ],
  );

  // A route that swaps in instantly — no slide/fade animation.
  static GoRoute _page(String path, Widget child) => GoRoute(
        path: path,
        pageBuilder: (_, _) => NoTransitionPage(child: child),
      );

  @override
  void initState() {
    super.initState();
    _boot();
  }

  /// Load saved settings AND preload the brand fonts before showing the site,
  /// so visitors never see a flash of default content or a fallback font.
  Future<void> _boot() async {
    try {
      // Referencing each font starts its download; pendingFonts awaits them.
      GoogleFonts.allura();
      GoogleFonts.dancingScript();
      GoogleFonts.cormorantGaramond();
      GoogleFonts.quicksand();
      await Future.wait<void>([
        widget.store.load(),
        GoogleFonts.pendingFonts().then((_) {}),
      ]).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Never hang on a slow font/network — show the site anyway.
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.store,
      child: MaterialApp.router(
        title: 'Honey Layne',
        debugShowCheckedModeBanner: false,
        theme: HoneyTheme.build(),
        routerConfig: _router,
        builder: (context, child) => _ready
            ? (child ?? const SizedBox.shrink())
            : const _Splash(),
      ),
    );
  }
}

/// Minimal branded splash shown while settings + fonts load. Uses an image
/// wordmark (no web font) so it itself never flashes.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HoneyColors.headerTop, HoneyColors.blush],
        ),
      ),
      child: Center(
        child: Image.asset('assets/images/logo_wordmark.png',
            width: 240, fit: BoxFit.contain),
      ),
    );
  }
}
