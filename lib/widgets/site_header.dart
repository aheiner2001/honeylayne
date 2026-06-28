import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

/// The sunny yellow header: the Honey Layne wordmark logo, the toggleable nav
/// row, and utility icons.
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
            // Decoration flying in from the top-left (bees by default).
            Positioned(
              top: compact ? 4 : 6,
              left: -8,
              child: IgnorePointer(
                child: _DecoImage(
                  url: settings.headerLeftImageUrl,
                  width: compact ? 110 : 190,
                ),
              ),
            ),
            // Decoration tucked into the top-right corner (florals by default).
            Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                child: _DecoImage(
                  url: settings.headerRightImageUrl,
                  width: compact ? 140 : 250,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, compact ? 14 : 18, 24, compact ? 14 : 20),
              child: Column(
                children: [
                  // Cursive wordmark with a little heart.
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Honey Layne',
                            style: HoneyTheme.logoFont(size: compact ? 40 : 56),
                          ),
                          SizedBox(width: compact ? 6 : 10),
                          Padding(
                            padding: EdgeInsets.only(top: compact ? 6 : 10),
                            child: Icon(
                              Icons.favorite_border,
                              size: compact ? 16 : 22,
                              color: HoneyColors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 10),
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
                          // Inset so the icons sit just left of the corner
                          // florals (instead of hidden behind them).
                          const Positioned(right: 140, child: _UtilityIcons()),
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

/// The single storefront icon in the top-right that opens the Instagram shop.
class _UtilityIcons extends StatelessWidget {
  const _UtilityIcons();

  static const _defaultIcon = 'assets/images/shop_icon.png';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<HoneyStore>().settings;
    final iconUrl = settings.headerShopIconUrl;
    // Tint the default line-art icon to match the theme; show custom uploads
    // (which may be full-color PNGs) as-is.
    final tint = iconUrl == _defaultIcon ? HoneyColors.pinkDeep : null;
    return Tooltip(
      message: 'Shop on Instagram',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _openShop(settings.contactInstagram),
          child: _DecoImage(url: iconUrl, width: 30, height: 30, color: tint),
        ),
      ),
    );
  }
}

Future<void> _openShop(String url) async {
  final target =
      url.isEmpty ? 'https://www.instagram.com/_honeylayne/' : url;
  final uri = Uri.tryParse(target);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Renders a header decoration from an asset path, https URL, or uploaded
/// data URI. Shows nothing when the url is empty.
class _DecoImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final Color? color;
  const _DecoImage({required this.url, this.width, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();
    const fit = BoxFit.contain;
    if (url.startsWith('data:')) {
      try {
        final bytes = base64Decode(url.substring(url.indexOf(',') + 1));
        return Image.memory(bytes,
            width: width,
            height: height,
            color: color,
            fit: fit,
            gaplessPlayback: true);
      } catch (_) {
        return const SizedBox.shrink();
      }
    }
    if (url.startsWith('http')) {
      return Image.network(url,
          width: width,
          height: height,
          color: color,
          fit: fit,
          errorBuilder: (_, _, _) => const SizedBox.shrink());
    }
    return Image.asset(url,
        width: width,
        height: height,
        color: color,
        fit: fit,
        errorBuilder: (_, _, _) => const SizedBox.shrink());
  }
}
