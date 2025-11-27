

import 'dart:convert';

import 'package:prototipo1_app/presentation/client/dtoCliente/rol_entity.dart';

class Cliente {
  final int idCliente;
  final String nombre;
  final String? apellido;
  final String? cedula;
  final String correo;
  final String? telefono;
  final String? fotoPerfil;
  final String? googleId;
  final String? passwordHash;
  final String proveedorAuth;
  final DateTime? fechaNacimiento;
  final String? genero;
  final int? idRol;
  final RolEntity? rol;
  final DateTime fechaRegistro;
  final DateTime? ultimoAcceso;
  final bool activo;
  final bool eliminado;

  Cliente({
    required this.idCliente,
    required this.nombre,
    this.apellido,
    this.cedula,
    required this.correo,
    this.telefono,
    this.fotoPerfil,
    this.googleId,
    this.passwordHash,
    this.proveedorAuth = 'local',
    this.fechaNacimiento,
    this.genero,
    this.idRol,
    this.rol,
    required this.fechaRegistro,
    this.ultimoAcceso,
    this.activo = true,
    this.eliminado = false,
  });

  // ==========================================================
  //  Constructor desde JSON (respuesta del backend)
  // ==========================================================
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['IdCliente'] ?? json['id_cliente'] ?? 0,
      nombre: json['Nombre'] ?? json['nombre'] ?? '',
      apellido: json['Apellido'] ?? json['apellido'],
      cedula: json['Cedula'] ?? json['cedula'],
      correo: json['Correo'] ?? json['correo'] ?? '',
      telefono: json['Telefono'] ?? json['telefono'],
      fotoPerfil: json['FotoPerfil'] ?? json['foto_perfil'],
      googleId: json['GoogleId'] ?? json['google_id'],
      passwordHash: json['PasswordHash'] ?? json['password_hash'],
      proveedorAuth: json['ProveedorAuth'] ?? json['proveedor_auth'] ?? 'local',
      fechaNacimiento: json['FechaNacimiento'] != null
          ? DateTime.tryParse(json['FechaNacimiento'] ?? json['fecha_nacimiento'])
          : null,
      genero: json['Genero'] ?? json['genero'],
      idRol: json['IdRol'] ?? json['id_rol'],
      rol: json['Rol'] != null && json['Rol'] is Map<String, dynamic>
          ? RolEntity.fromJson(json['Rol'])
          : null,
      fechaRegistro: DateTime.tryParse(
              json['FechaRegistro'] ?? json['fecha_registro'] ?? '') ??
          DateTime.now(),
      ultimoAcceso: json['UltimoAcceso'] != null
          ? DateTime.tryParse(json['UltimoAcceso'] ?? json['ultimo_acceso'])
          : null,
      activo: json['Activo'] ?? json['activo'] ?? true,
      eliminado: json['Eliminado'] ?? json['eliminado'] ?? false,
    );
  }

  // ==========================================================
  //  Convertir a JSON (para enviar al backend)
  // ==========================================================
  Map<String, dynamic> toJson({bool includeRol = false}) {
    final data = {
      'IdCliente': idCliente,
      'Nombre': nombre,
      'Apellido': apellido,
      'Cedula': cedula,
      'Correo': correo,
      'Telefono': telefono,
      'FotoPerfil': fotoPerfil,
      'GoogleId': googleId,
      'PasswordHash': passwordHash,
      'ProveedorAuth': proveedorAuth,
      'FechaNacimiento': fechaNacimiento?.toIso8601String(),
      'Genero': genero,
      'IdRol': idRol,
      'FechaRegistro': fechaRegistro.toIso8601String(),
      'UltimoAcceso': ultimoAcceso?.toIso8601String(),
      'Activo': activo,
      'Eliminado': eliminado,
    };

    if (includeRol && rol != null) {
      data['Rol'] = rol!.toJson();
    }

    return data;
  }

  // ==========================================================
  //  Métodos utilitarios
  // ==========================================================
  String get nombreCompleto => '${nombre.trim()} ${apellido?.trim() ?? ''}'.trim();

  bool get esGoogle => proveedorAuth.toLowerCase() == 'google';

  bool get estaActivo => activo && !eliminado;

  @override
  String toString() => jsonEncode(toJson());
}
