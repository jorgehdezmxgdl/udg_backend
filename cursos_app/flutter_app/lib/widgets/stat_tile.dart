import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icono,
    required this.valor,
    required this.etiqueta,
    this.fondoIcono = AppColors.primarioPastel,
    this.colorIcono = AppColors.primario,
  });

  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color fondoIcono;
  final Color colorIcono;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borde),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: fondoIcono, borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: colorIcono, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(valor, style: tema.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.bodySmall?.copyWith(color: AppColors.textoSuave),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
