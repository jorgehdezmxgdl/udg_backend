import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class IconoCurso extends StatelessWidget {
  const IconoCurso({super.key, required this.nombre, this.tamano = 52});

  final String nombre;
  final double tamano;

  static const Map<String, IconData> _iconos = {
    'code': Icons.code_rounded,
    'phone': Icons.phone_iphone_rounded,
    'storage': Icons.storage_rounded,
    'api': Icons.api_rounded,
    'palette': Icons.palette_rounded,
    'chart': Icons.insert_chart_rounded,
    'security': Icons.shield_rounded,
    'git': Icons.account_tree_rounded,
    'cloud': Icons.cloud_rounded,
    'ai': Icons.psychology_rounded,
  };

  static IconData iconoDe(String nombre) => _iconos[nombre] ?? Icons.school_rounded;

  @override
  Widget build(BuildContext context) {
    final (fondo, color) = switch (nombre.codeUnits.fold<int>(0, (a, b) => a + b) % 3) {
      0 => (AppColors.primarioPastel, AppColors.oceano),
      1 => (AppColors.salviaPastel, AppColors.tormenta),
      _ => (AppColors.arenaPastel, AppColors.arenaOscuro),
    };

    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(tamano * 0.3),
      ),
      child: Icon(iconoDe(nombre), color: color, size: tamano * 0.52),
    );
  }
}
