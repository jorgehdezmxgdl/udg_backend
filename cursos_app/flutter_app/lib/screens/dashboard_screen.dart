import 'package:flutter/material.dart';

import '../models/curso_inscrito.dart';
import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/services.dart';
import '../theme/app_colors.dart';
import '../widgets/curso_inscrito_card.dart';
import '../widgets/encabezado_degradado.dart';
import '../widgets/estado_vista.dart';
import '../widgets/stat_tile.dart';
import 'cursos_disponibles_screen.dart';

enum _Filtro { todos, enCurso, completados }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<MisCursos> _futuro;
  _Filtro _filtro = _Filtro.todos;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<MisCursos> _cargar() async {
    try {
      return await cursosService.misCursos();
    } on ApiException catch (e) {
      if (e.noAutorizado) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _cerrarSesion(expirada: true));
      }
      rethrow;
    }
  }

  Future<void> _recargar() async {
    final futuro = _cargar();
    setState(() {
      _futuro = futuro;
    });
    try {
      await futuro;
    } catch (_) {
    }
  }

  Future<void> _cerrarSesion({bool expirada = false}) async {
    await authService.logout();
    if (!mounted) return;

    if (expirada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu sesión expiró. Vuelve a iniciar sesión.')),
      );
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CursosDisponiblesScreen()),
      (_) => false,
    );
  }

  Future<void> _nuevoCurso() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CursosDisponiblesScreen(usuario: widget.usuario)),
    );
    if (mounted) _recargar();
  }

  Future<void> _confirmarSalida() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.primario),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de tu cuenta?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salir')),
        ],
      ),
    );
    if (salir == true) await _cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoCurso,
        backgroundColor: AppColors.arena,
        foregroundColor: AppColors.texto,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Nuevo curso', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _encabezado(context)),
            SliverToBoxAdapter(
              child: FutureBuilder<MisCursos>(
                future: _futuro,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const CargandoVista(mensaje: 'Cargando tus cursos...');
                  }
                  if (snap.hasError) {
                    return MensajeVista.error(
                      mensaje: snap.error.toString(),
                      onReintentar: _recargar,
                    );
                  }
                  return _contenido(context, snap.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final u = widget.usuario;

    return EncabezadoDegradado(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LogoApp(),
              const Spacer(),
              IconButton.filledTonal(
                tooltip: 'Cerrar sesión',
                onPressed: _confirmarSalida,
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.7)),
                icon: const Icon(Icons.logout_rounded, color: AppColors.primario),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.arena,
                child: Text(
                  u.iniciales,
                  style: tema.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.texto,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${u.primerNombre}! 👋',
                      style: tema.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 16, color: AppColors.textoSuave),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${u.clave} · ${u.correo}',
                            overflow: TextOverflow.ellipsis,
                            style: tema.bodySmall?.copyWith(color: AppColors.textoSuave),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contenido(BuildContext context, MisCursos datos) {
    final tema = Theme.of(context).textTheme;
    final r = datos.resumen;

    final cursos = switch (_filtro) {
      _Filtro.todos => datos.cursos,
      _Filtro.enCurso => datos.cursos.where((c) => !c.completado).toList(),
      _Filtro.completados => datos.cursos.where((c) => c.completado).toList(),
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              LayoutBuilder(
                builder: (context, c) {
                  final columnas = c.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: columnas,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: columnas == 4 ? 2.0 : 1.9,
                    children: [
                      StatTile(
                        icono: Icons.menu_book_rounded,
                        valor: '${r.total}',
                        etiqueta: 'Cursos tomados',
                      ),
                      StatTile(
                        icono: Icons.verified_rounded,
                        valor: '${r.completados}',
                        etiqueta: 'Completados',
                        fondoIcono: AppColors.exitoPastel,
                        colorIcono: AppColors.exito,
                      ),
                      StatTile(
                        icono: Icons.schedule_rounded,
                        valor: '${r.horasCompletadas} h',
                        etiqueta: 'Horas acreditadas',
                        fondoIcono: AppColors.arenaPastel,
                        colorIcono: AppColors.arenaOscuro,
                      ),
                      StatTile(
                        icono: Icons.star_rounded,
                        valor: r.promedio?.toStringAsFixed(1) ?? '—',
                        etiqueta: 'Promedio',
                        fondoIcono: AppColors.arenaPastel,
                        colorIcono: AppColors.arenaOscuro,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Icon(Icons.collections_bookmark_rounded, color: AppColors.primario, size: 20),
                  const SizedBox(width: 8),
                  Text('Mis cursos', style: tema.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<_Filtro>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.arenaPastel,
                  selectedForegroundColor: AppColors.texto,
                  side: const BorderSide(color: AppColors.borde),
                ),
                segments: const [
                  ButtonSegment(value: _Filtro.todos, label: Text('Todos')),
                  ButtonSegment(value: _Filtro.enCurso, label: Text('En curso')),
                  ButtonSegment(value: _Filtro.completados, label: Text('Hechos')),
                ],
                selected: {_filtro},
                onSelectionChanged: (s) => setState(() => _filtro = s.first),
              ),
              const SizedBox(height: 16),

              if (cursos.isEmpty)
                MensajeVista(
                  icono: Icons.inbox_rounded,
                  titulo: datos.cursos.isEmpty ? 'Aún no tienes cursos' : 'Nada por aquí',
                  mensaje: datos.cursos.isEmpty
                      ? 'Toca «Nuevo curso» para inscribirte a tu primer curso.'
                      : 'No hay cursos en este filtro.',
                )
              else
                for (final c in cursos) ...[
                  CursoInscritoCard(inscrito: c),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
