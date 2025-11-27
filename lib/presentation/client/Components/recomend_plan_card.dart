import 'package:flutter/material.dart';

class RecomendPlanCard extends StatelessWidget {
  const RecomendPlanCard({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.price,
    required this.press,
  });

  final String image;
  final String title;
  final String subTitle;
  final double price;
  final VoidCallback press;

  bool get isNetworkImage => image.startsWith('http') || image.startsWith('https');

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      width: size.width * 0.45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- IMAGEN ---
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: isNetworkImage
                  ? Image.network(
                      image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.contain,
                    ),
            ),
          ),

          // --- CONTENIDO ---
          GestureDetector(
            onTap: press,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${title.toUpperCase()}\n',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: subTitle,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // --- Mostrar precio solo si > 0 ---
                  if (price > 0)
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
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
