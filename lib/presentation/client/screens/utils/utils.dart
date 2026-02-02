import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';

class Utils {
  static String getProfileImage(Cliente cliente) {
    final baseUrl = dotenv.env['ENDPOINT_API6'] ?? ' ';

    if (cliente.fotoPerfil == null || cliente.fotoPerfil!.isEmpty) {
      return 'assets/images/polar.jpeg';
    }

    final foto = cliente.fotoPerfil;
    // Si es ruta relativa (backend)

    debugPrint('Base URL para fotos: $baseUrl$foto');
    return '$baseUrl$foto';
  }
}
