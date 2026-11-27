import '../models/usuario.dart';
import 'api_client.dart';
import 'session_storage.dart';

class AuthService {
  AuthService(this._api, this._storage);

  final ApiClient _api;
  final SessionStorage _storage;

  Future<Usuario> login(String clave, String password) async {
    final data = await _api.post('/auth/login', {
      'clave': clave.trim(),
      'password': password,
    });

    final token = data['token'] as String;
    final usuario = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);

    _api.token = token;
    await _storage.guardar(token, usuario);
    return usuario;
  }

  Future<Usuario?> restaurarSesion() async {
    final token = await _storage.leerToken();
    if (token == null) return null;

    _api.token = token;
    try {
      final data = await _api.get('/auth/me');
      return Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.noAutorizado) {
        await logout();
        return null;
      }

      return _storage.leerUsuario();
    }
  }

  Future<void> logout() async {
    _api.token = null;
    await _storage.limpiar();
  }
}
