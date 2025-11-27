import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/config/theme/app_theme.dart';
import 'package:prototipo1_app/config/theme/dark_mode_notifier.dart';
import 'package:prototipo1_app/config/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await SessionApp.init();

  runApp(
    const ProviderScope(child: MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme(isDarkMode, selectedColor: 1).getTheme(),

          routerConfig: appRouter,
        );
      },
    );
  }
}
