import 'package:flutter/material.dart';

import 'config/empresa.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CursosApp());
}

class CursosApp extends StatelessWidget {
  const CursosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${Empresa.nombre} · ${Empresa.slogan}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      home: const SplashScreen(),
    );
  }
}
