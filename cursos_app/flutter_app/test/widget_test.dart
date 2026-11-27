import 'package:cursos_app/models/curso_inscrito.dart';
import 'package:cursos_app/models/usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Usuario.fromJson e iniciales', () {
    final u = Usuario.fromJson({
      'id': 2,
      'clave': 'jorge',
      'nombre': 'Jorge Hernández',
      'correo': 'jorge@demo.mx',
    });
    expect(u.iniciales, 'JH');
    expect(u.primerNombre, 'Jorge');
  });

  test('MisCursos.fromJson con respuesta de /api/mis-cursos', () {
    final datos = MisCursos.fromJson({
      'ok': true,
      'resumen': {
        'total': 1,
        'completados': 1,
        'enCurso': 0,
        'horasCompletadas': 20,
        'promedio': 95,
      },
      'cursos': [
        {
          'id': 1,
          'titulo': 'Fundamentos de Dart',
          'descripcion': 'Variables, tipos...',
          'instructor': 'Mtra. Ana López',
          'duracionHoras': 20,
          'nivel': 'Básico',
          'categoria': 'Programación',
          'icono': 'code',
          'cupo': 30,
          'inscripcionId': 1,
          'progreso': 100,
          'calificacion': 95,
          'fechaInscripcion': '2026-08-10',
          'completado': true,
        },
      ],
    });

    expect(datos.resumen.promedio, 95.0);
    expect(datos.cursos.single.curso.titulo, 'Fundamentos de Dart');
    expect(datos.cursos.single.calificacion, 95.0);
    expect(datos.cursos.single.fechaInscripcion.month, 8);
  });
}
