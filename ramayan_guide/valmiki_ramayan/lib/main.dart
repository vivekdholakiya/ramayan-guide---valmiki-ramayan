import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  final localStorageService = await LocalStorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: const ValmikiRamayanApp(),
    ),
  );
}

class ValmikiRamayanApp extends ConsumerWidget {
  const ValmikiRamayanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Valmiki Ramayan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(language.code),
      darkTheme: AppTheme.darkTheme(language.code),
      themeMode: themeMode.mode,
      home: const SplashScreen(),
    );
  }
}
