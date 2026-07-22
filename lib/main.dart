import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

// Ubah ConsumerWidget agar MyApp bisa membaca goRouterProvider
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tarik konfigurasi GoRouter dari Riverpod
    final router = ref.watch(goRouterProvider);

    // Ganti MaterialApp menjadi MaterialApp.router
    return MaterialApp.router(
      title: 'Perpustakaan Digital',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Suntikkan konfigurasi router
      routerConfig: router,
    );
  }
}
