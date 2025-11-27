import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prototipo1_app/config/client/session.dart';
import 'package:prototipo1_app/config/employed/tratamiento_service.dart';
import 'package:prototipo1_app/config/promotions/promotion_items.dart';
import 'package:prototipo1_app/presentation/client/Components/floating_bubble.dart';
import 'package:prototipo1_app/presentation/client/Components/header_with_searchbox.dart';
import 'package:prototipo1_app/presentation/client/Components/recomend_plan_card.dart';
import 'package:prototipo1_app/presentation/client/Components/recomend_promotion.dart';
import 'package:prototipo1_app/presentation/client/Components/title_with_custom_underline.dart';
import 'package:prototipo1_app/presentation/client/providers/helper/odontograma_plan_helper.dart';
import 'package:prototipo1_app/presentation/client/screens/details/details_screen.dart';
import 'package:prototipo1_app/presentation/employee/dto/especialidad_model.dart';

import '../../Components/title_with_more_btn.dart' show TitleWithMoreBtn;

class BodyScreen extends ConsumerStatefulWidget {
  const BodyScreen({super.key});

  @override
  ConsumerState<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends ConsumerState<BodyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _promoController = PageController(
    viewportFraction: 0.75,
  );
  final TratamientosService _service = TratamientosService();

  int _currentPage = 0;
  Timer? _timer;

  List<Especialidad> _especialidades = [];
  bool _loading = true;
  final String baseUrl = 'http://192.168.1.20:3000';

