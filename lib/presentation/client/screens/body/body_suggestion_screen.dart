import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/comentarioCliente/comentario_cliente_service.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/config/comentarioCliente/dto/crear_comentario_dto.dart';
import 'package:prototipo1_app/presentation/client/Components/suggestion box comp/last_reviews_box.dart';
import '../../../../config/comentarioCliente/dto/comentario_cliente.dto.dart';

class BodySuggestionScreen extends ConsumerStatefulWidget {
  const BodySuggestionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BodySuggestionScreenState();
}

class _BodySuggestionScreenState extends ConsumerState<BodySuggestionScreen> {
  List<ComentarioCliente> comentarios = [];

  bool loading = false;
  bool sending = false;

  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 5.0;

  final String baseUrl = dotenv.env['ENDPOINT_API6'] ?? '';

  @override
  void initState() {
    super.initState();
    _cargarComentarios();
  }

  // =============================
  // Cargar comentarios
  // =============================
  Future<void> _cargarComentarios() async {
    setState(() => loading = true);

    try {
      final service = ComentarioClienteService();
      final data = await service.obtenerComentariosClientes();

      setState(() {
        comentarios = data.where((c) => !c.eliminado).toList();
      });
    } catch (e) {
      debugPrint('❌ Error cargando comentarios: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  // =============================
  // Enviar comentario
  // =============================
  Future<void> _enviarComentario() async {
    final cliente = SessionApp.usuarioActual;

    if (cliente == null || _feedbackController.text.trim().isEmpty) return;

    setState(() => sending = true);

    try {
      final dto = CrearComentarioDto(
        idCliente: cliente.idCliente,
        puntuacion: _rating,
        feedback: _feedbackController.text.trim(),
      );

      final service = ComentarioClienteService();
      await service.agregarComentario(dto);

      _feedbackController.clear();
      setState(() => _rating = 5);

      await _cargarComentarios();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario agregado correctamente')),
      );
    } finally {
      setState(() => sending = false);
    }
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =============================
        // LISTA (scrollable)
        // =============================
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : comentarios.isEmpty
                  ? const Center(child: Text('No hay comentarios registrados'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      itemCount: comentarios.length,
                      itemBuilder: (_, index) {
                        final c = comentarios[index];

                        final imageUrl = c.image.isNotEmpty
                            ? '$baseUrl${c.image}'
                            : 'assets/images/default_especialidad.png';

                        return LastReviewsBox(
                          image: imageUrl,
                          nombre: c.nombre,
                          especialdad: c.tratamiento,
                          puntuacion: c.puntuacion,
                          feedback: c.feedback,
                          fecha:
                              '${c.fecha.day}/${c.fecha.month}/${c.fecha.year}',
                          press: () {},
                        );
                      },
                    ),
        ),

        // =============================
        // FORMULARIO (fijo abajo)
        // =============================
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar comentario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Text('Calificación:'),
                  Expanded(
                    child: Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rating.toString(),
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                  ),
                ],
              ),

              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu comentario...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Enviar comentario'),
                  onPressed: sending ? null : _enviarComentario,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
