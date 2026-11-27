import 'package:flutter/material.dart';

import '../models/inscripcion.dart';
import '../theme/app_colors.dart';

class SelectorMetodoPago extends FormField<MetodoPago> {
  SelectorMetodoPago({
    super.key,
    required ValueChanged<MetodoPago> onChanged,
    super.validator,
    super.initialValue,
    bool habilitado = true,
  }) : super(
          enabled: habilitado,
          builder: (state) {
            final tema = Theme.of(state.context).textTheme;

            Widget opcion(MetodoPago m, IconData icono, String texto) {
              final activo = state.value == m;
              return Expanded(
                child: Material(
                  color: activo ? AppColors.arenaPastel : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: habilitado
                        ? () {
                            state.didChange(m);
                            onChanged(m);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: state.hasError
                              ? AppColors.error
                              : (activo ? AppColors.oceano : AppColors.borde),
                          width: activo ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(icono, size: 28, color: activo ? AppColors.texto : AppColors.primario),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              texto,
                              style: tema.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    opcion(MetodoPago.transferencia, Icons.account_balance_rounded, 'Transferencia'),
                    const SizedBox(width: 8),
                    opcion(MetodoPago.tarjeta, Icons.credit_card_rounded, 'Tarjeta'),
                    const SizedBox(width: 8),
                    opcion(MetodoPago.bitcoin, Icons.currency_bitcoin_rounded, 'Bitcoin'),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 6),
                    child: Text(
                      state.errorText!,
                      style: tema.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
              ],
            );
          },
        );
}
