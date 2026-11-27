import 'package:flutter/material.dart';

import '../models/inscripcion.dart';
import '../models/usuario.dart';
import '../theme/app_colors.dart';
import '../utils/formateadores.dart';
import '../widgets/icono_curso.dart';
import 'cursos_disponibles_screen.dart';
import 'dashboard_screen.dart';

class ConfirmacionScreen extends StatelessWidget {
  const ConfirmacionScreen({super.key, required this.resultado, required this.usuario});

  final ResultadoInscripcion resultado;
  final Usuario usuario;

  static const _metodos = {
    MetodoPago.tarjeta: 'Tarjeta de crédito / débito',
    MetodoPago.transferencia: 'Transferencia SPEI',
    MetodoPago.bitcoin: 'Bitcoin',
  };

  void _irAMisCursos(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => DashboardScreen(usuario: usuario)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final r = resultado;

    final filas = <(IconData, String, String)>[
      (Icons.confirmation_number_rounded, 'Folio', r.folio),
      (Icons.verified_user_rounded, 'Autorización', r.autorizacion),
      (Icons.payments_rounded, 'Monto', formatoDinero(r.monto, moneda: r.moneda)),
      if (r.montoBtc != null) (Icons.currency_bitcoin_rounded, 'Equivalente', '${r.montoBtc} BTC'),
      (Icons.account_balance_wallet_rounded, 'Forma de pago', _metodos[r.metodo]!),
      (Icons.credit_score_rounded, 'Referencia', r.referencia),
      (Icons.person_rounded, 'Alumno', r.nombre),
      (Icons.public_rounded, 'País', r.pais),
      (Icons.schedule_rounded, 'Fecha', formatoFecha(r.fecha)),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _irAMisCursos(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: AppColors.exitoPastel,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, size: 56, color: AppColors.exito),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¡Pago aprobado!',
                        textAlign: TextAlign.center,
                        style: tema.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.mensaje,
                        textAlign: TextAlign.center,
                        style: tema.bodyMedium?.copyWith(color: AppColors.textoSuave),
                      ),
                      const SizedBox(height: 20),

                      _EstadoCorreo(correo: r.correo),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borde),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconoCurso(nombre: r.cursoIcono, tamano: 46),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    r.cursoTitulo,
                                    style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 28, color: AppColors.borde),
                            for (final (icono, etiqueta, valor) in filas)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(icono, size: 18, color: AppColors.primario),
                                    const SizedBox(width: 8),
                                    Text(etiqueta,
                                        style: tema.bodyMedium?.copyWith(color: AppColors.textoSuave)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SelectableText(
                                        valor,
                                        textAlign: TextAlign.right,
                                        style: tema.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      FilledButton.icon(
                        onPressed: () => _irAMisCursos(context),
                        icon: const Icon(Icons.dashboard_rounded),
                        label: const Text('Ir a mis cursos'),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => CursosDisponiblesScreen(usuario: usuario),
                          ),
                          (_) => false,
                        ),
                        icon: const Icon(Icons.explore_rounded),
                        label: const Text('Seguir explorando cursos'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoCorreo extends StatelessWidget {
  const _EstadoCorreo({required this.correo});
  final EstadoCorreo correo;

  @override
  Widget build(BuildContext context) {
    final ok = correo.enviado;
    final color = ok ? AppColors.exito : AppColors.arenaOscuro;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ok ? AppColors.exitoPastel : AppColors.arenaClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.mark_email_read_rounded : Icons.mail_lock_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ok ? 'Confirmación enviada' : 'Correo no enviado',
                  style: TextStyle(fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 2),
                Text(correo.mensaje, style: TextStyle(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