  @override
  void initState() {
    super.initState();
    _loadEspecialidades();

    // Carrusel automático
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_promoController.hasClients) {
        if (_currentPage < 2) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _promoController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });

    // ⭐ Mostrar recomendación al inicio
    Future.delayed(const Duration(milliseconds: 800), () {
      _mostrarRecomendacionBucal();
    });
  }

  Future<void> _loadEspecialidades() async {
    try {
      final data = await _service.getAllEspecialidades();
      setState(() {
        _especialidades = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar especialidades: $e');
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _promoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _mostrarRecomendacionBucal() async {
  try {
    final cliente = SessionApp.usuarioActual;
    if (cliente == null) return;

    // 👉 LLAMADA CORRECTA
    await OdontogramaPlanHelper.mostrarPlanDeCuidado(context, ref);

  } catch (e) {
    debugPrint("❌ Error mostrando recomendación bucal: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final List<RecomendPromotion> promotions = PromotionItems(
      context: context,
    ).getPromotions();

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              HeaderWithSearchBox(
                size: size,
                searchController: _searchController,
              ),
              const SizedBox(height: 15),

              TitleWithMoreBtn(
                text: 'Servicios Disponibles',
                press: () {
                  debugPrint('Ver todo: Servicios disponibles');
                },
              ),

              _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _especialidades.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No hay especialidades registradas'),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _especialidades.map((esp) {
                              final imageUrl = esp.imagen != null
                                  ? '$baseUrl${esp.imagen}'
                                  : null;

                              return Container(
                                margin: const EdgeInsets.only(left: 16),
                                child: RecomendPlanCard(
                                  image: imageUrl ??
                                      'assets/images/default_especialidad.png',
                                  title: esp.nombre,
                                  subTitle:
                                      esp.descripcion ?? 'Especialidad disponible',
                                  price: 0.0,
                                  press: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailsScreen(
                                          idEspecialidad: esp.idEspecialidad,
                                          nombreEspecialidad: esp.nombre,
                                          imagenEspecialidad: esp.imagen ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: TitleWithCustomUnderline(text: 'Promociones'),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: size.width * 0.55,
                child: PageView.builder(
                  controller: _promoController,
                  itemCount: promotions.length,
                  itemBuilder: (context, index) {
                    return Center(child: promotions[index]);
                  },
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),

        // ⭐ NO TOCO NADA, sigue funcionando igual
        const FloatingBubble(),
      ],
    );
  }
}































































// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:prototipo1_app/config/employed/tratamiento_service.dart';
// import 'package:prototipo1_app/config/promotions/promotion_items.dart';
// import 'package:prototipo1_app/presentation/client/Components/floating_bubble.dart';
// import 'package:prototipo1_app/presentation/client/Components/header_with_searchbox.dart';
// import 'package:prototipo1_app/presentation/client/Components/recomend_plan_card.dart';
// import 'package:prototipo1_app/presentation/client/Components/recomend_promotion.dart';
// import 'package:prototipo1_app/presentation/client/Components/title_with_custom_underline.dart';
// import 'package:prototipo1_app/presentation/client/screens/details/details_screen.dart';
// import 'package:prototipo1_app/presentation/employee/dto/especialidad_model.dart';
// import '../../Components/title_with_more_btn.dart' show TitleWithMoreBtn;

// class BodyScreen extends StatefulWidget {
//   const BodyScreen({super.key});

//   @override
//   State<BodyScreen> createState() => _BodyScreenState();
// }

// class _BodyScreenState extends State<BodyScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final PageController _promoController = PageController(
//     viewportFraction: 0.75,
//   );
//   final TratamientosService _service = TratamientosService();

//   int _currentPage = 0;
//   Timer? _timer;

//   List<Especialidad> _especialidades = [];
//   bool _loading = true;
//   final String baseUrl =
//       'http://192.168.1.20:3000'; 

//   @override
//   void initState() {
//     super.initState();
//     _loadEspecialidades();

//     // Carrusel automático
//     _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
//       if (_promoController.hasClients) {
//         if (_currentPage < 2) {
//           _currentPage++;
//         } else {
//           _currentPage = 0;
//         }
//         _promoController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   Future<void> _loadEspecialidades() async {
//     try {
//       final data = await _service.getAllEspecialidades();
//       setState(() {
//         _especialidades = data;
//         _loading = false;
//       });
//     } catch (e) {
//       debugPrint('Error al cargar especialidades: $e');
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _promoController.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     final List<RecomendPromotion> promotions = PromotionItems(
//       context: context,
//     ).getPromotions();

//     return Stack(
//       children: [
//         SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               HeaderWithSearchBox(
//                 size: size,
//                 searchController: _searchController,
//               ),
//               const SizedBox(height: 15),

//               // ---- SECCIÓN DE SERVICIOS ----
//               TitleWithMoreBtn(
//                 text: 'Servicios Disponibles',
//                 press: () {
//                   debugPrint('Ver todo: Servicios disponibles');
//                 },
//               ),

//               _loading
//                   ? const Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(30),
//                         child: CircularProgressIndicator(),
//                       ),
//                     )
//                   : _especialidades.isEmpty
//                   ? const Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(20),
//                         child: Text('No hay especialidades registradas'),
//                       ),
//                     )
//                   : SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: _especialidades.map((esp) {
//                           final imageUrl = esp.imagen != null
//                               ? '$baseUrl${esp.imagen}'
//                               : null;

//                           return Container(
//                             margin: const EdgeInsets.only(left: 16),
//                             child: RecomendPlanCard(
//                               image:
//                                   imageUrl ??
//                                   'assets/images/default_especialidad.png',
//                               title: esp.nombre,
//                               subTitle:
//                                   esp.descripcion ?? 'Especialidad disponible',
//                               price: 0.0,
//                               press: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => DetailsScreen(
//                                       idEspecialidad: esp.idEspecialidad,
//                                       nombreEspecialidad: esp.nombre,
//                                       imagenEspecialidad: esp.imagen ?? '',
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                     const SizedBox(height: 15),

//               // ---- SECCIÓN DE PROMOCIONES ----
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 35.0),
//                 child: TitleWithCustomUnderline(text: 'Promociones'),
//               ),
//               const SizedBox(height: 15),

//               SizedBox(
//                 height: size.width * 0.55,
//                 child: PageView.builder(
//                   controller: _promoController,
//                   itemCount: promotions.length,
//                   itemBuilder: (context, index) {
//                     return Center(child: promotions[index]);
//                   },
//                 ),
//               ),
//               const SizedBox(height: 60),
//             ],
//           ),
//         ),

//         // ---- Burbuja flotante ----
//         const FloatingBubble(),
//       ],
//     );
//   }
// }
