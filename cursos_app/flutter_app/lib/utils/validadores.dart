class Validadores {
  Validadores._();

  static final _regexNombre = RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]+$");
  static final _regexCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _regexWallet =
      RegExp(r'^(bc1[a-z0-9]{25,59}|[13][a-km-zA-HJ-NP-Z1-9]{25,34})$');
  static final _regexVencimiento = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$');
  static final _soloDigitos = RegExp(r'^\d+$');

  static String limpiar(String? v) => (v ?? '').replaceAll(RegExp(r'[\s-]'), '');

  static String? nombre(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'El nombre es obligatorio';
    if (t.length < 5) return 'El nombre es demasiado corto';
    if (t.length > 100) return 'El nombre no puede exceder 100 caracteres';
    if (!_regexNombre.hasMatch(t)) return 'El nombre solo puede contener letras y espacios';
    if (t.split(RegExp(r'\s+')).length < 2) return 'Escribe tu nombre y al menos un apellido';
    return null;
  }

  static String? correo(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'El correo es obligatorio';
    if (t.length > 150) return 'El correo no puede exceder 150 caracteres';
    if (!_regexCorreo.hasMatch(t)) return 'Correo electrónico inválido (ej. nombre@dominio.com)';
    return null;
  }

  static String? requerido(String? v, String mensaje) =>
      (v == null || v.isEmpty) ? mensaje : null;

  static bool luhn(String numero) {
    if (!RegExp(r'^\d{13,19}$').hasMatch(numero)) return false;
    var suma = 0;
    var doble = false;
    for (var i = numero.length - 1; i >= 0; i--) {
      var d = int.parse(numero[i]);
      if (doble) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      suma += d;
      doble = !doble;
    }
    return suma % 10 == 0;
  }

  static bool esAmex(String numero) => RegExp(r'^3[47]').hasMatch(numero);

  static String marcaTarjeta(String numero) {
    if (numero.startsWith('4')) return 'Visa';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(numero)) return 'Mastercard';
    if (esAmex(numero)) return 'American Express';
    return '';
  }

  static String? titular(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'El titular es obligatorio';
    if (t.length < 3) return 'Escribe el nombre como aparece en la tarjeta';
    if (t.length > 60) return 'El titular no puede exceder 60 caracteres';
    if (!_regexNombre.hasMatch(t)) return 'El titular solo puede contener letras y espacios';
    return null;
  }

  static String? numeroTarjeta(String? v) {
    final n = limpiar(v);
    if (n.isEmpty) return 'El número de tarjeta es obligatorio';
    if (!_soloDigitos.hasMatch(n)) return 'El número de tarjeta solo admite dígitos';
    if (n.length < 13) return 'El número de tarjeta está incompleto';
    if (n.length > 19) return 'El número de tarjeta tiene demasiados dígitos';
    if (!luhn(n)) return 'Número de tarjeta inválido, revisa los dígitos';
    return null;
  }

  static String? vencimiento(String? v, {DateTime? hoy}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'El vencimiento es obligatorio';
    final m = _regexVencimiento.firstMatch(t);
    if (m == null) return 'Usa el formato MM/AA';
    final mes = int.parse(m.group(1)!);
    final anio = 2000 + int.parse(m.group(2)!);
    final finDeMes = DateTime(anio, mes + 1, 0, 23, 59, 59);
    if (finDeMes.isBefore(hoy ?? DateTime.now())) return 'La tarjeta está vencida';
    return null;
  }

  static String? cvv(String? v, String numeroTarjeta) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'El CVV es obligatorio';
    if (!RegExp(r'^\d{3,4}$').hasMatch(t)) return 'El CVV debe tener 3 o 4 dígitos';
    final largo = esAmex(limpiar(numeroTarjeta)) ? 4 : 3;
    if (t.length != largo) return 'El CVV de esta tarjeta debe tener $largo dígitos';
    return null;
  }

  static bool clabeValida(String clabe) {
    if (!RegExp(r'^\d{18}$').hasMatch(clabe)) return false;
    const pesos = [3, 7, 1];
    var suma = 0;
    for (var i = 0; i < 17; i++) {
      suma += (int.parse(clabe[i]) * pesos[i % 3]) % 10;
    }
    return (10 - (suma % 10)) % 10 == int.parse(clabe[17]);
  }

  static String? clabe(String? v) {
    final c = limpiar(v);
    if (c.isEmpty) return 'La CLABE es obligatoria';
    if (!_soloDigitos.hasMatch(c)) return 'La CLABE solo admite dígitos';
    if (c.length != 18) return 'La CLABE debe tener exactamente 18 dígitos (tienes ${c.length})';
    if (!clabeValida(c)) return 'CLABE inválida: el dígito verificador no coincide';
    return null;
  }

  static String? wallet(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'La dirección de tu wallet es obligatoria';
    if (t.length > 90) return 'La dirección es demasiado larga';
    if (!_regexWallet.hasMatch(t)) {
      return 'Dirección Bitcoin inválida (debe iniciar con bc1, 1 o 3)';
    }
    return null;
  }
}
