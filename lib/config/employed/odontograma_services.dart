import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/presentation/employee/dto/catalogo_dientes_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontocolor_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontograma_detalle_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontograma_model.dart';


class OdontogramaService {
  late final Dio _dio;
  final String? baseUrl = dotenv.env['ENDPOINT_API4'];

  OdontogramaService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('odontograma obtenido correctamente'),
        //debugPrint('odontograma obtenido: $obj'),
      ),
    );
  }

  // ======================================================
  //  ODONTOCOLOR
  // ======================================================

  Future<List<OdontoColor>> obtenerColores() async {
    try {
      final response = await _dio.get('/ObtenerColores');
      final List data = response.data;
      return data.map((e) => OdontoColor.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ======================================================
  //  CATALOGO DIENTES
  // ======================================================

  Future<List<CatalogoDientes>> obtenerCatalogoDientes() async {
    try {
      final response = await _dio.get('/ObtenerCatalogoDientes');
      final List data = response.data;
      return data.map((e) => CatalogoDientes.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ======================================================
  //  ODONTOGRAMA
  // ======================================================

  Future<List<Odontograma>> obtenerOdontogramas() async {
    try {
      final response = await _dio.get('/ObtenerOdontogramas');
      final List data = response.data;
      return data.map((e) => Odontograma.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Odontograma?> obtenerOdontograma(int id) async {
    try {
      final response = await _dio.get('/ObtenerOdontograma/$id');
      return Odontograma.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  // ====================================================
  // OBTENER ODONTOGRAMA POR CLIENTE
  // ====================================================
  Future<Odontograma?> obtenerOdontogramaPorCliente(int idCliente) async {
    try {
      final response = await _dio.get('/ObtenerPorCliente/$idCliente');

      if (response.data == null) return null;

      return Odontograma.fromJson(response.data);

    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<Odontograma> agregarOdontograma(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/AgregarOdontograma', data: data);
      return Odontograma.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Odontograma> actualizarOdontograma(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/ActualizarOdontograma/$id', data: data);
      return Odontograma.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  

  Future<void> eliminarOdontograma(int id) async {
    try {
      await _dio.delete('/EliminarOdontograma/$id');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ======================================================
  //  ODONTOGRAMA DETALLE
  // ======================================================

  Future<OdontogramaDetalle?> obtenerDetalle(int id) async {
    try {
      final response = await _dio.get('/detalle/ObtenerDetalle/$id');
      return OdontogramaDetalle.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      return null;
    }
  }

  Future<OdontogramaDetalle> agregarDetalle(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/detalle/AgregarDetalle', data: data);
      return OdontogramaDetalle.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<OdontogramaDetalle> actualizarDetalle(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/detalle/ActualizarDetalle/$id', data: data);
      return OdontogramaDetalle.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> eliminarDetalle(int id) async {
    try {
      await _dio.delete('/detalle/EliminarDetalle/$id');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ======================================================
  //  Manejo de errores
  // ======================================================

  void _handleError(DioException e) {
    final msg = e.response?.data ?? e.message ?? 'Error de servidor';
    if (kDebugMode) {
      print('Error API OdontogramaService: $msg');
    }
  }
}
