import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/config/employed/odontograma_services.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontograma_model.dart';

import 'package:prototipo1_app/presentation/client/providers/chat/chat_with_context.dart';

class OdontogramaPlanHelper {
  static bool _mostrado = false;
  static bool _procesando = false;

  /// MÉTODO PRINCIPAL
  static Future<void> mostrarPlanDeCuidado(
      BuildContext context, WidgetRef ref) async {
    if (_mostrado || _procesando) return;

    final cliente = SessionApp.usuarioActual;
    if (cliente == null) return;

    _procesando = true;

    try {
      final service = OdontogramaService();
      final Odontograma? odo =
          await service.obtenerOdontogramaPorCliente(cliente.idCliente);

      if (odo == null) {
        _procesando = false;
        return;
      }

      final prompt = _construirPrompt(
        nombreCompleto: cliente.nombreCompleto,
        idCliente: cliente.idCliente,
        odontograma: odo,
      );

      final chatNotifier = ref.read(chatWithContextProvider.notifier);

      /// 👉 NUEVO: usar nuestro método que creamos en el notifier
      final respuesta = await chatNotifier.generarPlanConOdontograma(prompt);

      if (respuesta.trim().isEmpty) {
        _procesando = false;
        return;
      }

      if (!context.mounted) return;

      _mostrarPopup(context, respuesta);
      _mostrado = true;
    } catch (e) {
      debugPrint("Error en mostrarPlanDeCuidado: $e");
    } finally {
      _procesando = false;
    }
  }

  // ----------------------------------------------------------
  // Prompt
  // ----------------------------------------------------------
  static String _construirPrompt({
    required String nombreCompleto,
    required int idCliente,
    required Odontograma odontograma,
  }) {
    final jsonOdo = jsonEncode(odontograma.toJson());

    return '''
Eres un odontólogo experto y tu tarea es analizar el odontograma del paciente.

DATOS DEL PACIENTE:
- Nombre: $nombreCompleto
- ID: $idCliente

ODONTOGRAMA EN JSON:
$jsonOdo

INSTRUCCIONES:
1) Resume su estado bucal.
2) Enumera los dientes que requieren atención.
3) Explica riesgos a corto plazo.
4) Crea un plan de cuidado diario y semanal.
5) Recomienda productos dentales.
6) Indica urgencias si las hay.

Usa lenguaje profesional pero fácil de entender. No menciones que eres IA.
''';
  }

  static void _mostrarPopup(BuildContext context, String texto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Plan de cuidado bucal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(child: Text(texto)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }
}
