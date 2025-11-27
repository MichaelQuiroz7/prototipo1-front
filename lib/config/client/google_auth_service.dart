

import 'package:google_sign_in/google_sign_in.dart';
import 'package:prototipo1_app/config/client/client_service.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  final _clientService = ClientService();

  /// Iniciar sesión con Google y registrar/verificar el usuario en el backend
  Future<Cliente?> signInWithGoogle() async {
    try {
      // Iniciar el flujo de inicio de sesión
      final account = await _googleSignIn.signIn();
      if (account == null) return null; 
      //print(  ' Usuario Google: ${account.email}');
      // 2️ Obtener datos básicos de Google
      //final auth = await account.authentication;

      final googleId = account.id;
      final correo = account.email;
      final nombre = account.displayName?.split(' ').first ?? '';
      final apellido = account.displayName?.split(' ').skip(1).join(' ') ?? '';
      final foto = account.photoUrl;

      // 3️⃣ Enviar al backend (para registrar o validar)
      final cliente = Cliente(
        idCliente: 0,
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        fotoPerfil: foto,
        googleId: googleId,
        proveedorAuth: 'google',
        idRol: 1,
        fechaRegistro: DateTime.now(),
      );

      // Envía al backend para registrar o validar
      final creado = await _clientService.createCliente(cliente);

      return creado;
    } catch (e) {
      rethrow;
      //return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
