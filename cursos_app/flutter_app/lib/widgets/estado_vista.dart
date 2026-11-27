import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CargandoVista extends StatelessWidget {
  const CargandoVista({super.key, this.mensaje = 'Cargando...'});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(mensaje, style: const TextStyle(color: AppColors.textoSuave)),
        ],
      ),
    );
  }
}

class MensajeVista extends StatelessWidget {
  const MensajeVista({
    super.key,
    required this.icono,
    required this.titulo,
    this.mensaje,
    this.textoBoton,
    this.onPressed,
    this.esError = false,
  });

  const MensajeVista.error({super.key, required String mensaje, VoidCallback? onReintentar})
      : icono = Icons.cloud_off_rounded,
        titulo = 'Algo salió mal',
        mensaje = mensaje,
        textoBoton = 'Reintentar',
        onPressed = onReintentar,
        esError = true;

  final IconData icono;
  final String titulo;
  final String? mensaje;
  final String? textoBoton;
  final VoidCallback? onPressed;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: esError ? AppColors.errorPastel : AppColors.arenaClaro,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 40, color: esError ? AppColors.error : AppColors.arenaOscuro),
          ),
          const SizedBox(height: 16),
          Text(titulo, style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (mensaje != null) ...[
            const SizedBox(height: 6),
            Text(
              mensaje!,
              textAlign: TextAlign.center,
              style: tema.bodyMedium?.copyWith(color: AppColors.textoSuave),
            ),
          ],
          if (textoBoton != null && onPressed != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(textoBoton!),
            ),
          ],
        ],
      ),
    );
  }
}
