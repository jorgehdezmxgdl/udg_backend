import 'package:flutter/material.dart';

class Centrado extends StatelessWidget {
  const Centrado({
    super.key,
    required this.child,
    this.ancho = 760,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final double ancho;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ancho),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
