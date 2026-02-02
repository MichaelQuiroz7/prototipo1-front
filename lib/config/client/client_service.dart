import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/rol_entity.dart';

class ClientService {
  late final Dio _dio;
  final String? baseUrl = dotenv.env['ENDPOINT_API3'];

  ClientService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Interceptor para logs en consola
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      //logPrint: (obj) => print('DioLog: $obj'),
    ));
  }

  // ======================================================
  //  CLIENTES
  // ======================================================

  /// Obtener todos los clientes
  Future<List<Cliente>> getAllClientes() async {
    try {
      final response = await _dio.get('/ObtenerClientes');
      final List data = response.data;
      return data.map((e) => Cliente.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

   /// Obtener todos los EMPLEADOS
  Future<List<Cliente>> getAllEmpleados() async {
    try {
      final response = await _dio.get('/ObtenerEmpleados');
      final List data = response.data;
      return data.map((e) => Cliente.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Obtener cliente por ID
  Future<Cliente?> getClienteById(int id) async {
    try {
      final response = await _dio.get('/ObtenerCliente/$id');
      return Cliente.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Crear cliente
  Future<Cliente> createCliente(Cliente cliente) async {
    try {
      final response = await _dio.post('/AgregarCliente', data: cliente.toJson());
      return Cliente.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Actualizar cliente completo
  Future<Cliente> updateCliente(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/ActualizarCliente/$id', data: data);
      return Cliente.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }


  // Actualizar foto de perfil del cliente
Future<Cliente> updateFotoPerfil(int id, File fotoFile) async {
  try {
    final formData = FormData.fromMap({
      'fotoPerfil': await MultipartFile.fromFile(
        fotoFile.path,
        filename: fotoFile.path.split('/').last,
      ),
    });

    final response = await _dio.patch(
      '/ActualizarFotoPerfil/$id',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return Cliente.fromJson(response.data);
  } on DioException catch (e) {
    _handleError(e);
    rethrow;
  }
}



  /// Actualizar solo la cédula
  Future<Cliente> updateCedula(int id, String cedula) async {
    try {
      final response = await _dio.patch('/ActualizarCedula/$id', data: {'cedula': cedula});
      return Cliente.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Eliminar cliente (lógico)
  Future<void> deleteCliente(int id) async {
    try {
      await _dio.delete('/EliminarCliente/$id');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }


   /// Login local (correo + contraseña)
  Future<Cliente?> loginLocal(String correo, String password) async {
  try {
    final response = await _dio.post(
      '/login',
      data: {'correo': correo, 'password': password},
    );

    return Cliente.fromJson(response.data);

  } on DioException catch (e) {
    _handleError(e);
    return null; // <-- credenciales incorrectas
  }
}



  // ======================================================
  //  ROLES
  // ======================================================

  /// Obtener todos los roles
  Future<List<RolEntity>> getAllRoles() async {
    try {
      final response = await _dio.get('/roles/ObtenerRoles');
      final List data = response.data;
      return data.map((e) => RolEntity.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Obtener rol por ID
  Future<RolEntity?> getRolById(int id) async {
    try {
      final response = await _dio.get('/roles/ObtenerRol/$id');
      return RolEntity.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Crear nuevo rol
  Future<RolEntity> createRol(RolEntity rol) async {
    try {
      final response = await _dio.post('/roles/AgregarRol', data: rol.toJson());
      return RolEntity.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Actualizar rol
  Future<RolEntity> updateRol(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/roles/ActualizarRol/$id', data: data);
      return RolEntity.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// Eliminar rol (lógico)
  Future<void> deleteRol(int id) async {
    try {
      await _dio.delete('/roles/EliminarRol/$id');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ======================================================
  //  UTILIDADES
  // ======================================================

  void _handleError(DioException e) {
    final msg = e.response?.data ??
        e.message ??
        'Error de conexión con el servidor';
    if (kDebugMode) {
      print(' Error API ClienteService: $msg');
    }
  }
}
