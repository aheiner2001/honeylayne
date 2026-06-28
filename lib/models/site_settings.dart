/// Navigation links the manager can toggle on/off, plus editable copy.
class SiteSettings {
  /// Map of nav label -> enabled. "Home" and "Shop All" are always on.
  final Map<String, bool> navEnabled;
  final String heroTitleLine1;
  final String heroTitleLine2;
  final String heroSubtitle;
  final String storyText;

  const SiteSettings({
    required this.navEnabled,
    this.heroTitleLine1 = 'Sweet style',
    this.heroTitleLine2 = 'for sunny days',
    this.heroSubtitle = 'Romantic pieces made to make you feel beautiful.',
    this.storyText =
        'Honey Layne was created with a love for romantic style, soft details, and the beauty of everyday moments.',
  });

  static const orderedNav = [
    'Home',
    'Shop All',
    'Dresses',
    'Tops',
    'Bottoms',
    'Accessories',
    'About',
    'Contact',
  ];

  /// Links that cannot be turned off.
  static const locked = {'Home', 'Shop All'};

  factory SiteSettings.initial() => SiteSettings(
        navEnabled: {for (final n in orderedNav) n: true},
      );

  List<String> get visibleNav =>
      orderedNav.where((n) => navEnabled[n] ?? true).toList();

  SiteSettings copyWith({
    Map<String, bool>? navEnabled,
    String? heroTitleLine1,
    String? heroTitleLine2,
    String? heroSubtitle,
    String? storyText,
  }) =>
      SiteSettings(
        navEnabled: navEnabled ?? this.navEnabled,
        heroTitleLine1: heroTitleLine1 ?? this.heroTitleLine1,
        heroTitleLine2: heroTitleLine2 ?? this.heroTitleLine2,
        heroSubtitle: heroSubtitle ?? this.heroSubtitle,
        storyText: storyText ?? this.storyText,
      );

  Map<String, dynamic> toJson() => {
        'navEnabled': navEnabled,
        'heroTitleLine1': heroTitleLine1,
        'heroTitleLine2': heroTitleLine2,
        'heroSubtitle': heroSubtitle,
        'storyText': storyText,
      };

  factory SiteSettings.fromJson(Map<String, dynamic> j) {
    final raw = (j['navEnabled'] as Map?)?.cast<String, dynamic>() ?? {};
    return SiteSettings(
      navEnabled: {
        for (final n in orderedNav) n: (raw[n] as bool?) ?? true,
      },
      heroTitleLine1: j['heroTitleLine1'] as String? ?? 'Sweet style',
      heroTitleLine2: j['heroTitleLine2'] as String? ?? 'for sunny days',
      heroSubtitle: j['heroSubtitle'] as String? ??
          'Romantic pieces made to make you feel beautiful.',
      storyText: j['storyText'] as String? ??
          'Honey Layne was created with a love for romantic style, soft details, and the beauty of everyday moments.',
    );
  }
}
