import 'package:flutter/material.dart';

class AppTheme {
  // ========== Premium Color Palette ==========
  // Soft, muted, health-focused colors

  // Primary Green - soft natural green (muted, not saturated)
  static const Color primaryColor = Color(0xFF6BA368);
  static const Color primaryColorDark = Color(
    0xFF5A9157,
  ); // For hover/pressed states
  static const Color primaryColorLight = Color(
    0xFFE8F5E6,
  ); // Very light green tint

  // Secondary/Accent
  static const Color accentColor = Color(0xFFA8D5A3); // Lighter green accent

  // Backgrounds
  static const Color backgroundColor = Color(
    0xFFF8FAF7,
  ); // Warm off-white (NOT pure white)
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white for cards

  // Text Colors - soft and professional
  static const Color textPrimary = Color(
    0xFF2F3E46,
  ); // Soft dark gray (not harsh black)
  static const Color textSecondary = Color(0xFF84A59D); // Muted green-gray
  static const Color textTertiary = Color(0xFFB8C5C2); // Very light gray-green

  // Macro / nutrient colors — used in all nutrition widgets
  static const Color calColor  = Color(0xFFFF8A65); // warm coral-orange (calories)
  static const Color protColor = Color(0xFF66BB6A); // soft green (protein)
  static const Color fatColor  = Color(0xFFFFB74D); // warm amber (fats)
  static const Color carbColor = Color(0xFF42A5F5); // soft blue (carbs)

  // Unified card corner radius
  static const double cardRadius = 16.0;

  // Status Colors - soft and calm
  static const Color errorColor = Color(
    0xFFE8A598,
  ); // Soft peachy-red (not aggressive)
  static const Color successColor = Color(0xFF9BC4B5); // Soft teal-green

  // Dividers and borders
  static const Color dividerColor = Color(0xFFEEF2F0); // Barely visible

  // Legacy dark theme colors (keeping for dark mode)
  static const Color darkBackgroundColor = Color(0xFF1E1B18);
  static const Color darkSurfaceColor = Color(0xFF2C2825);
  static const Color darkOnBackground = Color(0xFFEAEAEA);
  static const Color darkOnSurface = Color(0xFFD7D7D7);

  // ========== Light Theme (Premium Design) ==========
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor, // Warm off-white

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryColorLight,
        secondary: accentColor,
        surface: surfaceColor, // White for cards
        background: backgroundColor, // Warm off-white
        onPrimary: Colors.white,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        error: errorColor,
      ),

      // AppBar - clean and minimal
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600, // Semibold, not bold
          height: 1.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Cards - white with soft green-tinted shadow
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0, // No Material elevation, use shadow
        shadowColor: primaryColor.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Consistent soft corners
        ),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),

      // Primary Buttons - smooth and modern
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0, // Flat, no elevation
          shadowColor: primaryColor.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Smooth, not sharp
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 32,
          ), // Premium spacing
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500, // Medium, not bold
            height: 1.5,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),

      // Input Fields - clean and minimal
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor, // White background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border by default
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor,
            width: 1,
          ), // Subtle green border on focus
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        labelStyle: TextStyle(color: textSecondary), // Muted label
        hintStyle: TextStyle(color: textTertiary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // Bottom Navigation - clean with soft colors
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary, // Light gray-green
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Typography - light and clean
      textTheme: TextTheme(
        // Large headings
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600, // Semibold
          fontSize: 32,
          height: 1.3,
        ),

        // Medium headings
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600, // Semibold
          fontSize: 24,
          height: 1.4,
        ),

        // Small headings
        headlineSmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500, // Medium
          fontSize: 20,
          height: 1.4,
        ),

        // Title large
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600, // Semibold
          fontSize: 18,
          height: 1.5,
        ),

        // Title medium
        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500, // Medium
          fontSize: 16,
          height: 1.5,
        ),

        // Body large
        bodyLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w400, // Regular
          fontSize: 16,
          height: 1.5,
        ),

        // Body medium
        bodyMedium: TextStyle(
          color: textSecondary, // Muted for descriptions
          fontWeight: FontWeight.w400, // Regular
          fontSize: 14,
          height: 1.5,
        ),

        // Body small
        bodySmall: TextStyle(
          color: textTertiary, // Very light for captions
          fontWeight: FontWeight.w400, // Regular
          fontSize: 12,
          height: 1.5,
        ),

        // Labels
        labelLarge: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w500, // Medium
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        deleteIconColor: errorColor,
        labelStyle: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: dividerColor),
        ),
      ),
    );
  }

  // ========== Dark Theme (Preserved for users who prefer it) ==========
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackgroundColor,
      primaryColor: primaryColor,

      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: darkOnSurface,
        onBackground: darkOnBackground,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: darkOnBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkOnBackground),
      ),

      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIconColor: primaryColor,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkOnBackground,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: darkOnBackground,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkOnBackground,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: darkOnSurface, fontSize: 16),
        bodyMedium: TextStyle(color: darkOnSurface, fontSize: 14),
      ),
    );
  }
}
