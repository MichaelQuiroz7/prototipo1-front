import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/config/menu/menu_items.dart';
import 'package:prototipo1_app/presentation/client/screens/utils/utils.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int navDrawerIndex = 0;

  String _buildGreeting() {
    final cliente = SessionApp.usuarioActual;
    if (cliente == null) return 'Hola';

    final trimmed = cliente.nombre.trim();
    if (trimmed.isEmpty) return 'Hola';

    final firstName = trimmed.split(RegExp(r'\s+')).first;
    return firstName;
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionApp.usuarioActual;
    return NavigationDrawer(
      selectedIndex: navDrawerIndex,
      onDestinationSelected: (int index) {
        setState(() {
          navDrawerIndex = index;
        });

        final selectedItem = appMenuItems[index];
        context.push(selectedItem.link);
      },
      children: [
        // Encabezado de perfil
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(Utils.getProfileImage(user!))),
                ),
              const SizedBox(height: 12),
              Text(
                _buildGreeting(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const Divider(),

        //  Menú dinámico
        ...appMenuItems.map((item) {
          return NavigationDrawerDestination(
            icon: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
            label: Text(item.title),
          );
        }),
      ],
    );
  }
}
