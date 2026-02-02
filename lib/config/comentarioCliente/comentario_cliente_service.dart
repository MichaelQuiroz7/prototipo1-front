import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/comentarioCliente/dto/crear_comentario_dto.dart';
import 'package:prototipo1_app/config/model/response_model.dart';

import 'dto/comentario_cliente.dto.dart';


class ComentarioClienteService {
  late final Dio _dio;
  final String? baseUrl = dotenv.env['ENDPOINT_API7'];

  ComentarioClienteService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  // ======================================================
  //  OBTENER COMENTARIOS DE CLIENTES
  // ======================================================
  Future<List<ComentarioCliente>> obtenerComentariosClientes() async {
    try {

      final response = await _dio.get('/obtenerComentarios');

      debugPrint('Respuesta comentarios: ${response.data}');

      final result = ResponseModel<List<ComentarioCliente>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => ComentarioCliente.fromJson(e))
            .toList(),
      );

      if (!result.isSuccess) {
        debugPrint('Backend respondió error: ${result.message}');
        return [];
      }

      return result.data ?? [];
    } on DioException catch (e) {
      final msg =
          e.response?.data ?? e.message ?? 'Error consultando comentarios';

      debugPrint('Error ComentarioClienteService: $msg');
      return [];
    }
  }

  Future<void> agregarComentario(CrearComentarioDto dto) async {
  try {
    debugPrint('DTO ENVIADO: ${dto.toJson()}');

    final response = await _dio.post(
      '/AgregarComentario',
      data: dto.toJson(),
    );

    debugPrint('✅ RESPUESTA BACKEND: ${response.data}');
  } on DioException catch (e) {
    //_handleError(e);
    debugPrint('❌ Error al agregar comentario: ${e.message}');
    rethrow;
  }
}



}
