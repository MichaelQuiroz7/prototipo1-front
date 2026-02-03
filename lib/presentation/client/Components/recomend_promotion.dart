import 'package:flutter/material.dart';

class RecomendPromotion extends StatelessWidget {
  const RecomendPromotion({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.press,
    required this.idPROMO,
    this.precioAntes,
    this.precioAhora,
    this.es2x1 = false,
  });

  final String image;
  final String title;
  final String subTitle;
  final VoidCallback press;
  final String idPROMO;

  final double? precioAntes;
  final double? precioAhora;
  final bool es2x1;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: press,
      child: Container(
        width: size.width * 0.65,
        height: size.height * 0.55,
        margin: const EdgeInsets.only(left: 20, top: 10, bottom: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 6),
              blurRadius: 15,
              color: Colors.black.withOpacity(0.15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen
              image.startsWith('http')
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/ortodoncia.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(image, fit: BoxFit.cover),

              // Overlay
              Container(color: Colors.black.withOpacity(0.3)),

              // Texto y precios
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // SUBTITULO
                      Text(
                        subTitle,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              offset: Offset(1, 1),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Colors.white,
                              offset: Offset(-1, -1),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Colors.white,
                              offset: Offset(1, -1),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Colors.white,
                              offset: Offset(-1, 1),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // PRECIOS
                      if (es2x1)
                        const Text(
                          "2x1",
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else if (precioAntes != null && precioAhora != null)
                        Row(
                          children: [
                            Text(
                              "\$${precioAntes!.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "\$${precioAhora!.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.yellowAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: Offset(1, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
