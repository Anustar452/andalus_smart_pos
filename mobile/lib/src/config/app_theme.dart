// src/config/theme/app_theme.dart
import 'package:andalus_smart_pos/src/config/theme/color_schemes.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'font_theme.dart';

class AppTheme {
  static ThemeData lightTheme(WidgetRef ref) {
    final fontTheme = ref.read(fontThemeProvider);

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      fontFamily: fontTheme.englishFont.fontFamily,
      typography: Typography.material2021(
        englishLike: Typography.englishLike2021,
        dense: Typography.dense2021,
        tall: Typography.tall2021,
      ),
      textTheme: _buildTextTheme(fontTheme, Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: fontTheme.englishFont.fontFamily,
          fontSize: 18 * fontTheme.fontSizeScale,
          fontWeight: FontWeight.w600,
          color: lightColorScheme.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontFamily: fontTheme.englishFont.fontFamily,
          fontSize: 14 * fontTheme.fontSizeScale,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: fontTheme.englishFont.fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 16 * fontTheme.fontSizeScale,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF10B981),
          side: const BorderSide(color: Color(0xFF10B981)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: fontTheme.englishFont.fontFamily,
            fontSize: 16 * fontTheme.fontSizeScale,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey.shade600,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: fontTheme.englishFont.fontFamily,
          fontSize: 12 * fontTheme.fontSizeScale,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontTheme.englishFont.fontFamily,
          fontSize: 12 * fontTheme.fontSizeScale,
        ),
      ),
    );
  }

  static ThemeData darkTheme(WidgetRef ref) {
    final fontTheme = ref.read(fontThemeProvider);

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      fontFamily: fontTheme.englishFont.fontFamily,
      typography: Typography.material2021(
        englishLike: Typography.englishLike2021,
        dense: Typography.dense2021,
        tall: Typography.tall2021,
      ),
      textTheme: _buildTextTheme(fontTheme, Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: fontTheme.englishFont.fontFamily,
          fontSize: 18 * fontTheme.fontSizeScale,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.grey.shade800,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontFamily: fontTheme.englishFont.fontFamily,
          fontSize: 14 * fontTheme.fontSizeScale,
          color: Colors.grey.shade300,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey.shade500,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: fontTheme.englishFont.fontFamily,
          fontSize: 12 * fontTheme.fontSizeScale,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontTheme.englishFont.fontFamily,
          fontSize: 12 * fontTheme.fontSizeScale,
        ),
      ),
      cardColor: Colors.grey.shade800,
      dialogBackgroundColor: Colors.grey.shade800,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.grey.shade900,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(FontTheme fontTheme, Brightness brightness) {
    final baseTextTheme = brightness == Brightness.light
        ? Typography.material2021().black
        : Typography.material2021().white;

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 96 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
      ),
      displayMedium: baseTextTheme.displayMedium!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 60 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      displaySmall: baseTextTheme.displaySmall!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 48 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: baseTextTheme.headlineMedium!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 34 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      headlineSmall: baseTextTheme.headlineSmall!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 24 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 20 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 16 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      titleSmall: baseTextTheme.titleSmall!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 14 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 16 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 14 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      labelLarge: baseTextTheme.labelLarge!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 14 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
      bodySmall: baseTextTheme.bodySmall!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 12 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelSmall: baseTextTheme.labelSmall!.copyWith(
        fontFamily: fontTheme.englishFont.fontFamily,
        fontSize: 10 * fontTheme.fontSizeScale,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
      ),
    );
  }
}

// Font Theme Provider
final fontThemeProvider =
    StateNotifierProvider<FontThemeNotifier, FontTheme>((ref) {
  return FontThemeNotifier();
});

class FontThemeNotifier extends StateNotifier<FontTheme> {
  FontThemeNotifier() : super(const FontTheme());

  void updateEnglishFont(AppFontFamily font) {
    state = state.copyWith(englishFont: font);
  }

  void updateAmharicFont(AppFontFamily font) {
    state = state.copyWith(amharicFont: font);
  }

  void updateFontScale(double scale) {
    state = state.copyWith(fontSizeScale: scale);
  }
}
