import '../models/catalogos.dart';
import '../models/inscripcion.dart';
import 'api_client.dart';

class InscripcionesService {
  InscripcionesService(this._api);

  final ApiClient _api;
  Catalogos? _cache;

  Future<Catalogos> catalogos() async {
    final cache = _cache;
    if (cache != null) return cache;
    final data = await _api.get('/catalogos');
    return _cache = Catalogos.fromJson(data);
  }

  Future<ResultadoInscripcion> inscribir(SolicitudInscripcion solicitud) async {
    final data = await _api.post('/inscripciones', solicitud.toJson());
    return ResultadoInscripcion.fromJson(data);
  }
}
