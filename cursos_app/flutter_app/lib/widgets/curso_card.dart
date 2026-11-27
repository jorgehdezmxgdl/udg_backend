import 'package:flutter/material.dart';

import '../models/curso.dart';
import '../theme/app_colors.dart';
import '../utils/formateadores.dart';
import 'etiqueta.dart';
import 'icono_curso.dart';

class CursoCard extends StatelessWidget {
  const CursoCard({super.key, required this.curso, this.onTap, this.inscrito = false});

  final Curso curso;
  final VoidCallback? onTap;

  final bool inscrito;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borde),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconoCurso(nombre: curso.icono),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      curso.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.textoSuave),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            curso.instructor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tema.bodySmall?.copyWith(color: AppColors.textoSuave),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      curso.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tema.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Etiqueta(icono: Icons.signal_cellular_alt_rounded, texto: curso.nivel),
                        Etiqueta(
                          icono: Icons.schedule_rounded,
                          texto: '${curso.duracionHoras} h',
                          fondo: AppColors.arenaClaro,
                          color: AppColors.arenaOscuro,
                        ),
                        Etiqueta(icono: Icons.label_outline_rounded, texto: curso.categoria),
                        if (inscrito)
                          const Etiqueta(
                            icono: Icons.verified_rounded,
                            texto: 'Inscrito',
                            fondo: AppColors.exitoPastel,
                            color: AppColors.exito,
                          )
                        else
                          Etiqueta(
                            icono: Icons.sell_rounded,
                            texto: formatoDinero(curso.precio, corto: true),
                            fondo: AppColors.arenaPastel,
                            color: AppColors.texto,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
