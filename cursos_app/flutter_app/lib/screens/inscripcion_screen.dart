import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/catalogos.dart';
import '../models/curso.dart';
import '../models/inscripcion.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/services.dart';
import '../theme/app_colors.dart';
import '../utils/formateadores.dart';
import '../utils/validadores.dart';
import '../widgets/campo_seleccion.dart';
import '../widgets/centrado.dart';
import '../widgets/estado_vista.dart';
import '../widgets/icono_curso.dart';
import '../widgets/selector_metodo_pago.dart';
import 'confirmacion_screen.dart';
import 'cursos_disponibles_screen.dart';

class InscripcionScreen extends StatefulWidget {
  const InscripcionScreen({super.key, required this.curso, required this.usuario});

  final Curso curso;
  final Usuario usuario;

  @override
  State<InscripcionScreen> createState() => _InscripcionScreenState();
}

class _InscripcionScreenState extends State<InscripcionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  late Future<Catalogos> _catalogos;

  late final _nombre = TextEditingController(text: widget.usuario.nombre);
  late final _correo = TextEditingController(text: widget.usuario.correo);
  String? _pais;

  MetodoPago? _metodo;
  final _titular = TextEditingController();
  final _numero = TextEditingController();
  final _vencimiento = TextEditingController();
  final _cvv = TextEditingController();
  String? _banco;
  final _clabe = TextEditingController();
  final _wallet = TextEditingController();

  bool _aceptaTerminos = false;
  bool _enviando = false;
  bool _intentoEnviar = false;
  String? _errorGeneral;
  Map<String, String> _erroresServidor = {};

  @override
  void initState() {
    super.initState();
    _catalogos = inscripcionesService.catalogos();
  }

  @override
  void dispose() {
    for (final c in [_nombre, _correo, _titular, _numero, _vencimiento, _cvv, _clabe, _wallet]) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  FormFieldValidator<String> _v(String campo, String? Function(String?) local) =>
      (valor) => local(valor) ?? _erroresServidor[campo];

  void _quitarErrorServidor(String campo) {
    if (_erroresServidor.containsKey(campo)) {
      setState(() => _erroresServidor = Map.of(_erroresServidor)..remove(campo));
    }
  }

  Map<String, String> _datosPago() => switch (_metodo!) {
        MetodoPago.tarjeta => {
            'titular': _titular.text.trim(),
            'numero': Validadores.limpiar(_numero.text),
            'vencimiento': _vencimiento.text.trim(),
            'cvv': _cvv.text.trim(),
          },
        MetodoPago.transferencia => {
            'banco': _banco ?? '',
            'clabe': Validadores.limpiar(_clabe.text),
          },
        MetodoPago.bitcoin => {'wallet': _wallet.text.trim()},
      };

  Future<void> _pagar() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _intentoEnviar = true;
      _errorGeneral = null;
      _erroresServidor = {};
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _errorGeneral = 'Revisa los campos marcados en rojo antes de continuar.');
      _irArriba();
      return;
    }

    setState(() => _enviando = true);
    try {
      final resultado = await inscripcionesService.inscribir(
        SolicitudInscripcion(
          cursoId: widget.curso.id,
          nombre: _nombre.text,
          correo: _correo.text,
          pais: _pais!,
          metodo: _metodo!,
          datosPago: _datosPago(),
          aceptaTerminos: _aceptaTerminos,
        ),
      );
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ConfirmacionScreen(resultado: resultado, usuario: widget.usuario),
        ),
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      if (e.noAutorizado) {
        await authService.logout();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tu sesión expiró. Inicia sesión de nuevo.')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CursosDisponiblesScreen()),
          (_) => false,
        );
        return;
      }

      setState(() {
        _erroresServidor = e.errores;
        final otros = e.errores.length - 1;
        _errorGeneral = otros > 0 ? '${e.mensaje}\n…y $otros error(es) más marcados abajo.' : e.mensaje;
      });
      _formKey.currentState!.validate();
      _irArriba();
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _irArriba() {
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_enviando,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inscripción'),
          leading: IconButton(
            tooltip: 'Regresar',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _enviando ? null : () => Navigator.of(context).maybePop(),
          ),
        ),
        body: FutureBuilder<Catalogos>(
          future: _catalogos,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CargandoVista(mensaje: 'Preparando formulario...'));
            }
            if (snap.hasError) {
              return Center(
                child: MensajeVista.error(
                  mensaje: snap.error.toString(),
                  onReintentar: () => setState(() {
                    _catalogos = inscripcionesService.catalogos();
                  }),
                ),
              );
            }
            return _formulario(context, snap.data!);
          },
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context, Catalogos cat) {
    final curso = widget.curso;

    return Form(
      key: _formKey,
      autovalidateMode:
          _intentoEnviar ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Centrado(
            ancho: 640,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorGeneral != null) ...[
                  _BannerError(mensaje: _errorGeneral!),
                  const SizedBox(height: 12),
                ],
                _ResumenCurso(curso: curso),
                const SizedBox(height: 16),

                _Seccion(
                  numero: 1,
                  titulo: 'Datos del alumno',
                  icono: Icons.person_rounded,
                  children: [
                    TextFormField(
                      controller: _nombre,
                      enabled: !_enviando,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      inputFormatters: [LengthLimitingTextInputFormatter(100)],
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        hintText: 'Nombre y apellidos',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      onChanged: (_) => _quitarErrorServidor('nombre'),
                      validator: _v('nombre', Validadores.nombre),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _correo,
                      enabled: !_enviando,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        helperText: 'Aquí recibirás la confirmación de pago e inscripción',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      onChanged: (_) => _quitarErrorServidor('correo'),
                      validator: _v('correo', Validadores.correo),
                    ),
                    const SizedBox(height: 14),
                    CampoSeleccion(
                      etiqueta: 'País',
                      icono: Icons.public_rounded,
                      opciones: cat.paises,
                      initialValue: _pais,
                      habilitado: !_enviando,
                      onChanged: (v) {
                        _pais = v;
                        _quitarErrorServidor('pais');
                      },
                      validator: (v) =>
                          Validadores.requerido(v, 'Selecciona tu país') ?? _erroresServidor['pais'],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _Seccion(
                  numero: 2,
                  titulo: 'Forma de pago',
                  icono: Icons.payments_rounded,
                  children: [
                    SelectorMetodoPago(
                      initialValue: _metodo,
                      habilitado: !_enviando,
                      onChanged: (m) {
                        setState(() => _metodo = m);
                        _quitarErrorServidor('pago');
                        _quitarErrorServidor('pago.metodo');
                      },
                      validator: (m) => m == null
                          ? 'Elige transferencia, tarjeta o bitcoin'
                          : (_erroresServidor['pago'] ?? _erroresServidor['pago.metodo']),
                    ),
                    if (_metodo != null) ...[
                      const SizedBox(height: 16),
                      switch (_metodo!) {
                        MetodoPago.tarjeta => _camposTarjeta(),
                        MetodoPago.transferencia => _camposTransferencia(cat),
                        MetodoPago.bitcoin => _camposBitcoin(cat),
                      },
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                _Seccion(
                  numero: 3,
                  titulo: 'Confirmar',
                  icono: Icons.task_alt_rounded,
                  children: [
                    _filaTotal(context, curso),
                    const SizedBox(height: 8),
                    FormField<bool>(
                      initialValue: _aceptaTerminos,
                      validator: (v) => v == true
                          ? _erroresServidor['aceptaTerminos']
                          : 'Debes aceptar los términos y condiciones',
                      builder: (state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            value: state.value ?? false,
                            onChanged: _enviando
                                ? null
                                : (v) {
                                    state.didChange(v);
                                    setState(() => _aceptaTerminos = v ?? false);
                                  },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.primario,
                            title: const Text('Acepto los términos y condiciones y el aviso de privacidad'),
                          ),
                          if (state.hasError)
                            Text(
                              state.errorText!,
                              style: const TextStyle(color: AppColors.error, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: _enviando ? null : _pagar,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                  icon: _enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Icon(Icons.lock_rounded),
                  label: Text(
                    _enviando
                        ? 'Procesando pago...'
                        : 'Pagar ${formatoDinero(curso.precio)} e inscribirme',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _camposTarjeta() {
    final marca = Validadores.marcaTarjeta(Validadores.limpiar(_numero.text));
    final amex = Validadores.esAmex(Validadores.limpiar(_numero.text));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _titular,
          enabled: !_enviando,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.creditCardName],
          decoration: const InputDecoration(
            labelText: 'Titular de la tarjeta',
            hintText: 'Como aparece en la tarjeta',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          onChanged: (_) => _quitarErrorServidor('pago.titular'),
          validator: _v('pago.titular', Validadores.titular),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _numero,
          enabled: !_enviando,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.creditCardNumber],
          inputFormatters: [AgruparDigitosFormatter(maxDigitos: 19)],
          decoration: InputDecoration(
            labelText: 'Número de tarjeta',
            hintText: '0000 0000 0000 0000',
            prefixIcon: const Icon(Icons.credit_card_rounded),
            suffixText: marca.isEmpty ? null : marca,
            helperText: 'Prueba: 4242 4242 4242 4242 · rechazo: 4000 0000 0000 0002',
          ),
          onChanged: (_) {
            _quitarErrorServidor('pago.numero');
            setState(() {});
          },
          validator: _v('pago.numero', Validadores.numeroTarjeta),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _vencimiento,
                enabled: !_enviando,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.creditCardExpirationDate],
                inputFormatters: [VencimientoFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Vence',
                  hintText: 'MM/AA',
                  prefixIcon: Icon(Icons.event_rounded),
                ),
                onChanged: (_) => _quitarErrorServidor('pago.vencimiento'),
                validator: _v('pago.vencimiento', (v) => Validadores.vencimiento(v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cvv,
                enabled: !_enviando,
                keyboardType: TextInputType.number,
                obscureText: true,
                autofillHints: const [AutofillHints.creditCardSecurityCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(amex ? 4 : 3),
                ],
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: amex ? '0000' : '000',
                  prefixIcon: const Icon(Icons.password_rounded),
                ),
                onChanged: (_) => _quitarErrorServidor('pago.cvv'),
                validator: _v('pago.cvv', (v) => Validadores.cvv(v, _numero.text)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _camposTransferencia(Catalogos cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoPago(
          icono: Icons.account_balance_rounded,
          lineas: [
            'Transfiere ${formatoDinero(widget.curso.precio)} vía SPEI a:',
            'CLABE CurMex: ${cat.clabeDestino}',
            'Después indica desde qué cuenta pagaste.',
          ],
        ),
        const SizedBox(height: 14),
        CampoSeleccion(
          etiqueta: 'Banco de origen',
          icono: Icons.account_balance_outlined,
          opciones: cat.bancos,
          initialValue: _banco,
          habilitado: !_enviando,
          onChanged: (v) {
            _banco = v;
            _quitarErrorServidor('pago.banco');
          },
          validator: (v) =>
              Validadores.requerido(v, 'Selecciona tu banco') ?? _erroresServidor['pago.banco'],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _clabe,
          enabled: !_enviando,
          keyboardType: TextInputType.number,
          inputFormatters: [AgruparDigitosFormatter(maxDigitos: 18)],
          decoration: const InputDecoration(
            labelText: 'Tu CLABE interbancaria',
            hintText: '18 dígitos',
            prefixIcon: Icon(Icons.dialpad_rounded),
          ),
          onChanged: (_) => _quitarErrorServidor('pago.clabe'),
          validator: _v('pago.clabe', Validadores.clabe),
        ),
      ],
    );
  }

  Widget _camposBitcoin(Catalogos cat) {
    final btc = widget.curso.precio / cat.tipoCambioBtcMxn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoPago(
          icono: Icons.currency_bitcoin_rounded,
          lineas: [
            'Envía ≈ ${btc.toStringAsFixed(8)} BTC (${formatoDinero(widget.curso.precio)})',
            'Wallet CurMex: ${cat.walletDestino}',
            'Tipo de cambio: 1 BTC = ${formatoDinero(cat.tipoCambioBtcMxn)}',
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _wallet,
          enabled: !_enviando,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(
            labelText: 'Tu dirección de wallet Bitcoin',
            hintText: 'bc1q...',
            prefixIcon: Icon(Icons.account_balance_wallet_rounded),
          ),
          onChanged: (_) => _quitarErrorServidor('pago.wallet'),
          validator: _v('pago.wallet', Validadores.wallet),
        ),
      ],
    );
  }

  Widget _filaTotal(BuildContext context, Curso curso) {
    final tema = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarioClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: AppColors.primario),
          const SizedBox(width: 10),
          Text('Total a pagar', style: tema.titleSmall),
          const Spacer(),
          Text(
            formatoDinero(curso.precio),
            style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.numero,
    required this.titulo,
    required this.icono,
    required this.children,
  });

  final int numero;
  final String titulo;
  final IconData icono;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.arenaPastel,
                  child: Text('$numero', style: tema.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Icon(icono, size: 20, color: AppColors.primario),
                const SizedBox(width: 6),
                Text(titulo, style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ResumenCurso extends StatelessWidget {
  const _ResumenCurso({required this.curso});
  final Curso curso;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.degradado,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconoCurso(nombre: curso.icono, tamano: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(curso.titulo,
                    style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                Text('${curso.instructor} · ${curso.duracionHoras} h · ${curso.nivel}',
                    style: tema.bodySmall),
                const SizedBox(height: 6),
                Text(formatoDinero(curso.precio),
                    style: tema.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerError extends StatelessWidget {
  const _BannerError({required this.mensaje});
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorPastel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No pudimos completar tu inscripción',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.error),
                ),
                const SizedBox(height: 2),
                Text(mensaje, style: const TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPago extends StatelessWidget {
  const _InfoPago({required this.icono, required this.lineas});
  final IconData icono;
  final List<String> lineas;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarioClaro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: AppColors.primario),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final l in lineas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(l, style: Theme.of(context).textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
