enum MetodoPago { transferencia, tarjeta, bitcoin }

class SolicitudInscripcion {
  final int cursoId;
  final String nombre;
  final String correo;
  final String pais;
  final MetodoPago metodo;
  final Map<String, String> datosPago;
  final bool aceptaTerminos;

  const SolicitudInscripcion({
    required this.cursoId,
    required this.nombre,
    required this.correo,
    required this.pais,
    required this.metodo,
    required this.datosPago,
    required this.aceptaTerminos,
  });

  Map<String, dynamic> toJson() => {
        'cursoId': cursoId,
        'nombre': nombre.trim(),
        'correo': correo.trim(),
        'pais': pais,
        'aceptaTerminos': aceptaTerminos,
        'pago': {'metodo': metodo.name, ...datosPago},
      };
}

class EstadoCorreo {
  final bool enviado;
  final String modo;
  final String destinatario;
  final String mensaje;

  const EstadoCorreo({
    required this.enviado,
    required this.modo,
    required this.destinatario,
    required this.mensaje,
  });

  factory EstadoCorreo.fromJson(Map<String, dynamic> j) => EstadoCorreo(
        enviado: j['enviado'] as bool? ?? false,
        modo: j['modo'] as String? ?? '',
        destinatario: j['destinatario'] as String? ?? '',
        mensaje: j['mensaje'] as String? ?? '',
      );
}

class ResultadoInscripcion {
  final String mensaje;
  final String cursoTitulo;
  final String cursoIcono;
  final String folio;
  final String autorizacion;
  final MetodoPago metodo;
  final double monto;
  final String moneda;
  final double? montoBtc;
  final String referencia;
  final String nombre;
  final String pais;
  final DateTime fecha;
  final EstadoCorreo correo;

  const ResultadoInscripcion({
    required this.mensaje,
    required this.cursoTitulo,
    required this.cursoIcono,
    required this.folio,
    required this.autorizacion,
    required this.metodo,
    required this.monto,
    required this.moneda,
    required this.montoBtc,
    required this.referencia,
    required this.nombre,
    required this.pais,
    required this.fecha,
    required this.correo,
  });

  factory ResultadoInscripcion.fromJson(Map<String, dynamic> j) {
    final pago = j['pago'] as Map<String, dynamic>;
    final curso = (j['inscripcion'] as Map<String, dynamic>)['curso'] as Map<String, dynamic>;

    return ResultadoInscripcion(
      mensaje: j['mensaje'] as String? ?? '',
      cursoTitulo: curso['titulo'] as String,
      cursoIcono: curso['icono'] as String? ?? 'school',
      folio: pago['folio'] as String,
      autorizacion: pago['autorizacion'] as String,
      metodo: MetodoPago.values.byName(pago['metodo'] as String),
      monto: (pago['monto'] as num).toDouble(),
      moneda: pago['moneda'] as String? ?? 'MXN',
      montoBtc: (pago['montoBtc'] as num?)?.toDouble(),
      referencia: pago['referencia'] as String,
      nombre: pago['nombre'] as String,
      pais: pago['pais'] as String,
      fecha: DateTime.parse(pago['fecha'] as String).toLocal(),
      correo: EstadoCorreo.fromJson(j['correo'] as Map<String, dynamic>),
    );
  }
}
