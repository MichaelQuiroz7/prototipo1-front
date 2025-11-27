import 'package:flutter/material.dart';
import 'package:prototipo1_app/presentation/client/Components/recomend_promotion.dart';
import 'package:prototipo1_app/presentation/client/screens/Home/home_screen.dart';

class PromotionItems {
  final BuildContext context;

  const PromotionItems({required this.context});

  List<RecomendPromotion> getPromotions() {
    return [
      RecomendPromotion(
        idPROMO: 'A1',
        image: 'assets/images/ortodoncia.jpg',
        title: 'Descuento Ortodoncia',
        subTitle: '20% OFF este mes',
        press: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
      ),
      RecomendPromotion(
        idPROMO: 'A2',
        image: 'assets/images/ortodoncia.jpg',
        title: 'Limpieza Dental',
        subTitle: '2x1 hasta fin de mes',
        press: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
      ),
      RecomendPromotion(
        idPROMO: 'A3',
        image: 'assets/images/ortodoncia.jpg',
        title: 'Blanqueamiento',
        subTitle: '10% de descuento',
        press: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
      ),
    ];
  }
}