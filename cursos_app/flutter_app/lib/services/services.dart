import 'api_client.dart';
import 'auth_service.dart';
import 'cursos_service.dart';
import 'inscripciones_service.dart';
import 'session_storage.dart';

final ApiClient apiClient = ApiClient();
final AuthService authService = AuthService(apiClient, SessionStorage());
final CursosService cursosService = CursosService(apiClient);
final InscripcionesService inscripcionesService = InscripcionesService(apiClient);
