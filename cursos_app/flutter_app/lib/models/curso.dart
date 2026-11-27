class Curso {
  final int id;
  final String titulo;
  final String descripcion;
  final String instructor;
  final int duracionHoras;
  final String nivel;
  final String categoria;
  final String icono;
  final int cupo;
  final double precio;

  const Curso({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.instructor,
    required this.duracionHoras,
    required this.nivel,
    required this.categoria,
    required this.icono,
    required this.cupo,
    required this.precio,
  });

  factory Curso.fromJson(Map<String, dynamic> json) => Curso(
        id: json['id'] as int,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String? ?? '',
        instructor: json['instructor'] as String? ?? '',
        duracionHoras: (json['duracionHoras'] as num?)?.toInt() ?? 0,
        nivel: json['nivel'] as String? ?? 'Básico',
        categoria: json['categoria'] as String? ?? 'General',
        icono: json['icono'] as String? ?? 'school',
        cupo: (json['cupo'] as num?)?.toInt() ?? 0,
        precio: (json['precio'] as num?)?.toDouble() ?? 0,
      );
}
