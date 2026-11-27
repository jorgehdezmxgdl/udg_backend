import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Etiqueta extends StatelessWidget {
  const Etiqueta({
    super.key,
    required this.icono,
    required this.texto,
    this.fondo = AppColors.primarioClaro,
    this.color = AppColors.primario,
  });

  final IconData icono;
  final String texto;
  final Color fondo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
