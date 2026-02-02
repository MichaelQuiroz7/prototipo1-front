import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototipo1_app/presentation/client/Components/expandable_cards.dart';
import 'package:prototipo1_app/presentation/client/dtoCliente/plan_cuidado_model.dart';
import 'package:prototipo1_app/util/notification_service.dart';

import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/config/employed/odontograma_services.dart';
import 'package:prototipo1_app/presentation/employee/dto/odontograma_model.dart';
import 'package:prototipo1_app/presentation/client/providers/chat/chat_with_context.dart';

class OdontogramaPlanHelper {
  static bool _mostrado = false;
  static bool _procesando = false;

  // ===========================================================================
  // MÉTODO PRINCIPAL
  // ===========================================================================

  static Future<void> mostrarPlanDeCuidado(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (_mostrado || _procesando) return;

    final cliente = SessionApp.usuarioActual;
    if (cliente == null) return;

    _procesando = true;

    try {
      final service = OdontogramaService();
      final Odontograma? odo = await service.obtenerOdontogramaPorCliente(
        cliente.idCliente,
      );

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
      final respuesta = await chatNotifier.generarPlanConOdontogramaFull(
        prompt,
      );

      //print("Respuesta helper: $respuesta");

      if (respuesta.trim().isEmpty) {
        _procesando = false;
        return;
      }

      //final textoLimpio = await convertirTablaATexto(respuesta);

      if (!context.mounted) return;

      // _mostrarPopup(context, textoLimpio);

      final plan = await parsearRespuesta(respuesta);
      if (plan == null || !context.mounted) return;

      _mostrarPopup(context, plan);

      _mostrado = true;
    } catch (e) {
      debugPrint(" Error en mostrarPlanDeCuidado: $e");
    } finally {
      _procesando = false;
    }
  }

  // ===========================================================================
  // PROMPT
  // ===========================================================================
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

Usa lenguaje profesional pero fácil de entender.
''';
  }

  // ===========================================================================
  // CONVERTIR TABLA → TEXTO + ACTIVAR NOTIFICACIONES
  // ===========================================================================
  static Future<String> convertirTablaATexto(String respuestaGemini) async {
    try {
      final raw = respuestaGemini.trim();

      // ✅ Caso 1: Formato NUEVO del backend: una sola línea con pipes
      // SI | resumen | riesgos | productos | SI
      if (raw.contains('|')) {
        final parts = raw.split('|').map((e) => e.trim()).toList();

        if (parts.length >= 5) {
          final higiene = parts[0].toUpperCase(); // "SI" o "NO"
          final resumen = parts[1];
          final riesgos = parts[2];
          final productos = parts[3];
          final necesitaCita = parts[4].toUpperCase();

          // DEBUG:
          debugPrint("🧪 HIGIENE_CORRECTA: $higiene");

          // ✅ Armar texto bonito para el popup
          final out = StringBuffer();
          out.writeln("🦷 Estado general:\n$resumen");
          out.writeln("\n⚠️ Riesgos a corto plazo:\n$riesgos");
          out.writeln("\n🛒 Productos recomendados:\n$productos");
          out.writeln(
            necesitaCita == "SI"
                ? "\n🚨 Se recomienda reservar una consulta urgente."
                : "\n✔ No requiere urgencia inmediata.",
          );

          return out.toString().trim();
        }
      }

      // ✅ Caso 2: Si por alguna razón no vino el formato pipe esperado
      return respuestaGemini;
    } catch (e) {
      debugPrint(" Error convertirTablaATexto: $e");
      return respuestaGemini;
    }
  }

  static Future<PlanCuidadoUI?> parsearRespuesta(String raw) async {
    try {
      final parts = raw.split('|').map((e) => e.trim()).toList();
      if (parts.length < 5) return null;

      final higiene = parts[0].toUpperCase();
      final resumen = parts[1];
      final riesgos = parts[2];
      final productosRaw = parts[3];
      final necesitaCita = parts[4].toUpperCase() == "SI";

      //  NOTIFICACIONES
      if (higiene == "SI") {
        // await NotificationService().scheduleReminder(
        //   id: 5001,
        //   title: 'Perfect Teeth 🦷',
        //   body: '🦷 Es hora de cepillarse los dientes',
        //   startDate: DateTime.now(),
        //   frequency: ReminderFrequency.instant,
        // );
        //await NotificationService().openExactAlarmSettings();
        await NotificationService().scheduleDailyAtTime(
          id: 5001,
          title: 'Perfect Teeth 🦷',
          body: 'despues del desayuno es hora de cepillarse los dientes',
          hour: 07,
          minute: 00,
        );
        await NotificationService().scheduleDailyAtTime(
          id: 5002,
          title: 'Perfect Teeth 🦷',
          body: 'despues del almuerzo es hora de cepillarse los dientes',
          hour: 12,
          minute: 30,
        );
        await NotificationService().scheduleDailyAtTime(
          id: 5003,
          title: 'Perfect Teeth 🦷',
          body: 'despues de la cena es hora de cepillarse los dientes',
          hour: 20,
          minute: 23,
        );
      } else {
        await NotificationService.cancel(5001);
        await NotificationService.cancel(5002);
        await NotificationService.cancel(5003);
      }

      // Parsear productos
      final productos = productosRaw
          .split(';')
          .map((p) {
            final regex = RegExp(r'(.+?),.*?([\d.]+).*?(https?:\/\/\S+)');
            final match = regex.firstMatch(p);
            if (match == null) return null;

            return ProductoUI(
              nombre: match.group(1)!.trim(),
              precio: "${match.group(2)} USD",
              link: match.group(3)!,
            );
          })
          .whereType<ProductoUI>()
          .toList();

      return PlanCuidadoUI(
        estadoGeneral: resumen,
        riesgos: riesgos,
        productos: productos,
        necesitaCita: necesitaCita,
      );
    } catch (e) {
      debugPrint(" Error parsearRespuesta: $e");
      return null;
    }
  }

  static void _mostrarPopup(BuildContext context, PlanCuidadoUI plan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Plan de cuidado bucal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ExpandableCard(
                  icon: Icons.medical_information,
                  title: "Estado general",
                  body: plan.estadoGeneral,
                  color: Colors.blue.shade50,
                  accent: Colors.blue,
                ),

                ExpandableCard(
                  icon: Icons.warning_amber_rounded,
                  title: "Riesgos a corto plazo",
                  body: plan.riesgos,
                  color: Colors.orange.shade50,
                  accent: Colors.orange,
                ),

                ExpandableCard(
                  icon: Icons.shopping_bag,
                  title: "Recomendaciones",
                  body: plan.productos
                      .map((p) => "• ${p.nombre} (${p.precio})")
                      .join("\n"),
                  color: Colors.green.shade50,
                  accent: Colors.green,
                ),

                if (plan.necesitaCita)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "⚠️ Se recomienda agendar una cita odontológica.",
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
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
