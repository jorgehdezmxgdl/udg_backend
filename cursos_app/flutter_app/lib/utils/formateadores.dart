import 'package:flutter/services.dart';

String formatoDinero(double monto, {String moneda = 'MXN', bool corto = false}) {
  final partes = monto.toStringAsFixed(2).split('.');
  final entero = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return corto ? '\$$entero' : '\$$entero.${partes[1]} $moneda';
}

String formatoFecha(DateTime f) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(f.day)}/${dos(f.month)}/${f.year} ${dos(f.hour)}:${dos(f.minute)}';
}

class AgruparDigitosFormatter extends TextInputFormatter {
  AgruparDigitosFormatter({this.bloque = 4, required this.maxDigitos});

  final int bloque;
  final int maxDigitos;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > maxDigitos) digitos = digitos.substring(0, maxDigitos);

    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i > 0 && i % bloque == 0) buffer.write(' ');
      buffer.write(digitos[i]);
    }
    final texto = buffer.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class VencimientoFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > 4) digitos = digitos.substring(0, 4);

    final borrando = newValue.text.length < oldValue.text.length;
    String texto;
    if (digitos.length > 2) {
      texto = '${digitos.substring(0, 2)}/${digitos.substring(2)}';
    } else if (digitos.length == 2 && !borrando) {
      texto = '$digitos/';
    } else {
      texto = digitos;
    }
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
