import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prototipo1_app/config/menu/menu_items.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int navDrawerIndex = 0;

  @override
  Widget build(BuildContext context) {
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
          backgroundImage: AssetImage('assets/images/polar.jpeg'),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Michael',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    ],
  ),
),

        const Divider(),

        // 📋 Menú dinámico
        ...appMenuItems.map((item) {
          return NavigationDrawerDestination(
            icon: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
            label: Text(item.title),
          );
        }).toList(),
      ],
    );
  }
}