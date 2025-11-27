import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/presentation/client/Components/my_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();

    final user = SessionApp.usuarioActual;

    nameController = TextEditingController(
      text: user?.nombreCompleto ?? '',
    );

    emailController = TextEditingController(
      text: user?.correo ?? '',
    );

    phoneController = TextEditingController(
      text: user?.telefono ?? '',
    );

    addressController = TextEditingController(
      text: 'Dirección no registrada',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionApp.usuarioActual;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black87),
              onPressed: () => setState(() => isEditing = true),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () {
                // TODO: guardar en backend
                setState(() => isEditing = false);
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() => isEditing = false),
            ),
          ]
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            // FOTO DE PERFIL REAL
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.fotoPerfil != null
                  ? NetworkImage(user!.fotoPerfil!)
                  : const AssetImage('assets/images/polar.jpeg')
                      as ImageProvider,
            ),

            const SizedBox(height: 12),

            Text(
              nameController.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              user?.correo ?? '',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // ESTADÍSTICAS
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _ProfileStat(label: 'Visitas programadas', value: '2'),
                  _ProfileStat(label: 'Visitas asistidas', value: '5'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView(
                children: [
                  _EditableField(
                    icon: LucideIcons.user,
                    label: 'Nombre',
                    controller: nameController,
                    isEditing: isEditing,
                  ),
                  _EditableField(
                    icon: LucideIcons.mail,
                    label: 'Correo',
                    controller: emailController,
                    isEditing: isEditing,
                  ),
                  _EditableField(
                    icon: LucideIcons.phone,
                    label: 'Teléfono',
                    controller: phoneController,
                    isEditing: isEditing,
                  ),
                  _EditableField(
                    icon: LucideIcons.home,
                    label: 'Dirección',
                    controller: addressController,
                    isEditing: isEditing,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MyBottomNavBar(),
    );
  }
}

// --- Widgets auxiliares ---

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool isEditing;

  const _EditableField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: isEditing
          ? TextField(
              controller: controller,
              decoration: const InputDecoration(border: UnderlineInputBorder()),
            )
          : Text(controller.text),
    );
  }
}
