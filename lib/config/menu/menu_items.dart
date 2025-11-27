
import 'package:flutter/material.dart';


class MenuItem {
  final String title;
  final String subTitle;
  final String link;
  final IconData icon;

  const MenuItem({
    required this.title,
    required this.subTitle,
    required this.link,
    required this.icon
  });
}


const appMenuItems = <MenuItem>[
  MenuItem(
    title: 'Perfil',
    subTitle: 'Tu información personal',
    link: '/profile',
    icon: Icons.person,
  ),
  MenuItem(
    title: 'Notificaciones',
    subTitle: 'Alertas y mensajes importantes',
    link: '/notifications',
    icon: Icons.notification_important,
  ),
  MenuItem(
    title: 'Promociones',
    subTitle: 'Ofertas y descuentos disponibles',
    link: '/promotions',
    icon: Icons.card_giftcard,
  ),
  MenuItem(
    title: 'Social',
    subTitle: 'Conecta con otros usuarios',
    link: '/social',
    icon: Icons.group,
  ),
  MenuItem(
    title: 'Acerca de Nosotros',
    subTitle: 'Información sobre la app',
    link: '/about',
    icon: Icons.info,
  ),
  MenuItem(
    title: 'Sugerencias y Reclamos',
    subTitle: 'Envíanos tu opinión',
    link: '/feedback',
    icon: Icons.feedback,
  ),
  MenuItem(
    title: 'Cerrar sesión',
    subTitle: 'Salir de tu cuenta',
    link: '/login',
    icon: Icons.logout,
  ),
  MenuItem(
    title: 'Especialidades',
    subTitle: 'Ver/Agregar especialidades médicas',
    link: '/especialidades',
    icon: Icons.feedback,
  ),
  MenuItem(
    title: 'odontograma',
    subTitle: 'Ver/Agregar odontograma',
    link: '/odontograma',
    icon: Icons.feedback,
  ),
  MenuItem(
    title: 'odontograma Cliente',
    subTitle: 'Ver/Agregar odontograma',
    link: '/odontogramaCliente',
    icon: Icons.feedback,
  ),
];


