import 'curso.dart';

class CursoInscrito {
  final Curso curso;
  final int progreso;
  final double? calificacion;
  final DateTime fechaInscripcion;
  final bool completado;

  const CursoInscrito({
    required this.curso,
    required this.progreso,
    required this.calificacion,
    required this.fechaInscripcion,
    required this.completado,
  });

  factory CursoInscrito.fromJson(Map<String, dynamic> json) => CursoInscrito(

        curso: Curso.fromJson(json),
        progreso: (json['progreso'] as num?)?.toInt() ?? 0,
        calificacion: (json['calificacion'] as num?)?.toDouble(),
        fechaInscripcion: DateTime.parse(json['fechaInscripcion'] as String),
        completado: json['completado'] as bool? ?? false,
      );
}

class ResumenCursos {
  final int total;
  final int completados;
  final int enCurso;
  final int horasCompletadas;
  final double? promedio;

  const ResumenCursos({
    required this.total,
    required this.completados,
    required this.enCurso,
    required this.horasCompletadas,
    required this.promedio,
  });

  factory ResumenCursos.fromJson(Map<String, dynamic> json) => ResumenCursos(
        total: (json['total'] as num).toInt(),
        completados: (json['completados'] as num).toInt(),
        enCurso: (json['enCurso'] as num).toInt(),
        horasCompletadas: (json['horasCompletadas'] as num).toInt(),
        promedio: (json['promedio'] as num?)?.toDouble(),
      );
}

class MisCursos {
  final ResumenCursos resumen;
  final List<CursoInscrito> cursos;

  const MisCursos({required this.resumen, required this.cursos});

  factory MisCursos.fromJson(Map<String, dynamic> json) => MisCursos(
        resumen: ResumenCursos.fromJson(json['resumen'] as Map<String, dynamic>),
        cursos: (json['cursos'] as List)
            .map((e) => CursoInscrito.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
