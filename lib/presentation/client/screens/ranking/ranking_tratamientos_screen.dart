import 'package:flutter/material.dart';
import 'package:prototipo1_app/config/comentarioCliente/comentario_cliente_service.dart';
import 'package:prototipo1_app/config/comentarioCliente/dto/comentario_cliente.dto.dart';
import 'package:prototipo1_app/presentation/client/screens/ranking/detalle_tratamiento_screen.dart';

class RankingTratamientosScreen extends StatefulWidget {
  const RankingTratamientosScreen({super.key});

  @override
  State<RankingTratamientosScreen> createState() =>
      _RankingTratamientosScreenState();
}

class _RankingTratamientosScreenState extends State<RankingTratamientosScreen> {
  final service = ComentarioClienteService();
  List<ComentarioCliente> comentarios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    final data = await service.obtenerComentariosClientes();
    setState(() {
      comentarios = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final agrupados = agruparPorTratamiento(comentarios);

    final ranking = agrupados.entries.toList()
      ..sort(
        (a, b) =>
            calcularPromedio(b.value).compareTo(calcularPromedio(a.value)),
      );

    return Scaffold(
      appBar: AppBar(title: const Text("Ranking de Tratamientos")),
      body: ListView.builder(
        itemCount: ranking.length,
        itemBuilder: (context, index) {
          final tratamiento = ranking[index].key;
          final lista = ranking[index].value;
          final promedio = calcularPromedio(lista);

          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: ListTile(
              title: Text(
                tratamiento,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "⭐ ${promedio.toStringAsFixed(1)}  •  ${lista.length} comentarios",
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalleTratamientoScreen(
                      tratamiento: tratamiento,
                      comentarios: lista,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Map<String, List<ComentarioCliente>> agruparPorTratamiento(
    List<ComentarioCliente> comentarios,
  ) {
    final Map<String, List<ComentarioCliente>> mapa = {};

    for (var c in comentarios) {
      mapa.putIfAbsent(c.tratamiento, () => []);
      mapa[c.tratamiento]!.add(c);
    }

    return mapa;
  }

 double calcularPromedio(List<ComentarioCliente> lista) {
  if (lista.isEmpty) return 0;

  final total = lista.fold<double>(
    0,
    (sum, item) => sum + item.puntuacion,
  );

  return total / lista.length;
}


 

}


