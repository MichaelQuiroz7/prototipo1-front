import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/citas/dtos/cita_entity.dart';

class CitasService {
  late final Dio _dio;
  final String? baseUrl = dotenv.env['ENDPOINT_API5'];

  CitasService() {
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
  //  CITAS
  // ======================================================

  /// Crear cita
  Future<CitaEntity> crearCita(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post('/agendarCita', data: payload);
      return CitaEntity.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  

  // Obtener todas las citas
  Future<List<CitaEntity>> obtenerTodasCitas() async {
    try {
      final response = await _dio.get('/obtenerTodasCitas');
      final List data = response.data;
      return data.map((e) => CitaEntity.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Obtener todas las citas
  Future<List<CitaEntity>> consultarTodas() async {
    try {
      final response = await _dio.get('/consultarTodas');
      final List data = response.data;
      return data.map((e) => CitaEntity.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Obtener citas por cliente
Future<List<CitaEntity>> obtenerCitasPorCliente(int idCliente) async {
  try {
    final response = await _dio.get('/citaXcliente/$idCliente');

    // Caso 1: backend devuelve { ok, total, data }
    if (response.data is Map<String, dynamic>) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => CitaEntity.fromJson(e)).toList();
    }

    // Caso 2: backend devuelve lista directa
    if (response.data is List) {
      return (response.data as List)
          .map((e) => CitaEntity.fromJson(e))
          .toList();
    }

    // Caso raro → sin datos
    return [];
  } on DioException catch (e) {
    // cliente sin citas (404 esperado)
    if (e.response?.statusCode == 404) {
      return [];
    }

    _handleError(e);
    rethrow;
  }
}


  /// Obtener cita por ID
  Future<CitaEntity?> obtenerPorId(int id) async {
    try {
      final response = await _dio.get('/$id');
      return CitaEntity.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  /// Actualizar cita (estado, hora, etc.)
  Future<CitaEntity> actualizarCita(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/citas/$id', data: data);
      return CitaEntity.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Eliminar cita (lógico)
  Future<void> cancelar(int id) async {
    try {
      await _dio.delete('/cancelar/$id');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
  Future<void> reagendar(int id) async {
    try {
      await _dio.delete('/reagendar/$id');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> noasistio(int id) async {
    try {
      print(  'id en servicio: $id');
      await _dio.delete('/noasistio/$id');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ======================================================
  //  UTILIDAD
  // ======================================================

  void _handleError(DioException e) {
    final msg =
        e.response?.data ?? e.message ?? 'Error de conexión con el servidor';
    if (kDebugMode) {
      print(' Error API CitasService: $msg');
    }
  }
}
