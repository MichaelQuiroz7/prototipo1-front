import 'package:flutter/material.dart';

class RecomendPromotion extends StatelessWidget {
  const RecomendPromotion({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.press,
    required this.idPROMO,
  });

  final String image;
  final String title;
  final String subTitle;
  final VoidCallback press;
  final String idPROMO;

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
              // ✅ Imagen ocupa todo el cuadro
              Image.asset(
                image,
                fit: BoxFit.cover,
              ),

              // ✅ Capa semitransparente para mejor legibilidad
              Container(
                color: Colors.black.withOpacity(0.3),
              ),

              // ✅ Texto encima de la imagen
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
                      Text(
                        subTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
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
