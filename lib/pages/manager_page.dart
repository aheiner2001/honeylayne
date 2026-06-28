import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/product.dart';
import '../models/site_settings.dart';
import '../theme/honey_theme.dart';
import '../widgets/product_image.dart';
import 'about_page.dart' show featureIcon;

class ManagerPage extends StatelessWidget {
  const ManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HoneyStore>();
    return Scaffold(
      backgroundColor: HoneyColors.blush,
      body: store.managerUnlocked
          ? const _Dashboard()
          : const _PasswordGate(),
    );
  }
}

// ---------------------------------------------------------------------------
class _PasswordGate extends StatefulWidget {
  const _PasswordGate();
  @override
  State<_PasswordGate> createState() => _PasswordGateState();
}

class _PasswordGateState extends State<_PasswordGate> {
  final _legacy = TextEditingController();
  final _gatePw = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _signInGoogle() async {
    final store = context.read<HoneyStore>();
    // Require the access password before opening the Google popup.
    if (!store.checkManagerPassword(_gatePw.text)) {
      setState(() => _error = 'Incorrect access password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await store.signInWithGoogle();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  void _legacySubmit() {
    final ok = context.read<HoneyStore>().unlock(_legacy.text.trim());
    setState(() => _error = ok ? null : 'Incorrect password');
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<HoneyStore>();
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 400,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: HoneyColors.pink.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 12)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Honey Layne',
                  textAlign: TextAlign.center,
                  style: HoneyTheme.logoFont(size: 44)),
              Text('Manager Studio',
                  textAlign: TextAlign.center,
                  style: HoneyTheme.serif(
                      size: 18,
                      color: HoneyColors.text,
                      weight: FontWeight.w500)),
              const SizedBox(height: 22),
              if (store.authEnabled)
                ..._googleForm()
              else
                ..._legacyForm(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: HoneyTheme.sans(
                        size: 13, color: HoneyColors.pinkDeep)),
              ],
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => context.go('/'),
                child: Text('Back to store',
                    style: HoneyTheme.sans(size: 13, color: HoneyColors.pink)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Access password + Google sign-in (used when Firebase is configured).
  List<Widget> _googleForm() => [
        Text('Enter the access password, then sign in with Google.',
            textAlign: TextAlign.center,
            style: HoneyTheme.sans(size: 13, color: HoneyColors.textSoft)),
        const SizedBox(height: 16),
        TextField(
          controller: _gatePw,
          obscureText: true,
          onSubmitted: (_) => _signInGoogle(),
          decoration: InputDecoration(
            hintText: 'Access password',
            filled: true,
            fillColor: HoneyColors.cream,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        if (_busy)
          const _Spinner()
        else
          _GoogleButton(onTap: _signInGoogle),
      ];

  // Simple build-time password (used when Firebase isn't configured).
  List<Widget> _legacyForm() => [
        TextField(
          controller: _legacy,
          obscureText: true,
          onSubmitted: (_) => _legacySubmit(),
          decoration: InputDecoration(
            hintText: 'Manager password',
            filled: true,
            fillColor: HoneyColors.cream,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),
        _PinkButton(label: 'ENTER STUDIO', onTap: _legacySubmit),
      ];
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: HoneyColors.text,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        side: const BorderSide(color: HoneyColors.blushDeep, width: 1.2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Simple multi-color "G" stand-in (no asset needed).
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4285F4),
            ),
            child: const Text('G',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Text('Continue with Google',
              style: HoneyTheme.sans(
                  size: 14,
                  color: HoneyColors.text,
                  weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
                color: HoneyColors.pink, strokeWidth: 2.4),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HoneyStore>();
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 860;

    return SingleChildScrollView(
      child: Column(
        children: [
          _ManagerHeader(),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : 48, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(
                    title: 'Access password',
                    subtitle:
                        'The password required (with Google sign-in) to open this studio.',
                    child: _PasswordChanger(
                        key: ValueKey('pw_${store.settings.managerPassword}'),
                        current: store.managerPassword),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'Menu visibility',
                    subtitle:
                        'Turn the top-bar links on or off. Home and Shop All always stay on.',
                    child: _NavToggles(settings: store.settings),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'Page sections',
                    subtitle:
                        'Show or hide whole sections on each page.',
                    child: _SectionToggles(settings: store.settings),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'Header decorations',
                    subtitle:
                        'Upload your own PNGs for the top-left art, top-right art, and shop icon. Transparent PNGs look best.',
                    child: _HeaderEditor(
                        key: ValueKey('header_${store.settings.hashCode}'),
                        settings: store.settings),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'Home page',
                    subtitle:
                        'Hero headline, welcome text, button, photo, and the favorites title.',
                    child: _HomeEditor(
                        key: ValueKey(store.settings.hashCode),
                        settings: store.settings),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'About page · Our Story',
                    subtitle:
                        'Heading, story paragraphs, photo, and the four highlights.',
                    child: _AboutEditor(
                        key: ValueKey('about_${store.settings.hashCode}'),
                        settings: store.settings),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'Contact page',
                    subtitle:
                        'The greeting and how customers can reach you.',
                    child: _ContactEditor(
                        key: ValueKey('contact_${store.settings.hashCode}'),
                        settings: store.settings),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'Footer',
                    subtitle:
                        'The tagline and link columns at the bottom of every page.',
                    child: _FooterEditor(
                        key: ValueKey('footer_${store.settings.hashCode}'),
                        settings: store.settings),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'Products',
                    subtitle:
                        'Add a photo from your phone, set a price, and paste the Instagram link.',
                    trailing: _PinkButton(
                      label: 'ADD PRODUCT',
                      icon: Icons.add,
                      onTap: () => _openEditor(context, null),
                    ),
                    child: _ProductList(products: store.products),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _openEditor(BuildContext context, Product? existing) {
  showDialog(
    context: context,
    barrierColor: HoneyColors.pinkDeep.withValues(alpha: 0.18),
    builder: (_) => _ProductEditor(existing: existing, store: context.read<HoneyStore>()),
  );
}

class _ManagerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HoneyColors.headerTop, HoneyColors.headerBottom],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      child: Row(
        children: [
          Text('Honey Layne', style: HoneyTheme.logoFont(size: 38)),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Manager Studio',
                style: HoneyTheme.serif(
                    size: 16,
                    color: HoneyColors.pinkDeep,
                    weight: FontWeight.w600)),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.open_in_new,
                size: 16, color: HoneyColors.pinkDeep),
            label: Text('View store',
                style: HoneyTheme.sans(
                    size: 13, color: HoneyColors.pinkDeep)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => context.read<HoneyStore>().lock(),
            icon: const Icon(Icons.logout,
                size: 16, color: HoneyColors.pinkDeep),
            label: Text('Log out',
                style: HoneyTheme.sans(
                    size: 13, color: HoneyColors.pinkDeep)),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  const _SectionCard(
      {required this.title,
      required this.subtitle,
      required this.child,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: HoneyColors.pink.withValues(alpha: 0.1),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: HoneyTheme.serif(
                            size: 22,
                            color: HoneyColors.pinkDeep,
                            weight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: HoneyTheme.sans(
                            size: 13, color: HoneyColors.textSoft)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _NavToggles extends StatelessWidget {
  final SiteSettings settings;
  const _NavToggles({required this.settings});

  @override
  Widget build(BuildContext context) {
    final store = context.read<HoneyStore>();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final label in SiteSettings.orderedNav)
          _ToggleChip(
            label: label,
            value: settings.navEnabled[label] ?? true,
            locked: SiteSettings.locked.contains(label),
            onChanged: (v) => store.toggleNav(label, v),
          ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool value;
  final bool locked;
  final ValueChanged<bool> onChanged;
  const _ToggleChip(
      {required this.label,
      required this.value,
      required this.locked,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: value ? HoneyColors.pink.withValues(alpha: 0.16) : HoneyColors.cream,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: value ? HoneyColors.pink : HoneyColors.blushDeep,
            width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: HoneyTheme.serif(
                  size: 16,
                  color: locked ? HoneyColors.textSoft : HoneyColors.pinkDeep,
                  weight: FontWeight.w600)),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: locked ? null : onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: HoneyColors.pink,
          ),
        ],
      ),
    );
  }
}

void _toast(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Saved'), duration: Duration(seconds: 1)),
  );
}

// ---------------------------------------------------------------------------
class _SectionToggles extends StatelessWidget {
  final SiteSettings settings;
  const _SectionToggles({required this.settings});

  @override
  Widget build(BuildContext context) {
    final store = context.read<HoneyStore>();
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final entry in SiteSettings.sections.entries)
          _ToggleChip(
            label: entry.value,
            value: settings.sectionOn(entry.key),
            locked: false,
            onChanged: (v) => store.toggleSection(entry.key, v),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
/// Lets the manager view and change the studio access password.
class _PasswordChanger extends StatefulWidget {
  final String current;
  const _PasswordChanger({super.key, required this.current});

  @override
  State<_PasswordChanger> createState() => _PasswordChangerState();
}

class _PasswordChangerState extends State<_PasswordChanger> {
  late final _controller = TextEditingController(text: widget.current);
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    context.read<HoneyStore>().updateManagerPassword(value);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Access password updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            obscureText: _obscure,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              hintText: 'Access password',
              filled: true,
              fillColor: HoneyColors.cream,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: HoneyColors.pink),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _PinkButton(label: 'SAVE', onTap: _save),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
/// A photo box that uploads a new image and reports the resulting URL.
class _ImagePickField extends StatefulWidget {
  final String label;
  final String imageUrl;
  final String storageKey;
  final ValueChanged<String> onChanged;
  /// Preserve transparency: pick the file without re-encoding to JPEG and
  /// upload it as a PNG. Use for header art and icons.
  final bool png;
  const _ImagePickField({
    required this.label,
    required this.imageUrl,
    required this.storageKey,
    required this.onChanged,
    this.png = false,
  });

  @override
  State<_ImagePickField> createState() => _ImagePickFieldState();
}

class _ImagePickFieldState extends State<_ImagePickField> {
  late String _url = widget.imageUrl;
  bool _uploading = false;

  Future<void> _pick() async {
    final store = context.read<HoneyStore>();
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    // For PNG art, skip maxWidth/imageQuality so transparency is preserved.
    final file = widget.png
        ? await picker.pickImage(source: ImageSource.gallery)
        : await picker.pickImage(
            source: ImageSource.gallery, maxWidth: 1400, imageQuality: 82);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _uploading = true);
    try {
      final url = widget.png
          ? await store.uploadImagePng(bytes, widget.storageKey)
          : await store.uploadImage(bytes, widget.storageKey);
      if (!mounted) return;
      setState(() {
        _url = url;
        _uploading = false;
      });
      widget.onChanged(url);
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      messenger.showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: HoneyTheme.sans(
                size: 12, color: HoneyColors.textSoft, weight: FontWeight.w600)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: 140,
            height: 150,
            decoration: BoxDecoration(
              color: HoneyColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: HoneyColors.pinkSoft, width: 1.4),
            ),
            clipBehavior: Clip.antiAlias,
            child: _uploading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: HoneyColors.pink, strokeWidth: 2))
                : _url.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined,
                              color: HoneyColors.pink, size: 28),
                          const SizedBox(height: 8),
                          Text('Add photo',
                              style: HoneyTheme.sans(
                                  size: 12, color: HoneyColors.pink)),
                        ],
                      )
                    : ProductImage(imageUrl: _url),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _HeaderEditor extends StatefulWidget {
  final SiteSettings settings;
  const _HeaderEditor({super.key, required this.settings});
  @override
  State<_HeaderEditor> createState() => _HeaderEditorState();
}

class _HeaderEditorState extends State<_HeaderEditor> {
  late String _left = widget.settings.headerLeftImageUrl;
  late String _right = widget.settings.headerRightImageUrl;
  late String _icon = widget.settings.headerShopIconUrl;
  late final _shopLink =
      TextEditingController(text: widget.settings.contactInstagram);

  @override
  void dispose() {
    _shopLink.dispose();
    super.dispose();
  }

  void _save() {
    final store = context.read<HoneyStore>();
    store.updateSettings(store.settings.copyWith(
      headerLeftImageUrl: _left,
      headerRightImageUrl: _right,
      headerShopIconUrl: _icon,
      contactInstagram: _shopLink.text.trim(),
    ));
    _toast(context);
  }

  void _reset() {
    final store = context.read<HoneyStore>();
    store.updateSettings(store.settings.copyWith(
      headerLeftImageUrl: 'assets/images/bees_trail.png',
      headerRightImageUrl: 'assets/images/floral_topright.png',
      headerShopIconUrl: 'assets/images/shop_icon.png',
    ));
    _toast(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            _ImagePickField(
              label: 'Top-left art',
              imageUrl: _left,
              storageKey: 'header_left',
              png: true,
              onChanged: (u) => _left = u,
            ),
            _ImagePickField(
              label: 'Top-right art',
              imageUrl: _right,
              storageKey: 'header_right',
              png: true,
              onChanged: (u) => _right = u,
            ),
            _ImagePickField(
              label: 'Shop icon',
              imageUrl: _icon,
              storageKey: 'header_shop_icon',
              png: true,
              onChanged: (u) => _icon = u,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Field(
          controller: _shopLink,
          label: 'Instagram shop link (opens when the shop icon is tapped)',
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _reset,
              child: Text('Reset to defaults',
                  style: HoneyTheme.sans(size: 13, color: HoneyColors.pink)),
            ),
            const SizedBox(width: 12),
            _PinkButton(label: 'SAVE HEADER', onTap: _save),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _HomeEditor extends StatefulWidget {
  final SiteSettings settings;
  const _HomeEditor({super.key, required this.settings});
  @override
  State<_HomeEditor> createState() => _HomeEditorState();
}

class _HomeEditorState extends State<_HomeEditor> {
  late final _line1 = TextEditingController(text: widget.settings.heroTitleLine1);
  late final _line2 = TextEditingController(text: widget.settings.heroTitleLine2);
  late final _subtitle =
      TextEditingController(text: widget.settings.heroSubtitle);
  late final _button =
      TextEditingController(text: widget.settings.heroButtonLabel);
  late final _favTitle =
      TextEditingController(text: widget.settings.favoritesTitle);
  late String _heroImage = widget.settings.heroImageUrl;

  void _save() {
    final store = context.read<HoneyStore>();
    store.updateSettings(store.settings.copyWith(
      heroTitleLine1: _line1.text,
      heroTitleLine2: _line2.text,
      heroSubtitle: _subtitle.text,
      heroButtonLabel: _button.text,
      favoritesTitle: _favTitle.text,
      heroImageUrl: _heroImage,
    ));
    _toast(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImagePickField(
              label: 'Hero photo',
              imageUrl: _heroImage,
              storageKey: 'hero',
              onChanged: (u) => _heroImage = u,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _Field(
                              controller: _line1, label: 'Headline line 1')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _Field(
                              controller: _line2, label: 'Headline line 2')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Field(controller: _subtitle, label: 'Welcome text'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _Field(controller: _button, label: 'Button label')),
            const SizedBox(width: 12),
            Expanded(
                child: _Field(
                    controller: _favTitle, label: 'Favorites section title')),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: _PinkButton(label: 'SAVE HOME', onTap: _save),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _AboutEditor extends StatefulWidget {
  final SiteSettings settings;
  const _AboutEditor({super.key, required this.settings});
  @override
  State<_AboutEditor> createState() => _AboutEditorState();
}

class _AboutEditorState extends State<_AboutEditor> {
  late final _title = TextEditingController(text: widget.settings.aboutTitle);
  late final _body1 = TextEditingController(text: widget.settings.aboutBody1);
  late final _body2 = TextEditingController(text: widget.settings.aboutBody2);
  late final _thanks =
      TextEditingController(text: widget.settings.aboutThankYou);
  late String _image = widget.settings.aboutImageUrl;
  late final List<FeatureItem> _features =
      List<FeatureItem>.from(widget.settings.aboutFeatures);
  late final List<TextEditingController> _featureCtrls = [
    for (final f in _features) TextEditingController(text: f.text),
  ];

  static const _iconKeys = ['leaf', 'heart', 'flower', 'bag', 'star', 'sparkle'];

  void _save() {
    final store = context.read<HoneyStore>();
    final features = [
      for (var i = 0; i < _features.length; i++)
        _features[i].copyWith(text: _featureCtrls[i].text),
    ];
    store.updateSettings(store.settings.copyWith(
      aboutTitle: _title.text,
      aboutBody1: _body1.text,
      aboutBody2: _body2.text,
      aboutThankYou: _thanks.text,
      aboutImageUrl: _image,
      aboutFeatures: features,
    ));
    _toast(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImagePickField(
              label: 'Story photo',
              imageUrl: _image,
              storageKey: 'about',
              onChanged: (u) => _image = u,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                children: [
                  _Field(controller: _title, label: 'Heading'),
                  const SizedBox(height: 12),
                  _Field(controller: _thanks, label: 'Closing line'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Field(controller: _body1, label: 'Story paragraph 1'),
        const SizedBox(height: 12),
        _Field(controller: _body2, label: 'Story paragraph 2'),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Highlights',
              style: HoneyTheme.serif(
                  size: 16,
                  color: HoneyColors.pinkDeep,
                  weight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _features.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _IconPicker(
                  value: _features[i].icon,
                  options: _iconKeys,
                  onChanged: (v) =>
                      setState(() => _features[i] = _features[i].copyWith(icon: v)),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _Field(
                        controller: _featureCtrls[i],
                        label: 'Highlight ${i + 1}')),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: _PinkButton(label: 'SAVE ABOUT', onTap: _save),
        ),
      ],
    );
  }
}

class _IconPicker extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _IconPicker(
      {required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 50,
      decoration: BoxDecoration(
        color: HoneyColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: HoneyColors.pink),
          items: [
            for (final k in options)
              DropdownMenuItem(
                value: k,
                child: Icon(featureIcon(k), color: HoneyColors.pinkDeep, size: 22),
              ),
          ],
          onChanged: (v) => onChanged(v ?? value),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _ContactEditor extends StatefulWidget {
  final SiteSettings settings;
  const _ContactEditor({super.key, required this.settings});
  @override
  State<_ContactEditor> createState() => _ContactEditorState();
}

class _ContactEditorState extends State<_ContactEditor> {
  late final _title = TextEditingController(text: widget.settings.contactTitle);
  late final _blurb = TextEditingController(text: widget.settings.contactBlurb);
  late final _email = TextEditingController(text: widget.settings.contactEmail);
  late final _instagram =
      TextEditingController(text: widget.settings.contactInstagram);
  late final _phone = TextEditingController(text: widget.settings.contactPhone);

  void _save() {
    final store = context.read<HoneyStore>();
    store.updateSettings(store.settings.copyWith(
      contactTitle: _title.text,
      contactBlurb: _blurb.text,
      contactEmail: _email.text,
      contactInstagram: _instagram.text,
      contactPhone: _phone.text,
    ));
    _toast(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Field(controller: _title, label: 'Heading'),
        const SizedBox(height: 12),
        _Field(controller: _blurb, label: 'Greeting text'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _Field(controller: _email, label: 'Email')),
            const SizedBox(width: 12),
            Expanded(
                child: _Field(controller: _phone, label: 'Phone (optional)')),
          ],
        ),
        const SizedBox(height: 12),
        _Field(controller: _instagram, label: 'Instagram link'),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: _PinkButton(label: 'SAVE CONTACT', onTap: _save),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _FooterEditor extends StatefulWidget {
  final SiteSettings settings;
  const _FooterEditor({super.key, required this.settings});
  @override
  State<_FooterEditor> createState() => _FooterEditorState();
}

class _FooterEditorState extends State<_FooterEditor> {
  late final _tagline =
      TextEditingController(text: widget.settings.footerTagline);
  late final List<TextEditingController> _titles = [
    for (final c in widget.settings.footerColumns)
      TextEditingController(text: c.title),
  ];
  late final List<TextEditingController> _links = [
    for (final c in widget.settings.footerColumns)
      TextEditingController(
          text: c.links.map(_linkToLine).join('\n')),
  ];

  static String _linkToLine(FooterLink l) =>
      l.url.isEmpty ? l.label : '${l.label} | ${l.url}';

  static FooterLink _lineToLink(String line) {
    final i = line.indexOf('|');
    if (i < 0) return FooterLink(label: line.trim());
    return FooterLink(
        label: line.substring(0, i).trim(), url: line.substring(i + 1).trim());
  }

  void _save() {
    final store = context.read<HoneyStore>();
    final cols = [
      for (var i = 0; i < _titles.length; i++)
        FooterColumn(
          title: _titles[i].text,
          links: _links[i]
              .text
              .split('\n')
              .where((e) => e.trim().isNotEmpty)
              .map(_lineToLink)
              .toList(),
        ),
    ];
    store.updateSettings(store.settings.copyWith(
      footerTagline: _tagline.text,
      footerColumns: cols,
    ));
    _toast(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(controller: _tagline, label: 'Tagline (under the logo)'),
        const SizedBox(height: 10),
        Text(
          'Links: one per line. To make a link clickable add "  | link" after '
          'the name — e.g. "Dresses | /shop/Dresses" for a page on this site, '
          'or "Instagram | https://instagram.com/_honeylayne/" for an outside '
          'link. No "|" = plain text.',
          style: HoneyTheme.sans(size: 12, color: HoneyColors.textSoft),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (var i = 0; i < _titles.length; i++)
              SizedBox(
                width: 260,
                child: Column(
                  children: [
                    _Field(controller: _titles[i], label: 'Column ${i + 1} title'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _links[i],
                      label: 'Links (Name | link)',
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: _PinkButton(label: 'SAVE FOOTER', onTap: _save),
        ),
      ],
    );
  }
}

class _ProductList extends StatelessWidget {
  final List<Product> products;
  const _ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text('No products yet. Tap “Add product” to begin.',
            style: HoneyTheme.sans(color: HoneyColors.textSoft)),
      );
    }
    return Column(
      children: [
        for (final p in products)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: HoneyColors.blush.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                      width: 54,
                      height: 64,
                      child: ProductImage(imageUrl: p.imageUrl)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: HoneyTheme.serif(
                              size: 18, color: HoneyColors.pinkDeep)),
                      Text('${p.category}  •  \$${p.price.toStringAsFixed(2)}',
                          style: HoneyTheme.sans(
                              size: 12, color: HoneyColors.textSoft)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: HoneyColors.pink, size: 20),
                  onPressed: () => _openEditor(context, p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: HoneyColors.pinkDeep, size: 20),
                  onPressed: () =>
                      context.read<HoneyStore>().removeProduct(p.id),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
class _ProductEditor extends StatefulWidget {
  final Product? existing;
  final HoneyStore store;
  const _ProductEditor({required this.existing, required this.store});
  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _price = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.price.toStringAsFixed(2)
          : '');
  late final _instagram =
      TextEditingController(text: widget.existing?.instagramUrl ?? '');
  late String _category = widget.existing?.category ?? 'Dresses';
  late String _imageUrl = widget.existing?.imageUrl ?? '';
  late final String _pendingId =
      widget.existing?.id ?? 'p_${DateTime.now().millisecondsSinceEpoch}';
  bool _favorite = true;

  @override
  void initState() {
    super.initState();
    _favorite = widget.existing?.favorite ?? true;
  }

  bool _uploading = false;

  Future<void> _pickImage() async {
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1200, imageQuality: 82);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final id = widget.existing?.id ?? _pendingId;
    setState(() => _uploading = true);
    try {
      final url = await widget.store.uploadProductImage(bytes, id);
      if (!mounted) return;
      setState(() {
        _imageUrl = url;
        _uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      messenger.showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')));
    }
  }

  void _save() {
    final price = double.tryParse(_price.text.trim()) ?? 0;
    final product = Product(
      id: _pendingId,
      name: _name.text.trim().isEmpty ? 'New Piece' : _name.text.trim(),
      price: price,
      category: _category,
      imageUrl: _imageUrl,
      instagramUrl: _instagram.text.trim(),
      favorite: _favorite,
    );
    if (widget.existing == null) {
      widget.store.addProduct(product);
    } else {
      widget.store.updateProduct(product);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HoneyColors.blush,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.existing == null ? 'Add product' : 'Edit product',
                  style: HoneyTheme.serif(
                      size: 24,
                      color: HoneyColors.pinkDeep,
                      weight: FontWeight.w600)),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                      color: HoneyColors.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: HoneyColors.pinkSoft, width: 1.4),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _uploading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: HoneyColors.pink, strokeWidth: 2))
                        : _imageUrl.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_a_photo_outlined,
                                      color: HoneyColors.pink, size: 30),
                                  const SizedBox(height: 8),
                                  Text('Add photo',
                                      style: HoneyTheme.sans(
                                          size: 13, color: HoneyColors.pink)),
                                ],
                              )
                            : ProductImage(imageUrl: _imageUrl),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _Field(controller: _name, label: 'Name'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                        controller: _price,
                        label: 'Price',
                        prefix: '\$',
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _CategoryDropdown(
                    value: _category,
                    onChanged: (v) => setState(() => _category = v),
                  )),
                ],
              ),
              const SizedBox(height: 12),
              _Field(
                  controller: _instagram,
                  label: 'Instagram link',
                  hint: 'https://instagram.com/p/...'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: _favorite,
                    onChanged: (v) => setState(() => _favorite = v),
                    activeThumbColor: Colors.white,
                    activeTrackColor: HoneyColors.pink,
                  ),
                  Text('Show in “Shop Our Favorites”',
                      style: HoneyTheme.sans(
                          size: 13, color: HoneyColors.text)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel',
                        style: HoneyTheme.sans(
                            size: 14, color: HoneyColors.textSoft)),
                  ),
                  const SizedBox(width: 10),
                  _PinkButton(label: 'SAVE', onTap: _save),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category',
            style: HoneyTheme.sans(
                size: 12,
                color: HoneyColors.textSoft,
                weight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: HoneyColors.cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: HoneyColors.pink),
              style: HoneyTheme.serif(size: 16, color: HoneyColors.text),
              items: const ['Dresses', 'Tops', 'Bottoms', 'Accessories']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => onChanged(v ?? value),
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? prefix;
  final TextInputType? keyboardType;
  final int maxLines;
  const _Field(
      {required this.controller,
      required this.label,
      this.hint,
      this.prefix,
      this.keyboardType,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: HoneyTheme.sans(
                size: 12,
                color: HoneyColors.textSoft,
                weight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: HoneyTheme.serif(size: 16, color: HoneyColors.text),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            isDense: true,
            filled: true,
            fillColor: HoneyColors.cream,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class _PinkButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  const _PinkButton({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: HoneyColors.pink,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16),
          if (icon != null) const SizedBox(width: 6),
          Text(label,
              style: HoneyTheme.sans(
                  size: 13,
                  color: Colors.white,
                  weight: FontWeight.w600,
                  spacing: 1.0)),
        ],
      ),
    );
  }
}
