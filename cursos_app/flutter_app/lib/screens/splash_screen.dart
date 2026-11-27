import 'package:flutter/material.dart';

import '../config/empresa.dart';
import '../services/services.dart';
import '../theme/app_colors.dart';
import 'cursos_disponibles_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decidirRuta();
  }

  Future<void> _decidirRuta() async {
    final usuario = await authService.restaurarSesion();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => usuario == null
            ? const CursosDisponiblesScreen()
            : DashboardScreen(usuario: usuario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.degradado),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, size: 72, color: AppColors.primario),
              const SizedBox(height: 12),
              Text(
                Empresa.nombre,
                style: tema.displaySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(Empresa.slogan, style: tema.titleMedium),
              const SizedBox(height: 28),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
