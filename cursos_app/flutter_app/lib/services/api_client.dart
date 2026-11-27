import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;

  final Map<String, String> errores;

  const ApiException(this.mensaje, [this.statusCode, this.errores = const {}]);

  bool get noAutorizado => statusCode == 401;

  @override
  String toString() => mensaje;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String ruta, [Map<String, String>? query]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$ruta');
    return (query == null || query.isEmpty) ? uri : uri.replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> get(String ruta, {Map<String, String>? query}) =>
      _enviar(() => _client.get(_uri(ruta, query), headers: _headers));

  Future<Map<String, dynamic>> post(String ruta, Map<String, dynamic> body) =>
      _enviar(() => _client.post(_uri(ruta), headers: _headers, body: jsonEncode(body)));

  Future<Map<String, dynamic>> _enviar(Future<http.Response> Function() peticion) async {
    final http.Response res;
    try {
      res = await peticion().timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder');
    } catch (_) {
      throw const ApiException('No se pudo conectar con el servidor');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Respuesta inválida del servidor', res.statusCode);
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return data;

    final errores = <String, String>{};
    final lista = data['errores'];
    if (lista is List) {
      for (final e in lista) {
        if (e is Map && e['campo'] != null && e['mensaje'] != null) {
          errores.putIfAbsent(e['campo'].toString(), () => e['mensaje'].toString());
        }
      }
    }

    throw ApiException(
      data['mensaje']?.toString() ?? 'Error ${res.statusCode}',
      res.statusCode,
      errores,
    );
  }
}
