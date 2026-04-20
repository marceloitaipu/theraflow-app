import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de design da TheraFlow.
///
/// Centraliza paleta de cores, tipografia e estilos de componentes
/// para garantir uma identidade visual consistente, vibrante e profissional
/// em toda a aplicação.
class AppTheme {
  AppTheme._();

  // ===== Paleta da marca =====
  static const Color brandPrimary = Color(0xFF5B5BF7); // Indigo vivo
  static const Color brandPrimaryDark = Color(0xFF4338CA);
  static const Color brandSecondary = Color(0xFF14B8A6); // Teal
  static const Color brandTertiary = Color(0xFFF59E0B); // Amber

  // ===== Cores semânticas =====
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ===== Neutros =====
  static const Color surfaceLight = Color(0xFFF7F8FC);
  static const Color surfaceDark = Color(0xFF0F1115);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A1D24);

  // ===== Tema claro =====
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.light,
      primary: brandPrimary,
      secondary: brandSecondary,
      tertiary: brandTertiary,
      error: danger,
      surface: cardLight,
    ).copyWith(
      surfaceContainerLowest: surfaceLight,
      surfaceContainerLow: const Color(0xFFEEF0F8),
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ===== Tema escuro =====
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8),
      secondary: const Color(0xFF2DD4BF),
      tertiary: const Color(0xFFFBBF24),
      error: const Color(0xFFF87171),
      surface: cardDark,
    ).copyWith(
      surfaceContainerLowest: surfaceDark,
      surfaceContainerLow: const Color(0xFF161922),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme cs, Brightness brightness) {
    final base = ThemeData(useMaterial3: true, brightness: brightness);
    final isDark = brightness == Brightness.dark;

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: isDark ? surfaceDark : surfaceLight,
      canvasColor: isDark ? surfaceDark : surfaceLight,

      // ===== AppBar =====
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isDark ? surfaceDark : surfaceLight,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.primary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
          letterSpacing: -0.2,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // ===== Texto =====
      textTheme: base.textTheme
          .apply(
            bodyColor: cs.onSurface,
            displayColor: cs.onSurface,
          )
          .copyWith(
            headlineSmall: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.85),
              height: 1.4,
            ),
            labelLarge: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),

      // ===== Cards =====
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: isDark ? cardDark : cardLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),

      // ===== Inputs =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: cs.onSurface.withValues(alpha: 0.45),
        ),
        labelStyle: TextStyle(
          color: cs.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: cs.onSurface.withValues(alpha: 0.6),
        suffixIconColor: cs.onSurface.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outline.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
      ),

      // ===== Botões =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          side: BorderSide(color: cs.primary.withValues(alpha: 0.6), width: 1.4),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ===== FAB =====
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ===== Bottom Navigation =====
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: isDark ? cardDark : cardLight,
        indicatorColor: cs.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? cs.primary
                : cs.onSurface.withValues(alpha: 0.65),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? cs.primary
                : cs.onSurface.withValues(alpha: 0.7),
          );
        }),
      ),

      // ===== Chips =====
      chipTheme: ChipThemeData(
        backgroundColor: cs.primary.withValues(alpha: 0.08),
        selectedColor: cs.primary,
        secondarySelectedColor: cs.primary,
        labelStyle: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: TextStyle(
          color: cs.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),

      // ===== Dividers =====
      dividerTheme: DividerThemeData(
        color: cs.outline.withValues(alpha: 0.15),
        thickness: 1,
        space: 1,
      ),

      // ===== Dialogs =====
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? cardDark : cardLight,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),

      // ===== SnackBar =====
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF2A2F3A) : const Color(0xFF1F2937),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),

      // ===== Bottom Sheet =====
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? cardDark : cardLight,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ===== List Tile =====
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurface.withValues(alpha: 0.75),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ===== Switch / Checkbox =====
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? cs.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? cs.primary.withValues(alpha: 0.5)
              : null,
        ),
      ),
    );
  }
}
