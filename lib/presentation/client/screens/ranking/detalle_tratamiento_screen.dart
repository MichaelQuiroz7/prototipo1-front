import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/comentarioCliente/dto/comentario_cliente.dto.dart';

class DetalleTratamientoScreen extends StatelessWidget {
  final String tratamiento;
  final List<ComentarioCliente> comentarios;

  const DetalleTratamientoScreen({
    super.key,
    required this.tratamiento,
    required this.comentarios,
  });

  @override
  Widget build(BuildContext context) {
    final agrupados = agruparPorMes(comentarios);
    final meses = agrupados.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: Text(tratamiento)),
      body: ListView.builder(
        itemCount: meses.length,
        itemBuilder: (context, index) {
          final mes = meses[index];
          final listaMes = agrupados[mes]!;

          return ExpansionTile(
            title: Text("Mes: $mes (${listaMes.length})"),
            children: listaMes.map((c) {
              final fecha = c.fecha;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    "${dotenv.env['ENDPOINT_API6']}${c.image}",
                  ),
                ),
                title: Text(c.nombre),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("⭐ ${c.puntuacion}"),
                    Text(c.feedback),
                    Text(
                      "${fecha.day}/${fecha.month}/${fecha.year}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Map<String, List<ComentarioCliente>> agruparPorMes(
    List<ComentarioCliente> comentarios,
  ) {
    final Map<String, List<ComentarioCliente>> mapa = {};

    for (var c in comentarios) {
     final fecha = c.fecha;
      final key = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}";

      mapa.putIfAbsent(key, () => []);
      mapa[key]!.add(c);
    }

    return mapa;
  }
}
