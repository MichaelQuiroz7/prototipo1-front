import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/model/response_model.dart';
import 'package:prototipo1_app/config/promociones/dto/promocion.dto.dart';


class PromocionesService {
  late final Dio _dio;
  final String? baseUrl = dotenv.env['ENDPOINT_API8'];

  PromocionesService() {
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
  // OBTENER PROMOCIONES
  // ======================================================
  Future<List<Promocion>> obtenerPromociones() async {
    try {
      final response = await _dio.get('/obtenerPromociones');

      debugPrint('Respuesta promociones: ${response.data}');

      final result = ResponseModel<List<Promocion>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => Promocion.fromJson(e))
            .toList(),
      );

      if (!result.isSuccess) {
        debugPrint('Backend respondió error: ${result.message}');
        return [];
      }

      return result.data ?? [];
    } on DioException catch (e) {
      final msg =
          e.response?.data ?? e.message ?? 'Error consultando promociones';

      debugPrint('Error PromocionesService: $msg');
      return [];
    }
  }

  // ======================================================
  // CREAR PROMOCION
  // ======================================================
  Future<void> crearPromocion(Promocion promocion) async {
  try {
    final response = await _dio.post(
      '/crearPromocion',
      data: promocion.toCreateJson(),
    );

    debugPrint('RESPUESTA BACKEND: ${response.data}');
  } on DioException catch (e) {
    debugPrint('Error al crear promoción: ${e.response?.data}');
    rethrow;
  }
}


  // ======================================================
  // ACTUALIZAR PROMOCION
  // ======================================================
  Future<void> actualizarPromocion(Promocion promocion) async {
  try {
    final response = await _dio.put(
      '/actualizarPromocion',
      data: promocion.toUpdateJson(),
    );

    debugPrint('RESPUESTA BACKEND: ${response.data}');
  } on DioException catch (e) {
    debugPrint('Error al actualizar promoción: ${e.response?.data}');
    rethrow;
  }
}


  // ======================================================
  // ELIMINAR PROMOCION
  // ======================================================
  Future<void> eliminarPromocion(int idPromocion) async {
    try {
      final response =
          await _dio.delete('/eliminarPromocion/$idPromocion');

      debugPrint('RESPUESTA BACKEND: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Error al eliminar promoción: ${e.message}');
      rethrow;
    }
  }
}
