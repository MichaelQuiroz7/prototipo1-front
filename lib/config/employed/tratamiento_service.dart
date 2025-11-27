import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/presentation/employee/dto/especialidad_model.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';


class TratamientosService {
  late final Dio _dio;
  final String? baseUrl = dotenv.env['ENDPOINT_API2'];

  TratamientosService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // // Interceptor para logs legibles en consola
    // _dio.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    //   logPrint: (obj) => print('DioLog: $obj'),
    // ));
  }

  // ======================================================
  //  TRATAMIENTOS
  // ======================================================

  Future<List<Tratamiento>> getAllTratamientos() async {
    final response = await _dio.get('/obtenerTratamientos');
    final List data = response.data;
    return data.map((e) => Tratamiento.fromJson(e)).toList();
  }

  Future<Tratamiento?> getTratamientoById(int id) async {
    final response = await _dio.get('/tratamiento/$id');
    return Tratamiento.fromJson(response.data);
  }

  /// Crear un tratamiento (con o sin imagen)
  Future<Tratamiento> createTratamiento(
    Tratamiento tratamiento, {
    File? imagenFile,
  }) async {
    final formData = FormData.fromMap({
      ...tratamiento.toJson(),
      if (imagenFile != null)
        'imagen': await MultipartFile.fromFile(
          imagenFile.path,
          filename: imagenFile.path.split('/').last,
        ),
    });

    final response = await _dio.post('/', data: formData);
    return Tratamiento.fromJson(response.data);
  }

  /// Actualizar tratamiento (con o sin imagen nueva)
  Future<Tratamiento> updateTratamiento(
    int id,
    Map<String, dynamic> data, {
    File? imagenFile,
  }) async {
    final formData = FormData.fromMap({
      ...data,
      if (imagenFile != null)
        'imagen': await MultipartFile.fromFile(
          imagenFile.path,
          filename: imagenFile.path.split('/').last,
        ),
    });

    final response = await _dio.patch('/tratamiento/$id', data: formData);
    return Tratamiento.fromJson(response.data);
  }

  Future<void> deleteTratamiento(int id) async {
    await _dio.delete('/tratamiento/delete/$id');
  }

  // ======================================================
  //  ESPECIALIDADES
  // ======================================================

  Future<List<Especialidad>> getAllEspecialidades() async {
    final response = await _dio.get('/obtenerEspecialidades');
    final List data = response.data;
    return data.map((e) => Especialidad.fromJson(e)).toList();
  }

  Future<Especialidad?> getEspecialidadById(int id) async {
    final response = await _dio.get('/especialidad/$id');
    return Especialidad.fromJson(response.data);
  }

  /// Crear una especialidad (con o sin imagen)
  Future<Especialidad> createEspecialidad(
    Especialidad especialidad, {
    File? imagenFile,
  }) async {
    final formData = FormData.fromMap({
      ...especialidad.toJson(),
      if (imagenFile != null)
        'imagen': await MultipartFile.fromFile(
          imagenFile.path,
          filename: imagenFile.path.split('/').last,
        ),
    });

    final response = await _dio.post('/especialidad', data: formData);
    return Especialidad.fromJson(response.data);
  }

  /// Actualizar especialidad (con o sin imagen nueva)
  Future<Especialidad> updateEspecialidad(
    int id,
    Map<String, dynamic> data, {
    File? imagenFile,
  }) async {
    final formData = FormData.fromMap({
      ...data,
      if (imagenFile != null)
        'imagen': await MultipartFile.fromFile(
          imagenFile.path,
          filename: imagenFile.path.split('/').last,
        ),
    });

    final response = await _dio.patch('/especialidad/$id', data: formData);
    return Especialidad.fromJson(response.data);
  }

  Future<void> deleteEspecialidad(int id) async {
    await _dio.delete('/especialidad/delete/$id');
  }
}