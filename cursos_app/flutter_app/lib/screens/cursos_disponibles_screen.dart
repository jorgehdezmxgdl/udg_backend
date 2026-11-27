import 'dart:async';

import 'package:flutter/material.dart';

import '../config/empresa.dart';
import '../models/curso.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/services.dart';
import '../theme/app_colors.dart';
import '../utils/formateadores.dart';
import '../widgets/centrado.dart';
import '../widgets/curso_card.dart';
import '../widgets/encabezado_degradado.dart';
import '../widgets/estado_vista.dart';
import '../widgets/icono_curso.dart';
import '../widgets/login_dialog.dart';
import '../widgets/mision_vision.dart';
import 'dashboard_screen.dart';
import 'inscripcion_screen.dart';

class CursosDisponiblesScreen extends StatefulWidget {
  const CursosDisponiblesScreen({super.key, this.usuario});

  final Usuario? usuario;

  @override
  State<CursosDisponiblesScreen> createState() => _CursosDisponiblesScreenState();
}

class _CursosDisponiblesScreenState extends State<CursosDisponiblesScreen> {
  final _busqueda = TextEditingController();
  Timer? _debounce;

  late Usuario? _usuario = widget.usuario;
  Set<int> _inscritos = {};
  List<Curso> _cursos = [];
  bool _cargando = true;
  String? _error;
  String? _categoria;

