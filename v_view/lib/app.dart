import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/auth/auth_provider.dart';
import 'ui/auth/login_screen.dart';
import 'ui/history/history_list_screen.dart';

class VViewApp extends ConsumerWidget {
  const VViewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'v-view',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (user) => user != null
            ? const HistoryListScreen()
            : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => const LoginScreen(),
      ),
    );
  }
}
