import 'package:cursos_app/utils/formateadores.dart';
import 'package:cursos_app/utils/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Datos del alumno', () {
    test('nombre', () {
      expect(Validadores.nombre(''), 'El nombre es obligatorio');
      expect(Validadores.nombre('Ana'), 'El nombre es demasiado corto');
      expect(Validadores.nombre('Mariana'), 'Escribe tu nombre y al menos un apellido');
      expect(Validadores.nombre('Mariana R2D2'), 'El nombre solo puede contener letras y espacios');
      expect(Validadores.nombre('Mariana Ramírez Soto'), isNull);
      expect(Validadores.nombre('José Ñúñez'), isNull);
    });

    test('correo', () {
      expect(Validadores.correo(''), 'El correo es obligatorio');
      expect(Validadores.correo('x@'), isNotNull);
      expect(Validadores.correo('mariana.ramirez@example.com'), isNull);
    });
  });

  group('Tarjeta', () {
    test('Luhn', () {
      expect(Validadores.luhn('4242424242424242'), isTrue);
      expect(Validadores.luhn('4242424242424241'), isFalse);
      expect(Validadores.luhn('378282246310005'), isTrue);
    });

    test('número con espacios', () {
      expect(Validadores.numeroTarjeta('4242 4242 4242 4242'), isNull);
      expect(Validadores.numeroTarjeta('4242 4242'), 'El número de tarjeta está incompleto');
    });

    test('vencimiento', () {
      final hoy = DateTime(2026, 11, 25);
      expect(Validadores.vencimiento('13/28', hoy: hoy), 'Usa el formato MM/AA');
      expect(Validadores.vencimiento('01/24', hoy: hoy), 'La tarjeta está vencida');
      expect(Validadores.vencimiento('11/26', hoy: hoy), isNull);
      expect(Validadores.vencimiento('12/29', hoy: hoy), isNull);
    });

    test('CVV según la marca', () {
      expect(Validadores.cvv('123', '4242424242424242'), isNull);
      expect(Validadores.cvv('123', '378282246310005'),
          'El CVV de esta tarjeta debe tener 4 dígitos');
      expect(Validadores.cvv('1234', '378282246310005'), isNull);
    });
  });

  group('Transferencia y Bitcoin', () {
    test('CLABE con dígito verificador', () {
      expect(Validadores.clabe('012180001234567899'), isNull);
      expect(Validadores.clabe('012180001234567890'),
          'CLABE inválida: el dígito verificador no coincide');
      expect(Validadores.clabe('0121'), startsWith('La CLABE debe tener exactamente 18 dígitos'));
    });

    test('wallet', () {
      expect(Validadores.wallet('bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq'), isNull);
      expect(Validadores.wallet('0xABC'), isNotNull);
    });
  });

  test('formato de dinero', () {
    expect(formatoDinero(1499), r'$1,499.00 MXN');
    expect(formatoDinero(1850000, corto: true), r'$1,850,000');
  });
}
