import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/client/session.dart';

class MenuItem {
  final String title;
  final String subTitle;
  final String link;
  final IconData icon;

  const MenuItem({
    required this.title,
    required this.subTitle,
    required this.link,
    required this.icon,
  });
}

class AppMenu {

  static List<MenuItem> get items {

    final usuario = SessionApp.usuarioActual;
    final int? rol = usuario?.idRol;

    final List<MenuItem> menu = [

      const MenuItem(
        title: 'Perfil',
        subTitle: 'Tu información personal',
        link: '/profile',
        icon: Icons.person,
      ),

      const MenuItem(
        title: 'Acerca de Nosotros',
        subTitle: 'Información sobre la app',
        link: '/aboutUs',
        icon: Icons.info,
      ),

      const MenuItem(
        title: 'Sugerencias y Reclamos',
        subTitle: 'Envíanos tu opinión',
        link: '/suggestionBox',
        icon: Icons.feedback,
      ),

      const MenuItem(
        title: 'Cerrar sesión',
        subTitle: 'Salir de tu cuenta',
        link: '/login',
        icon: Icons.logout,
      ),

      const MenuItem(
        title: 'odontograma Cliente',
        subTitle: 'Ver/Agregar odontograma',
        link: '/odontogramaCliente',
        icon: Icons.medical_information,
      ),
    ];

    if (rol != 3) {
      menu.insert(
        3, // posición donde aparecerá
        const MenuItem(
          title: 'Especialidades',
          subTitle: 'Ver/Agregar especialidades médicas',
          link: '/especialidades',
          icon: Icons.medical_services,
        ),
      );
    }

    return menu;
  }
}
