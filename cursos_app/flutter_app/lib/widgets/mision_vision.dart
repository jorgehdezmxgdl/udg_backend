import 'package:flutter/material.dart';

import '../config/empresa.dart';
import '../theme/app_colors.dart';

class MisionVision extends StatelessWidget {
  const MisionVision({super.key});

  static const _mision = _Tarjeta(
    imagen: 'assets/images/mision.png',
    icono: Icons.flag_rounded,
    titulo: 'Nuestra misión',
    texto: Empresa.mision,
    color: AppColors.primario,
    fondo: AppColors.primarioPastel,
  );

  static const _vision = _Tarjeta(
    imagen: 'assets/images/vision.png',
    icono: Icons.visibility_rounded,
    titulo: 'Nuestra visión',
    texto: Empresa.vision,
    color: AppColors.arenaOscuro,
    fondo: AppColors.arenaPastel,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 700) {
          return const Column(children: [_mision, SizedBox(height: 20), _vision]);
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _mision),
            SizedBox(width: 20),
            Expanded(child: _vision),
          ],
        );
      },
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.imagen,
    required this.icono,
    required this.titulo,
    required this.texto,
    required this.color,
    required this.fondo,
  });

  final String imagen;
  final IconData icono;
  final String titulo;
  final String texto;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 12 / 7,
            child: Image.asset(imagen, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(14)),
                      child: Icon(icono, color: color, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        titulo,
                        style: tema.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(texto, style: tema.bodyLarge?.copyWith(fontSize: 17, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
