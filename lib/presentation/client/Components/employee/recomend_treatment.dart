import 'package:flutter/material.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

class RecomendTreatment extends StatelessWidget {
  const RecomendTreatment({
    super.key,
    required this.primaryColor,
    required this.imageUrl,
    required this.t,
  });

  final Color primaryColor;
  final String imageUrl;
  final Tratamiento t;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 📷 Imagen
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Container(
              width: 110,
              height: 120, // 🔹 un poco más alto
              color: Colors.grey[100],
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported,
                        color: primaryColor.withOpacity(0.4),
                        size: 40),
              ),
            ),
          ),
    
          // 📋 Texto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.nombre.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 0.3,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.descripcion ?? '',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey[800],
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (t.precio > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "\$${t.precio.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}