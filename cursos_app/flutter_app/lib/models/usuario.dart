class Usuario {
  final int id;
  final String clave;
  final String nombre;
  final String correo;

  const Usuario({
    required this.id,
    required this.clave,
    required this.nombre,
    required this.correo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as int,
        clave: json['clave'] as String,
        nombre: json['nombre'] as String,
        correo: json['correo'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clave': clave,
        'nombre': nombre,
        'correo': correo,
      };

  String get iniciales {
    final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }

  String get primerNombre => nombre.trim().split(' ').first;
}
