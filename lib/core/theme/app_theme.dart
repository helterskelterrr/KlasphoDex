import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Inter';
  static final _radius = BorderRadius.circular(18);

  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.scannerTeal,
      onPrimary: AppColors.voidBlack,
      secondary: AppColors.rewardGold,
      onSecondary: AppColors.ink,
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.surface : AppColors.lightCard,
      onSurface: isDark ? AppColors.pearl : AppColors.lightText,
    );

    final background = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final mutedColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashColor: AppColors.scannerCyan.withValues(alpha: 0.08),
      highlightColor: AppColors.scannerCyan.withValues(alpha: 0.04),
      textTheme: _textTheme(textColor, mutedColor),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: _radius),
      ),
      dividerTheme: DividerThemeData(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: _radius),
          backgroundColor: AppColors.scannerTeal,
          foregroundColor: AppColors.voidBlack,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: _radius),
          foregroundColor: textColor,
          side: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.12,
            ),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.scannerCyan,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.08,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.scannerCyan,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        side: BorderSide(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.scannerCyan
              : mutedColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.scannerTeal.withValues(alpha: 0.35)
              : mutedColor.withValues(alpha: 0.18);
        }),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.scannerTeal.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.scannerCyan
                : mutedColor,
            letterSpacing: 0,
          );
        }),
      ),
    );
  }

  static TextTheme _textTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      displaySmall: TextStyle(
        color: textColor,
        fontSize: 34,
        fontWeight: FontWeight.w900,
        height: 1.02,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 25,
        fontWeight: FontWeight.w900,
        height: 1.12,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.25,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0,
      ),
      bodyMedium: TextStyle(
        color: mutedColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
      ),
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: 0,
      ),
      labelSmall: TextStyle(
        color: mutedColor,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: 0,
      ),
    );
  }
}
