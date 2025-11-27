import 'package:flutter/material.dart';
import 'package:prototipo1_app/presentation/client/Components/my_bottom_nav_bar.dart';
import 'package:prototipo1_app/presentation/client/screens/details/components/body_details.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({
    super.key,
    required this.idEspecialidad,
    required this.nombreEspecialidad,
    required this.imagenEspecialidad,
  });
  final int idEspecialidad;
  final String nombreEspecialidad;
  final String imagenEspecialidad;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyDetails(
        idEspecialidad: idEspecialidad,
        nombreEspecialidad: nombreEspecialidad,
        imagenEspecialidad: imagenEspecialidad,
      ),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }
}
