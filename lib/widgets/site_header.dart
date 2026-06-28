import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../theme/honey_theme.dart';

/// Maps a top-bar label to its route.
String routeForNav(String label) {
  switch (label) {
    case 'Home':
      return '/';
    case 'Shop All':
      return '/shop';
    case 'About':
      return '/about';
    case 'Contact':
      return '/contact';
    default:
      return '/shop/$label'; // Dresses, Tops, Bottoms, Accessories
  }
}

/// The sunny yellow header: bees + flight trail (left), floral cluster (right),
/// the scripted Honey Layne wordmark, the toggleable nav row, and utility icons.
class SiteHeader extends StatelessWidget {
  final String active;
  const SiteHeader({super.key, this.active = 'Home'});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<HoneyStore>().settings;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HoneyColors.headerTop, HoneyColors.headerBottom],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Decorative bees on the left.
            Positioned(
              left: -8,
              top: 2,
              child: IgnorePointer(
                child: Image.asset('assets/images/bees_trail.png',
                    width: compact ? 130 : 196, fit: BoxFit.contain),
              ),
            ),
            // Floral cluster on the right.
            Positioned(
              right: -22,
              top: -30,
              child: IgnorePointer(
                child: Image.asset('assets/images/floral_topright.png',
                    width: compact ? 140 : 232, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, compact ? 16 : 22, 24, compact ? 14 : 20),
              child: Column(
                children: [
                  // Wordmark with heart.
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Honey Layne',
                              style:
                                  HoneyTheme.logoFont(size: compact ? 38 : 50)),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 2),
                            child: Icon(Icons.favorite_border,
                                size: compact ? 14 : 18,
                                color: HoneyColors.logo),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  // Nav centered in full width, icons pinned to the right.
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _NavRow(
                          items: settings.visibleNav,
                          active: active,
                        ),
                        if (!compact)
                          const Positioned(right: 4, child: _UtilityIcons()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final List<String> items;
  final String active;
  const _NavRow({required this.items, required this.active});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 22,
      runSpacing: 6,
      children: [
        for (final item in items)
          _NavItem(label: item, active: item == active),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final bool active;
  const _NavItem({required this.label, required this.active});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final emphasized = widget.active || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(routeForNav(widget.label)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: HoneyTheme.serif(
                size: 16,
                weight: emphasized ? FontWeight.w600 : FontWeight.w500,
                color:
                    emphasized ? HoneyColors.pinkDeep : HoneyColors.pink,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 1.5,
              width: widget.active ? 22 : 0,
              color: HoneyColors.pinkDeep,
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilityIcons extends StatelessWidget {
  const _UtilityIcons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _Icon(Icons.search),
        SizedBox(width: 14),
        _Icon(Icons.person_outline),
        SizedBox(width: 14),
        _Icon(Icons.shopping_bag_outlined),
      ],
    );
  }
}

class _Icon extends StatelessWidget {
  final IconData icon;
  const _Icon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 20, color: HoneyColors.pinkDeep);
  }
}
