import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── 색상 팔레트 ────────────────────────────────────────────────────────────
// designex/code.html Tailwind config → Material 3 역할로 매핑
// primary-container: #00C9A7 (민트-틸 메인)
// secondary-container: #FF6B6B (코랄 보조)
// on-background: #131B30 (다크 네이비 텍스트)
// background: #FAF8FF

abstract final class AppColors {
  // Primary — 민트-틸
  static const primary            = Color(0xFF006B58);
  static const onPrimary          = Color(0xFFFFFFFF);
  static const primaryContainer   = Color(0xFF00C9A7);
  static const onPrimaryContainer = Color(0xFF004E40);
  static const inversePrimary     = Color(0xFF38DEBB);
  static const primaryFixed       = Color(0xFF5FFBD6);
  static const primaryFixedDim    = Color(0xFF38DEBB);
  static const onPrimaryFixed         = Color(0xFF002019);
  static const onPrimaryFixedVariant  = Color(0xFF005142);

  // Secondary — 코랄
  static const secondary            = Color(0xFFAE2F34);
  static const onSecondary          = Color(0xFFFFFFFF);
  static const secondaryContainer   = Color(0xFFFF6B6B);
  static const onSecondaryContainer = Color(0xFF6D0010);
  static const secondaryFixed           = Color(0xFFFFDAD8);
  static const secondaryFixedDim        = Color(0xFFFFB3B0);
  static const onSecondaryFixed         = Color(0xFF410006);
  static const onSecondaryFixedVariant  = Color(0xFF8C1520);

  // Tertiary — 블루 (강조)
  static const tertiary            = Color(0xFF005DB8);
  static const onTertiary          = Color(0xFFFFFFFF);
  static const tertiaryContainer   = Color(0xFF87B3FF);
  static const onTertiaryContainer = Color(0xFF004489);
  static const tertiaryFixed           = Color(0xFFD6E3FF);
  static const tertiaryFixedDim        = Color(0xFFA9C7FF);
  static const onTertiaryFixed         = Color(0xFF001B3E);
  static const onTertiaryFixedVariant  = Color(0xFF00468C);

  // Error
  static const error            = Color(0xFFBA1A1A);
  static const onError          = Color(0xFFFFFFFF);
  static const errorContainer   = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Surface / Background
  static const surface                 = Color(0xFFFAF8FF);
  static const surfaceDim              = Color(0xFFD2D9F7);
  static const surfaceBright           = Color(0xFFFAF8FF);
  static const surfaceContainerLowest  = Color(0xFFFFFFFF);
  static const surfaceContainerLow     = Color(0xFFF2F3FF);
  static const surfaceContainer        = Color(0xFFEAEDFF);
  static const surfaceContainerHigh    = Color(0xFFE2E7FF);
  static const surfaceContainerHighest = Color(0xFFDAE2FF);
  static const onSurface               = Color(0xFF131B30);
  static const onSurfaceVariant        = Color(0xFF3C4A45);

  // Outline
  static const outline        = Color(0xFF6B7A75);
  static const outlineVariant = Color(0xFFBACAC3);

  // Inverse
  static const inverseSurface   = Color(0xFF283046);
  static const onInverseSurface = Color(0xFFEEF0FF);
  static const surfaceTint      = Color(0xFF006B58);

  // 버튼 3D-그림자 (하단 4px press 효과에 사용)
  static const primaryShadow   = Color(0xFF00967C); // primaryContainer 보다 20% 어둡게
  static const secondaryShadow = Color(0xFFD44F54);

  // 카드 그림자 (Y:4, Blur:12, Opacity:5% — #1A2238 @ 0x0D)
  static const cardShadow = Color(0x0D1A2238);
}

// ── 타이포그래피 ───────────────────────────────────────────────────────────
// Heading : Plus Jakarta Sans (700/800)
// Body    : Be Vietnam Pro  (400/500)
// Source  : designex/code.html fontSize config

TextTheme buildAppTextTheme() {
  final j = GoogleFonts.plusJakartaSans;
  final v = GoogleFonts.beVietnamPro;
  const c = AppColors.onSurface;

  return TextTheme(
    // display — Plus Jakarta Sans 800, letterSpacing -2%
    displayLarge:  j(fontSize: 40, fontWeight: FontWeight.w800, height: 1.30, letterSpacing: -0.80, color: c),
    displayMedium: j(fontSize: 32, fontWeight: FontWeight.w800, height: 1.25, letterSpacing: -0.64, color: c),
    displaySmall:  j(fontSize: 28, fontWeight: FontWeight.w800, height: 1.28, letterSpacing: -0.28, color: c),

    // headline — Plus Jakarta Sans 700
    headlineLarge:  j(fontSize: 24, fontWeight: FontWeight.w700, height: 1.33, color: c),
    headlineMedium: j(fontSize: 20, fontWeight: FontWeight.w700, height: 1.40, color: c),
    headlineSmall:  j(fontSize: 18, fontWeight: FontWeight.w700, height: 1.44, color: c),

    // title — Plus Jakarta Sans 700 (label-bold 역할)
    titleLarge:  j(fontSize: 16, fontWeight: FontWeight.w700, height: 1.50, color: c),
    titleMedium: j(fontSize: 14, fontWeight: FontWeight.w700, height: 1.43, color: c),
    titleSmall:  j(fontSize: 12, fontWeight: FontWeight.w700, height: 1.33, color: c),

    // body — Be Vietnam Pro
    bodyLarge:  v(fontSize: 18, fontWeight: FontWeight.w400, height: 1.56, color: c),
    bodyMedium: v(fontSize: 16, fontWeight: FontWeight.w400, height: 1.50, color: c),
    bodySmall:  v(fontSize: 14, fontWeight: FontWeight.w400, height: 1.57, color: c),

    // label
    labelLarge:  j(fontSize: 14, fontWeight: FontWeight.w700, height: 1.43, color: c),
    labelMedium: v(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, color: c),
    labelSmall:  v(fontSize: 10, fontWeight: FontWeight.w500, height: 1.60, color: c),
  );
}

