import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/hive_service.dart';
import 'state/auth/auth_provider.dart';
import 'theme/app_theme.dart';
import 'ui/auth/login_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';

// Legacy color constants — kept for screens not yet migrated
const Color kPrimaryColor = AppColors.primaryContainer;
const Color kSecondaryColor = AppColors.outlineVariant;
const Color kTextColor = AppColors.onSurface;
const Color kErrorColor = AppColors.error;
const Color kSuccessColor = AppColors.primaryContainer;

class VViewApp extends ConsumerWidget {
  const VViewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'v-view',
      theme: AppTheme.light,
      home: authState.when(
        data: (user) {
          if (user != null) return const HomeScreen();
          final seen = HiveService.settingsBox
                  .get('onboarding_seen', defaultValue: false) as bool;
          return seen ? const LoginScreen() : const OnboardingScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => const LoginScreen(),
      ),
    );
  }
}
