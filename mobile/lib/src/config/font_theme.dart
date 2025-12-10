// src/config/theme/font_theme.dart
class FontTheme {
  final AppFontFamily englishFont;
  final AppFontFamily amharicFont;
  final double fontSizeScale;

  const FontTheme({
    this.englishFont = AppFontFamily.inter,
    this.amharicFont = AppFontFamily.notoSansEthiopic,
    this.fontSizeScale = 1.0,
  });

  FontTheme copyWith({
    AppFontFamily? englishFont,
    AppFontFamily? amharicFont,
    double? fontSizeScale,
  }) {
    return FontTheme(
      englishFont: englishFont ?? this.englishFont,
      amharicFont: amharicFont ?? this.amharicFont,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
    );
  }
}

enum AppFontFamily {
  inter('Inter'),
  roboto('Roboto'),
  openSans('OpenSans'),
  notoSansEthiopic('NotoSansEthiopic'),
  AbyssinicaSIL('AbyssinicaSIL');

  final String fontFamily;
  const AppFontFamily(this.fontFamily);

  String get name {
    switch (this) {
      case AppFontFamily.inter:
        return 'Inter';
      case AppFontFamily.roboto:
        return 'Roboto';
      case AppFontFamily.openSans:
        return 'Open Sans';
      case AppFontFamily.notoSansEthiopic:
        return 'Noto Sans Ethiopic';
      case AppFontFamily.AbyssinicaSIL:
        return 'Abyssinica SIL';
    }
  }
}
