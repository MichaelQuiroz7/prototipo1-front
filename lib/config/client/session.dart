import 'dart:convert';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionApp {
  static const _storageKey = 'usuario_actual';

  static Cliente? usuarioActual;

  static bool get isLogged => usuarioActual != null;

  static Future<void> init() async {
    await _loadFromStorage();
  }

  static Future<void> setUsuario(Cliente? cliente) async {
    usuarioActual = cliente;
    await _persist(cliente);
  }

  static Future<void> logout() => setUsuario(null);

  // Guardar en SharedPreferences
  static Future<void> _persist(Cliente? cliente) async {
    final prefs = await SharedPreferences.getInstance();

    if (cliente == null) {
      await prefs.remove(_storageKey);
      return;
    }

    await prefs.setString(
      _storageKey,
      jsonEncode(cliente.toJson(includeRol: true)),
    );
  }

  // Cargar usuario de SharedPreferences
  static Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      usuarioActual = null;
      return;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      usuarioActual = Cliente.fromJson(data);
    } catch (e) {
      usuarioActual = null;
    }
  }
}
