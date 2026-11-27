import '../models/curso.dart';
import '../models/curso_inscrito.dart';
import 'api_client.dart';

class CursosService {
  CursosService(this._api);

  final ApiClient _api;

  Future<List<Curso>> listarDisponibles({String? busqueda}) async {
    final q = busqueda?.trim();
    final data = await _api.get(
      '/cursos',
      query: (q == null || q.isEmpty) ? null : {'q': q},
    );
    return (data['cursos'] as List)
        .map((e) => Curso.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MisCursos> misCursos() async {
    final data = await _api.get('/mis-cursos');
    return MisCursos.fromJson(data);
  }
}
