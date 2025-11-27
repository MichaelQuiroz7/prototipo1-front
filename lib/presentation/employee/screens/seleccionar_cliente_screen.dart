import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/client/client_service.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'editor_odontograma_screen.dart';

class SeleccionarClienteScreen extends StatefulWidget {
  const SeleccionarClienteScreen({super.key});

  @override
  State<SeleccionarClienteScreen> createState() => _SeleccionarClienteScreenState();
}

class _SeleccionarClienteScreenState extends State<SeleccionarClienteScreen> {
  final ClientService _clientService = ClientService();
  List<Cliente> clientes = [];
  List<Cliente> filtrados = [];
  final TextEditingController _search = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    try {
      clientes = await _clientService.getAllClientes();
      filtrados = clientes;
    } catch (e) {
      print("Error clientes: $e");
    }
    setState(() => loading = false);
  }

  void _filtrar(String texto) {
    filtrados = clientes
        .where((c) => c.nombreCompleto.toLowerCase().contains(texto.toLowerCase()))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Cliente'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: _filtrar,
              decoration: InputDecoration(
                labelText: "Buscar paciente",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filtrados.length,
                    itemBuilder: (_, i) {
                      final c = filtrados[i];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/polar.jpeg'),
                        ),
                        title: Text(c.nombreCompleto),
                        subtitle: Text(c.correo),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditorOdontogramaScreen(cliente: c),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
