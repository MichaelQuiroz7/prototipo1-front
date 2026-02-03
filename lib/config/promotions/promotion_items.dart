import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/employed/tratamiento_service.dart';
import 'package:prototipo1_app/config/promociones/promotions_services.dart';
import 'package:prototipo1_app/presentation/client/Components/recomend_promotion.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

class PromotionItems {
  final BuildContext context;

  final PromocionesService _promoService = PromocionesService();
  final TratamientosService _tratamientoService = TratamientosService();

  final String baseUrl = dotenv.env['ENDPOINT_API6'] ?? '';

  PromotionItems({required this.context});

  Future<List<RecomendPromotion>> getPromotions() async {
    try {
      final promociones = await _promoService.obtenerPromociones();
      final tratamientos = await _tratamientoService.getAllTratamientos();

      final now = DateTime.now();

      // Filtrar solo activas
      final activas = promociones
          .where(
            (p) =>
                !p.eliminado &&
                now.isAfter(p.fechaInicio) &&
                now.isBefore(p.fechaFin),
          )
          .toList();

      return activas.map((promo) {
        final tratamiento = tratamientos.firstWhere(
          (t) => t.idTratamiento == promo.idTratamiento,
          orElse: () => Tratamiento(
            idTratamiento: 0,
            codigo: '',
            nombre: 'Tratamiento',
            descripcion: '',
            precio: 0,
            imagen: '',
            idEspecialidad: 0,
            eliminado: false,
            fechaCreacion: DateTime.now(),
          ),
        );

        final imageUrl =
            tratamiento.imagen != null && tratamiento.imagen!.isNotEmpty
            ? '$baseUrl${tratamiento.imagen}'
            : 'assets/images/ortodoncia.jpg';

        debugPrint('Imagen promoción: $imageUrl');
        String subtitle;

        if (promo.es2x1) {
          subtitle = "2x1 hasta ${_formatDate(promo.fechaFin)}";
        } else {
          final descuento =
              ((promo.precioAntes - promo.precioAhora) / promo.precioAntes) *
              100;

          subtitle =
              "${descuento.toStringAsFixed(0)}% OFF hasta ${_formatDate(promo.fechaFin)}";
        }

        return RecomendPromotion(
          idPROMO: promo.idPromocion?.toString() ?? '',
          image: imageUrl,
          title: tratamiento.nombre,
          subTitle: subtitle,
          precioAntes: promo.precioAntes,
          precioAhora: promo.precioAhora,
          es2x1: promo.es2x1 ?? false,
          press: () {},
        );
      }).toList();
    } catch (e) {
      debugPrint("Error mapeando promociones: $e");
      return [];
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
