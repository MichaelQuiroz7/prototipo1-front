import 'package:flutter/material.dart';

class LastReviewsBox extends StatelessWidget {
  final String image;
  final String nombre;
  final String especialdad;
  final double puntuacion;
  final String feedback;
  final String fecha;
  final VoidCallback press;

  const LastReviewsBox({
    super.key,
    required this.image,
    required this.nombre,
    required this.especialdad,
    required this.puntuacion,
    required this.feedback,
    required this.fecha,
    required this.press,
  });

  bool get isNetworkImage =>
      image.startsWith('http') || image.startsWith('https');

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: press,
      child: Container(
        width: size.width * 0.9,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───── Header (avatar + name + date) ─────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: isNetworkImage
                      ? NetworkImage(image)
                      : AssetImage(image) as ImageProvider,
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nombre,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          // ───── Fecha ─────
                          Text(
                            fecha,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ───── Estrellas ─────
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < puntuacion.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ───── Feedback ─────
            Text(
              'Tratamiento: $especialdad\n$feedback',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
