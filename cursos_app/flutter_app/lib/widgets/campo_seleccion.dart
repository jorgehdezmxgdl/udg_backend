import 'package:flutter/material.dart';

import '../models/catalogos.dart';
import '../theme/app_colors.dart';

class CampoSeleccion extends FormField<String> {
  CampoSeleccion({
    super.key,
    required String etiqueta,
    required IconData icono,
    required List<Opcion> opciones,
    required ValueChanged<String> onChanged,
    super.validator,
    super.initialValue,
    bool habilitado = true,
    String? textoAyuda,
  }) : super(
          enabled: habilitado,
          builder: (state) {
            final seleccion = opciones.where((o) => o.codigo == state.value).firstOrNull;

            Future<void> abrir() async {
              final elegido = await showModalBottomSheet<String>(
                context: state.context,
                isScrollControlled: true,
                showDragHandle: true,
                backgroundColor: Colors.white,
                builder: (_) => _HojaSeleccion(
                  titulo: etiqueta,
                  opciones: opciones,
                  seleccionado: state.value,
                ),
              );
              if (elegido != null) {
                state.didChange(elegido);
                onChanged(elegido);
              }
            }

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: habilitado ? abrir : null,
              child: InputDecorator(
                isEmpty: seleccion == null,
                decoration: InputDecoration(
                  labelText: etiqueta,
                  helperText: textoAyuda,
                  prefixIcon: Icon(icono),
                  suffixIcon: const Icon(Icons.expand_more_rounded),
                  errorText: state.errorText,
                  enabled: habilitado,
                ),
                child: Text(
                  seleccion?.nombre ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
}

class _HojaSeleccion extends StatefulWidget {
  const _HojaSeleccion({required this.titulo, required this.opciones, this.seleccionado});

  final String titulo;
  final List<Opcion> opciones;
  final String? seleccionado;

  @override
  State<_HojaSeleccion> createState() => _HojaSeleccionState();
}

class _HojaSeleccionState extends State<_HojaSeleccion> {
  String _filtro = '';

  static String _normalizar(String s) {
    const con = 'áéíóúüñ';
    const sin = 'aeiouun';
    var r = s.toLowerCase();
    for (var i = 0; i < con.length; i++) {
      r = r.replaceAll(con[i], sin[i]);
    }
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final f = _normalizar(_filtro.trim());
    final lista = widget.opciones.where((o) => _normalizar(o.nombre).contains(f)).toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Padding(

        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                autofocus: widget.opciones.length > 12,
                onChanged: (v) => setState(() => _filtro = v),
                decoration: InputDecoration(
                  hintText: 'Buscar ${widget.titulo.toLowerCase()}...',
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text('Sin coincidencias', style: TextStyle(color: AppColors.textoSuave)),
                    )
                  : ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (_, i) {
                        final o = lista[i];
                        final activo = o.codigo == widget.seleccionado;
                        return ListTile(
                          title: Text(o.nombre,
                              style: TextStyle(fontWeight: activo ? FontWeight.w700 : FontWeight.w500)),
                          trailing: activo
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.primario)
                              : null,
                          selected: activo,
                          selectedTileColor: AppColors.arenaClaro,
                          onTap: () => Navigator.of(context).pop(o.codigo),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
