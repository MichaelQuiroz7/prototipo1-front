import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/config/theme/dark_mode_notifier.dart';
import 'package:prototipo1_app/presentation/client/Components/my_bottom_nav_bar.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'package:prototipo1_app/presentation/client/screens/body/body_employed_screen.dart';
import 'package:prototipo1_app/presentation/client/screens/body/body_screen.dart';
import 'package:prototipo1_app/presentation/client/widgets/menu/side_menu.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = SessionApp.usuarioActual;
    return Scaffold(
      appBar: buildAppBar(context),
      body: _buildBody(usuario),
      drawer: SideMenu(),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }

  Widget _buildBody(Cliente? usuario) {
  // Si no hay sesión aún
  if (usuario == null) {
    return const Center(child: CircularProgressIndicator());
  }

  // Rol 2 = Cliente
  if (usuario.idRol == 3) {
    return BodyScreen();
  }

  // Cualquier otro rol = Empleado
  return BodyEmployedScreen();
}

  AppBar buildAppBar(context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      //leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
      title: const Text('Perfect Teeth'),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: isDarkModeNotifier,
          builder: (context, isDarkMode, _) {
            return IconButton(
              icon: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny),
              tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
              onPressed: () {
                isDarkModeNotifier.value = !isDarkModeNotifier.value;
              },
            );
          },
        ),
      ],
    );
  }

}

