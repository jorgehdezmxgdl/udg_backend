import 'package:flutter/material.dart';

import '../models/curso_inscrito.dart';
import '../theme/app_colors.dart';
import 'etiqueta.dart';
import 'icono_curso.dart';

class CursoInscritoCard extends StatelessWidget {
  const CursoInscritoCard({super.key, required this.inscrito});

  final CursoInscrito inscrito;

  String _fecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final curso = inscrito.curso;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconoCurso(nombre: curso.icono, tamano: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      curso.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      curso.instructor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tema.bodySmall?.copyWith(color: AppColors.textoSuave),
                    ),
                  ],
                ),
              ),
              if (inscrito.completado)
                const Etiqueta(
                  icono: Icons.verified_rounded,
                  texto: 'Completado',
                  fondo: AppColors.exitoPastel,
                  color: AppColors.exito,
                )
              else
                const Etiqueta(icono: Icons.timelapse_rounded, texto: 'En curso'),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: inscrito.progreso / 100,
                    minHeight: 8,
                    color: inscrito.completado ? AppColors.exito : AppColors.primario,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${inscrito.progreso}%',
                style: tema.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.event_rounded, size: 16, color: AppColors.textoSuave),
              const SizedBox(width: 4),
              Text(
                'Inscrito el ${_fecha(inscrito.fechaInscripcion)}',
                style: tema.bodySmall?.copyWith(color: AppColors.textoSuave),
              ),
              const Spacer(),
              if (inscrito.calificacion != null) ...[
                const Icon(Icons.star_rounded, size: 18, color: AppColors.arenaOscuro),
                const SizedBox(width: 2),
                Text(
                  inscrito.calificacion!.toStringAsFixed(
                    inscrito.calificacion! % 1 == 0 ? 0 : 1,
                  ),
                  style: tema.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
