import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const oceano = Color(0xFF2589BD);
  static const ceruleo = Color(0xFF187795);
  static const tormenta = Color(0xFF38686A);
  static const ceniza = Color(0xFFA3B4A2);
  static const roble = Color(0xFFCDC6AE);

  static const primario = ceruleo;
  static const primarioPastel = Color(0xFFC4E0EE);
  static const primarioClaro = Color(0xFFE7F2F7);

  static const arena = roble;
  static const arenaPastel = Color(0xFFE8E4D6);
  static const arenaClaro = Color(0xFFF4F2EB);
  static const arenaOscuro = Color(0xFF6E6648);

  static const salvia = ceniza;
  static const salviaPastel = Color(0xFFDDE6DC);

  static const crema = Color(0xFFF8F7F2);
  static const texto = Color(0xFF1F3F41);
  static const textoSuave = Color(0xFF5B7270);
  static const borde = Color(0xFFDCE3DE);

  static const exito = tormenta;
  static const exitoPastel = salviaPastel;
  static const error = Color(0xFFC0504D);
  static const errorPastel = Color(0xFFF9E3E2);

  static const degradado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarioPastel, arenaPastel],
  );
}
