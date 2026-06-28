import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/product.dart';
import '../models/site_settings.dart';
import '../theme/honey_theme.dart';
import '../widgets/product_image.dart';

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
  final _controller = TextEditingController();
  bool _error = false;

  void _submit() {
    final ok = context.read<HoneyStore>().unlock(_controller.text.trim());
    setState(() => _error = !ok);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 380,
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
          children: [
            Text('Honey Layne', style: HoneyTheme.logoFont(size: 44)),
            Text('Manager Studio',
                style: HoneyTheme.serif(
                    size: 18, color: HoneyColors.text, weight: FontWeight.w500)),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              obscureText: true,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Manager password',
                errorText: _error ? 'Incorrect password' : null,
                filled: true,
                fillColor: HoneyColors.cream,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: _PinkButton(label: 'ENTER STUDIO', onTap: _submit),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => context.go('/'),
              child: Text('Back to store',
                  style: HoneyTheme.sans(size: 13, color: HoneyColors.pink)),
            ),
          ],
        ),
      ),
    );
  }
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
                    title: 'Menu visibility',
                    subtitle:
                        'Turn the top-bar links on or off. Home and Shop All always stay on.',
                    child: _NavToggles(settings: store.settings),
                  ),
                  const SizedBox(height: 22),
                  _SectionCard(
                    title: 'Homepage words',
                    subtitle: 'Edit the hero headline and welcome text.',
                    child: _CopyEditor(settings: store.settings),
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
              if (trailing != null) trailing!,
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

class _CopyEditor extends StatefulWidget {
  final SiteSettings settings;
  const _CopyEditor({required this.settings});
  @override
  State<_CopyEditor> createState() => _CopyEditorState();
}

class _CopyEditorState extends State<_CopyEditor> {
  late final _line1 = TextEditingController(text: widget.settings.heroTitleLine1);
  late final _line2 = TextEditingController(text: widget.settings.heroTitleLine2);
  late final _subtitle =
      TextEditingController(text: widget.settings.heroSubtitle);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _Field(controller: _line1, label: 'Headline line 1')),
            const SizedBox(width: 12),
            Expanded(child: _Field(controller: _line2, label: 'Headline line 2')),
          ],
        ),
        const SizedBox(height: 12),
        _Field(controller: _subtitle, label: 'Welcome text'),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: _PinkButton(
            label: 'SAVE WORDS',
            onTap: () {
              context.read<HoneyStore>().updateCopy(
                    heroTitleLine1: _line1.text,
                    heroTitleLine2: _line2.text,
                    heroSubtitle: _subtitle.text,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved')),
              );
            },
          ),
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
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1200, imageQuality: 82);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final id = widget.existing?.id ?? _pendingId;
    setState(() => _uploading = true);
    final url = await widget.store.uploadProductImage(bytes, id);
    if (!mounted) return;
    setState(() {
      _imageUrl = url;
      _uploading = false;
    });
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
  const _Field(
      {required this.controller,
      required this.label,
      this.hint,
      this.prefix,
      this.keyboardType});

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
