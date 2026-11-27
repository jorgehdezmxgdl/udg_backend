import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/services.dart';
import '../theme/app_colors.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  static Future<Usuario?> mostrar(BuildContext context) {
    return showDialog<Usuario>(
      context: context,
      builder: (_) => const LoginDialog(),
    );
  }

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _claveCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _cargando = false;
  bool _ocultarPassword = true;
  String? _errorServidor;

  @override
  void dispose() {
    _claveCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validarClave(String? v) {
    final valor = v?.trim() ?? '';
    if (valor.isEmpty) return 'Ingresa tu clave';
    if (valor.length < 3) return 'Mínimo 3 caracteres';
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(valor))
      return 'Solo letras, números, . _ -';
    return null;
  }

  String? _validarPassword(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorServidor = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      final usuario =
          await authService.login(_claveCtrl.text, _passwordCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pop(usuario);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorServidor = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_cargando,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 12, 20),
                  decoration:
                      const BoxDecoration(gradient: AppColors.degradado),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.lock_person_rounded,
                            color: AppColors.primario, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Iniciar sesión',
                                style: tema.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            Text('Accede para ver tus cursos',
                                style: tema.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: _cargando
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _claveCtrl,
                          enabled: !_cargando,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                            labelText: 'Clave',
                            hintText: 'Ej. mramirez',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: _validarClave,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordCtrl,
                          enabled: !_cargando,
                          obscureText: _ocultarPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _enviar(),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _ocultarPassword ? 'Mostrar' : 'Ocultar',
                              onPressed: () => setState(
                                  () => _ocultarPassword = !_ocultarPassword),
                              icon: Icon(_ocultarPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                            ),
                          ),
                          validator: _validarPassword,
                        ),
                        if (_errorServidor != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorPastel,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorServidor!,
                                    style: tema.bodyMedium
                                        ?.copyWith(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _cargando ? null : _enviar,
                          icon: _cargando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.login_rounded),
                          label: Text(_cargando ? 'Validando...' : 'Entrar'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 16, color: AppColors.textoSuave),
                            const SizedBox(width: 6),
                            Text(
                              'Tus datos están seguros..',
                              style: tema.bodySmall
                                  ?.copyWith(color: AppColors.textoSuave),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
