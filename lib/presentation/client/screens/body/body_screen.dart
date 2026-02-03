import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

import '../../Components/title_with_more_btn.dart';
// 👇 Si tu proyecto no lo trae por PromotionItems, importa esto:
// import 'package:prototipo1_app/presentation/client/Components/recomend_promotion.dart';

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

  Timer? _timer;
  int _currentPage = 0;

  List<Especialidad> _especialidades = [];
  Map<int, List<Tratamiento>> _tratamientosPorEspecialidad = {};

  bool _loading = true;
  String _query = '';

  final String baseUrl = dotenv.env['ENDPOINT_API6'] ?? '';


  List<RecomendPromotion> _promotions = []; // si tu tipo es RecomendPromotion, cámbialo a List<RecomendPromotion>
  // bool _loadingPromos = true; // si quieres loader, pero NO lo agrego para no cambiar diseño

  // ======================================================
  // INIT
  // ======================================================
  @override
  void initState() {
    super.initState();
    _loadDatos();
    _loadPromotions(); // ✅ NUEVO

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_promoController.hasClients && _promotions.isNotEmpty) {
        // ✅ FIX: ya no es % 3, es % cantidad real
        _currentPage = (_currentPage + 1) % _promotions.length;
        _promoController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _mostrarRecomendacionBucal();
    });
  }

  // ======================================================
  // ✅ NUEVO: cargar promociones desde servicio
  // ======================================================
  Future<void> _loadPromotions() async {
    try {
      final promos = await PromotionItems(context: context).getPromotions();
      if (!mounted) return;
      setState(() {
        _promotions = promos;
        // _loadingPromos = false;
      });
    } catch (e) {
      debugPrint('Error cargando promociones: $e');
      if (!mounted) return;
      setState(() {
        _promotions = [];
        // _loadingPromos = false;
      });
    }
  }

  // ======================================================
  // CARGA DE DATOS (SIN NUEVOS ENDPOINTS)
  // ======================================================
  Future<void> _loadDatos() async {
    try {
      final especialidades = await _service.getAllEspecialidades();
      final tratamientos = await _service.getAllTratamientos();

      final Map<int, List<Tratamiento>> agrupados = {};

      for (final t in tratamientos) {
        agrupados.putIfAbsent(t.idEspecialidad, () => []);
        agrupados[t.idEspecialidad]!.add(t);
      }

      setState(() {
        _especialidades = especialidades;
        _tratamientosPorEspecialidad = agrupados;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error cargando datos: $e');
      setState(() => _loading = false);
    }
  }

  // ======================================================
  // FILTRO INTELIGENTE
  // ======================================================
  List<Especialidad> _especialidadesFiltradas() {
    if (_query.isEmpty) return _especialidades;

    return _especialidades.where((esp) {
      final matchEspecialidad = esp.nombre.toLowerCase().contains(_query);

      final tratamientos =
          _tratamientosPorEspecialidad[esp.idEspecialidad] ?? [];

      final matchTratamiento = tratamientos.any(
        (t) => t.nombre.toLowerCase().contains(_query),
      );

      return matchEspecialidad || matchTratamiento;
    }).toList();
  }

  // ======================================================
  // RECOMENDACIÓN BUCAL
  // ======================================================
  Future<void> _mostrarRecomendacionBucal() async {
    final cliente = SessionApp.usuarioActual;
    if (cliente == null) return;
    await OdontogramaPlanHelper.mostrarPlanDeCuidado(context, ref);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _promoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final promotions = _promotions;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWithSearchBox(
                size: size,
                searchController: _searchController,
                onChanged: (value) {
                  setState(() => _query = value.toLowerCase());
                },
              ),

              const SizedBox(height: 15),

              TitleWithMoreBtn(text: 'Servicios Disponibles', press: () {}),

              _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _especialidadesFiltradas().map((esp) {
                          final imageUrl = esp.imagen != null
                              ? '$baseUrl${esp.imagen}'
                              : 'assets/images/default_especialidad.png';

                          final tratamientos =
                              _tratamientosPorEspecialidad[esp.idEspecialidad] ??
                                  [];

                          final tratamientosFiltrados = _query.isEmpty
                              ? []
                              : tratamientos
                                  .where(
                                    (t) => t.nombre.toLowerCase().contains(_query),
                                  )
                                  .toList();

                          return Container(
                            margin: const EdgeInsets.only(left: 16),
                            width: 260,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RecomendPlanCard(
                                  image: imageUrl,
                                  title: esp.nombre,
                                  subTitle: esp.descripcion ?? 'Especialidad disponible',
                                  price: 0.0,
                                  press: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailsScreen(
                                          idEspecialidad: esp.idEspecialidad,
                                          nombreEspecialidad: esp.nombre,
                                          imagenEspecialidad: esp.imagen ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                if (tratamientosFiltrados.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: tratamientosFiltrados.map((t) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.arrow_right,
                                                size: 18,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  t.nombre,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: TitleWithCustomUnderline(text: 'Promociones'),
              ),

              const SizedBox(height: 15),

              LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;

                  final promoHeight = (screenHeight * 0.28).clamp(
                    180.0,
                    280.0,
                  ); // móvil ↔ tablet balanceado

                  return SizedBox(
                    height: promoHeight,
                    child: PageView.builder(
                      controller: _promoController,
                      itemCount: promotions.length,
                      itemBuilder: (_, i) => Center(child: promotions[i]),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),

        const FloatingBubble(),
      ],
    );
  }
}