  @override
  void initState() {
    super.initState();
    _cargar();
    _cargarInscritos();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final cursos = await cursosService.listarDisponibles(busqueda: _busqueda.text);
      if (!mounted) return;
      setState(() {
        _cursos = cursos;
        if (!cursos.any((c) => c.categoria == _categoria)) _categoria = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cargarInscritos() async {
    if (_usuario == null) return;
    try {
      final mis = await cursosService.misCursos();
      if (mounted) setState(() => _inscritos = mis.cursos.map((c) => c.curso.id).toSet());
    } on ApiException {
      return;
    }
  }

  void _buscar(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _cargar);
    setState(() {});
  }

  Future<void> _iniciarSesion() async {
    final usuario = await LoginDialog.mostrar(context);
    if (usuario == null || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardScreen(usuario: usuario)),
    );
  }

  void _irAMisCursos() {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen(usuario: _usuario!)));
    }
  }

  Future<void> _inscribirme(Curso curso) async {
    var usuario = _usuario;
    if (usuario == null) {
      usuario = await LoginDialog.mostrar(context);
      if (usuario == null || !mounted) return;
      setState(() => _usuario = usuario);
      await _cargarInscritos();
      if (!mounted) return;
    }

    if (_inscritos.contains(curso.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya estás inscrito en "${curso.titulo}"')),
      );
      return;
    }

    final alumno = usuario;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InscripcionScreen(curso: curso, usuario: alumno)),
    );
  }

  void _verDetalle(Curso curso) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) => _DetalleCurso(
        curso: curso,
        conSesion: _usuario != null,
        inscrito: _inscritos.contains(curso.id),
        onInscribirme: () {
          Navigator.of(ctx).pop();
          _inscribirme(curso);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.usuario == null ? 0 : 1,
      child: Scaffold(
        body: Column(
          children: [
            _encabezado(context),
            Centrado(
              child: TabBar(
                labelColor: AppColors.primario,
                unselectedLabelColor: AppColors.textoSuave,
                indicatorColor: AppColors.oceano,
                indicatorWeight: 3,
                dividerColor: AppColors.borde,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                tabs: const [
                  _Pestana(icono: Icons.diversity_3_rounded, texto: 'Quiénes somos'),
                  _Pestana(icono: Icons.auto_stories_rounded, texto: 'Cursos'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Centrado(ancho: 1100, child: MisionVision()),
                  ),
                  _pestanaCursos(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final angosta = MediaQuery.sizeOf(context).width < 400;

    return EncabezadoDegradado(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LogoApp(),
              const Spacer(),
              if (_usuario == null)
                FilledButton.icon(
                  onPressed: _iniciarSesion,
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: Text(angosta ? 'Entrar' : 'Iniciar sesión'),
                )
              else
                FilledButton.icon(
                  onPressed: _irAMisCursos,
                  icon: const Icon(Icons.dashboard_rounded, size: 20),
                  label: Text(angosta ? 'Mi panel' : 'Mis cursos'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(Empresa.slogan, style: tema.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            _usuario == null
                ? 'Explora el catálogo e inicia sesión para inscribirte.'
                : 'Hola, ${_usuario!.primerNombre}. Elige tu próximo curso.',
            style: tema.bodyMedium?.copyWith(color: AppColors.textoSuave),
          ),
        ],
      ),
    );
  }

  Widget _pestanaCursos(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final categorias = _cursos.map((c) => c.categoria).toSet().toList()..sort();
    final cursos = _categoria == null ? _cursos : _cursos.where((c) => c.categoria == _categoria).toList();

    return RefreshIndicator(
      onRefresh: () => Future.wait([_cargar(), _cargarInscritos()]),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Centrado(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _busqueda,
                onChanged: _buscar,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar curso, tema o instructor...',
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _busqueda.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _busqueda.clear();
                            _buscar('');
                          },
                        ),
                ),
              ),
            ),
          ),
          if (_cursos.isNotEmpty)
            SliverToBoxAdapter(
              child: Centrado(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip(
                        texto: 'Todas',
                        icono: Icons.apps_rounded,
                        activo: _categoria == null,
                        onTap: () => setState(() => _categoria = null),
                      ),
                      for (final cat in categorias)
                        _Chip(
                          texto: cat,
                          icono: IconoCurso.iconoDe(_cursos.firstWhere((c) => c.categoria == cat).icono),
                          activo: _categoria == cat,
                          onTap: () => setState(() => _categoria = cat),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (_cargando && _cursos.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: Center(child: CargandoVista()))
          else if (_error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: MensajeVista.error(mensaje: _error!, onReintentar: _cargar)),
            )
          else if (cursos.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: MensajeVista(
                  icono: Icons.search_off_rounded,
                  titulo: 'Sin resultados',
                  mensaje: 'Prueba con otra búsqueda o categoría.',
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Centrado(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text('Cursos disponibles', style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text('${cursos.length}', style: tema.labelLarge?.copyWith(color: AppColors.textoSuave)),
                  ],
                ),
              ),
            ),
            SliverList.separated(
              itemCount: cursos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => Centrado(
                child: CursoCard(
                  curso: cursos[i],
                  inscrito: _inscritos.contains(cursos[i].id),
                  onTap: () => _verDetalle(cursos[i]),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(texto, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto, required this.icono, required this.activo, required this.onTap});

  final String texto;
  final IconData icono;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final forma = StadiumBorder(side: BorderSide(color: activo ? AppColors.arenaOscuro : AppColors.borde));

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: activo ? AppColors.arenaPastel : Colors.white,
        shape: forma,
        child: InkWell(
          customBorder: forma,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 18, color: activo ? AppColors.texto : AppColors.primario),
                const SizedBox(width: 6),
                Text(
                  texto,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.texto),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetalleCurso extends StatelessWidget {
  const _DetalleCurso({
    required this.curso,
    required this.conSesion,
    required this.inscrito,
    required this.onInscribirme,
  });

  final Curso curso;
  final bool conSesion;
  final bool inscrito;
  final VoidCallback onInscribirme;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final precio = formatoDinero(curso.precio, corto: true);

    final (IconData icono, String texto) = inscrito
        ? (Icons.verified_rounded, 'Ya estás inscrito')
        : conSesion
            ? (Icons.shopping_cart_checkout_rounded, 'Inscribirme · $precio')
            : (Icons.login_rounded, 'Inicia sesión para inscribirte');

    Widget dato(IconData icono, String titulo, String valor) => Expanded(
          child: Column(
            children: [
              Icon(icono, color: AppColors.primario),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(valor, style: tema.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              ),
              Text(titulo, style: tema.bodySmall?.copyWith(color: AppColors.textoSuave)),
            ],
          ),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconoCurso(nombre: curso.icono, tamano: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(curso.titulo, style: tema.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(curso.descripcion, style: tema.bodyLarge),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primarioClaro,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  dato(Icons.schedule_rounded, 'Duración', '${curso.duracionHoras} h'),
                  dato(Icons.signal_cellular_alt_rounded, 'Nivel', curso.nivel),
                  dato(Icons.groups_rounded, 'Cupo', '${curso.cupo}'),
                  dato(Icons.sell_rounded, 'Precio', precio),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_rounded, size: 18, color: AppColors.textoSuave),
                const SizedBox(width: 6),
                Expanded(child: Text(curso.instructor, style: tema.bodyMedium)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: inscrito ? null : onInscribirme,
                icon: Icon(icono),
                label: Text(texto),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
