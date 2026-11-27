class Opcion {
  final String codigo;
  final String nombre;

  const Opcion(this.codigo, this.nombre);

  factory Opcion.fromJson(Map<String, dynamic> json) =>
      Opcion(json['codigo'] as String, json['nombre'] as String);
}

class Catalogos {
  final List<Opcion> paises;
  final List<Opcion> metodosPago;
  final List<Opcion> bancos;
  final double tipoCambioBtcMxn;
  final String clabeDestino;
  final String walletDestino;

  const Catalogos({
    required this.paises,
    required this.metodosPago,
    required this.bancos,
    required this.tipoCambioBtcMxn,
    required this.clabeDestino,
    required this.walletDestino,
  });

  factory Catalogos.fromJson(Map<String, dynamic> json) {
    List<Opcion> lista(String k) =>
        (json[k] as List).map((e) => Opcion.fromJson(e as Map<String, dynamic>)).toList();
    final pago = json['pago'] as Map<String, dynamic>;

    return Catalogos(
      paises: lista('paises'),
      metodosPago: lista('metodosPago'),
      bancos: lista('bancos'),
      tipoCambioBtcMxn: (pago['tipoCambioBtcMxn'] as num).toDouble(),
      clabeDestino: pago['clabeDestino'] as String,
      walletDestino: pago['walletDestino'] as String,
    );
  }
}
