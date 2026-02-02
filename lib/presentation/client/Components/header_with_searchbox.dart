import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/client/session.dart';

class HeaderWithSearchBox extends StatelessWidget {
  const HeaderWithSearchBox({
    super.key,
    required this.size,
    required TextEditingController searchController,
    this.onChanged,
  }) : _searchController = searchController;

  final Size size;
  final TextEditingController _searchController;
  final ValueChanged<String>? onChanged; // ✅ NUEVO

  String _buildGreeting() {
    final cliente = SessionApp.usuarioActual;
    if (cliente == null) return 'Hola';

    final trimmed = cliente.nombre.trim();
    if (trimmed.isEmpty) return 'Hola';

    final firstName = trimmed.split(RegExp(r'\s+')).first;
    return 'Hola $firstName';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 5),
      height: size.height * 0.2,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 36 + 20),
            height: size.height * 0.2 - 27,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  _buildGreeting(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Image.asset('assets/images/logo.png', height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 10),
                    blurRadius: 50,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.23 * 255).round()),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),

                // ✅ AQUÍ SE CONECTA
                onChanged: onChanged,

                decoration: InputDecoration(
                  hintText: "Buscar",
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.5 * 255).round()),
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.5 * 255).round()),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