// ── ColorScheme (Material 3 전체 역할 직접 지정) ───────────────────────────

const _colorScheme = ColorScheme(
  brightness: Brightness.light,

  primary:            AppColors.primary,
  onPrimary:          AppColors.onPrimary,
  primaryContainer:   AppColors.primaryContainer,
  onPrimaryContainer: AppColors.onPrimaryContainer,
  inversePrimary:     AppColors.inversePrimary,

  secondary:            AppColors.secondary,
  onSecondary:          AppColors.onSecondary,
  secondaryContainer:   AppColors.secondaryContainer,
  onSecondaryContainer: AppColors.onSecondaryContainer,

  tertiary:            AppColors.tertiary,
  onTertiary:          AppColors.onTertiary,
  tertiaryContainer:   AppColors.tertiaryContainer,
  onTertiaryContainer: AppColors.onTertiaryContainer,

  error:            AppColors.error,
  onError:          AppColors.onError,
  errorContainer:   AppColors.errorContainer,
  onErrorContainer: AppColors.onErrorContainer,

  surface:                 AppColors.surface,
  surfaceDim:              AppColors.surfaceDim,
  surfaceBright:           AppColors.surfaceBright,
  surfaceContainerLowest:  AppColors.surfaceContainerLowest,
  surfaceContainerLow:     AppColors.surfaceContainerLow,
  surfaceContainer:        AppColors.surfaceContainer,
  surfaceContainerHigh:    AppColors.surfaceContainerHigh,
  surfaceContainerHighest: AppColors.surfaceContainerHighest,
  onSurface:               AppColors.onSurface,
  onSurfaceVariant:        AppColors.onSurfaceVariant,

  outline:        AppColors.outline,
  outlineVariant: AppColors.outlineVariant,
  shadow:         Color(0xFF000000),
  scrim:          Color(0xFF000000),

  inverseSurface:   AppColors.inverseSurface,
  onInverseSurface: AppColors.onInverseSurface,
  surfaceTint:      AppColors.surfaceTint,
);

// ── AppTheme ───────────────────────────────────────────────────────────────

abstract final class AppTheme {
  static ThemeData get light {
    final textTheme = buildAppTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface, size: 24),
        actionsIconTheme: const IconThemeData(color: AppColors.onSurface, size: 24),
      ),

      // ElevatedButton — 민트-틸 배경, Bold 18sp, 높이 56px
      // 3D press 그림자(하단 4px border)는 VViewButton 커스텀 위젯에서 구현
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled)
              ? AppColors.surfaceContainerHigh
              : AppColors.primaryContainer),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled)
              ? AppColors.onSurfaceVariant
              : AppColors.onPrimaryContainer),
          overlayColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.10)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0),
          ),
        ),
      ),

      // OutlinedButton — 흰 배경 + 민트-틸 2px 테두리
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surfaceContainerLowest),
          foregroundColor: WidgetStateProperty.all(AppColors.primary),
          overlayColor: WidgetStateProperty.all(AppColors.primaryContainer.withValues(alpha: 0.10)),
          elevation: WidgetStateProperty.all(0),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          side: WidgetStateProperty.resolveWith((s) => BorderSide(
            color: s.contains(WidgetState.disabled)
                ? AppColors.outlineVariant
                : AppColors.primaryContainer,
            width: 2,
          )),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0),
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.primary),
          overlayColor: WidgetStateProperty.all(AppColors.primaryContainer.withValues(alpha: 0.10)),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0),
          ),
        ),
      ),

      // Card — 흰 배경, 16px 모서리, Y:4/Blur:12/Opacity:5% 그림자
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),

      // InputDecoration — 16px 패딩, 16px radius, focus 시 민트-틸 테두리
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.all(16),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
        ),
        floatingLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryContainer,
        ),
        hintStyle: GoogleFonts.beVietnamPro(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.outline,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      // Chip — pill 모양, 선택 시 민트-틸
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primaryContainer,
        disabledColor: AppColors.surfaceContainerHigh,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryContainer,
        ),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 0,
        pressElevation: 0,
      ),

      // ProgressIndicator — 민트-틸, 두께 12px, 둥근 캡
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryContainer,
        linearTrackColor: AppColors.surfaceContainerHigh,
        linearMinHeight: 12,
        circularTrackColor: AppColors.surfaceContainerHigh,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.beVietnamPro(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // NavigationBar (M3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryContainer.withValues(alpha: 0.20),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.onSurfaceVariant,
          size: 24,
        )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.onSurfaceVariant,
        )),
        elevation: 0,
        height: 64,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onInverseSurface,
        ),
        actionTextColor: AppColors.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        contentTextStyle: GoogleFonts.beVietnamPro(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        subtitleTextStyle: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        iconColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
