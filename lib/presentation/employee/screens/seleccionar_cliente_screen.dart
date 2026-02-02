import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/client/client_service.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/client_model.dart';
import 'package:prototipo1_app/presentation/client/screens/citas/selectorespecialidad_tratamiento_sheet.dart';
import 'editor_odontograma_screen.dart';

class SeleccionarClienteScreen extends StatefulWidget {
  final int? idRol;

  const SeleccionarClienteScreen({
    super.key,
    this.idRol,
  });

  @override
  State<SeleccionarClienteScreen> createState() =>
      _SeleccionarClienteScreenState();
}

class _SeleccionarClienteScreenState
    extends State<SeleccionarClienteScreen> {
  final ClientService _clientService = ClientService();

  List<Cliente> clientes = [];
  List<Cliente> filtrados = [];
  final TextEditingController _search = TextEditingController();

  bool loading = true;

  bool get esEmpleado => widget.idRol != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==========================================
  // CARGAR CLIENTES O EMPLEADOS
  // ==========================================
  Future<void> _loadData() async {
    try {
      if (esEmpleado) {
        clientes = await _clientService.getAllEmpleados();
      } else {
        clientes = await _clientService.getAllClientes();
      }

      filtrados = clientes;
    } catch (e) {
      debugPrint("Error al cargar datos: $e");
    }

    setState(() => loading = false);
  }

  // ==========================================
  // FILTRO
  // ==========================================
  void _filtrar(String texto) {
    filtrados = clientes
        .where(
          (c) => c.nombreCompleto
              .toLowerCase()
              .contains(texto.toLowerCase()),
        )
        .toList();
    setState(() {});
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          esEmpleado
              ? 'Seleccionar Empleado'
              : 'Seleccionar Cliente',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              onChanged: _filtrar,
              decoration: InputDecoration(
                labelText: esEmpleado
                    ? "Buscar empleado"
                    : "Buscar paciente",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                          backgroundImage: AssetImage(
                            'assets/images/polar.jpeg',
                          ),
                        ),
                        title: Text(c.nombreCompleto),
                        subtitle: Text(c.correo),
                        trailing:
                            const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          if (esEmpleado) {
                            
                            Navigator.pop(context, c);
                          } else {
                            _mostrarOpcionesCliente(c);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODAL OPCIONES CLIENTE
  // ==========================================
  void _mostrarOpcionesCliente(Cliente c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(
                  Icons.medical_services,
                  color: Colors.blue,
                ),
                title: const Text('Odontograma'),
                subtitle: const Text(
                  'Ver o editar odontograma del paciente',
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditorOdontogramaScreen(
                        cliente: c,
                      ),
                    ),
                  );
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Colors.green,
                ),
                title: const Text('Reservar cita'),
                subtitle: const Text(
                  'Agendar una cita para este paciente',
                ),
                onTap: () {
                  Navigator.pop(context);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape:
                        const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) =>
                        const SelectorEspecialidadTratamientoSheet(),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
