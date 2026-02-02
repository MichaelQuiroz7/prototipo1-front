import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prototipo1_app/config/promociones/dto/promocion.dto.dart';
import 'package:prototipo1_app/config/promociones/promotions_services.dart';
import 'package:prototipo1_app/presentation/client/Components/promocion_modal.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

class TratamientosModal extends StatelessWidget {
  final List<Tratamiento> tratamientos;

  const TratamientosModal({super.key, required this.tratamientos});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 26,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tratamientos.length,
                  itemBuilder: (_, index) {
                    return _CouponCard(tratamiento: tratamientos[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CouponCard extends StatefulWidget {
  final Tratamiento tratamiento;

  const _CouponCard({required this.tratamiento});

  @override
  State<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends State<_CouponCard> {
  final PromocionesService _promoService = PromocionesService();

  Promocion? promocion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromocion();
  }

  Future<void> _loadPromocion() async {
    setState(() {
      isLoading = true;
    });

    final promociones = await _promoService.obtenerPromociones();

    final encontrada = promociones
        .where((p) => p.idTratamiento == widget.tratamiento.idTratamiento)
        .toList();

    setState(() {
      promocion = encontrada.isNotEmpty ? encontrada.first : null;
      isLoading = false;
    });
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
          color: Colors.white,
        ),
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['ENDPOINT_API6'] ?? '';

    final imageUrl =
        (widget.tratamiento.imagen != null &&
            widget.tratamiento.imagen!.isNotEmpty)
        ? "$baseUrl${widget.tratamiento.imagen}"
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// ===== CUPÓN ORIGINAL (NO MODIFICADO) =====
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE3F6FF), Color(0xFF7CCFFF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                /// IMAGEN
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 95,
                      height: 95,
                      child: imageUrl != null
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Container(color: Colors.white),
                    ),
                  ),
                ),

                /// Línea punteada
                SizedBox(
                  height: 90,
                  child: CustomPaint(painter: _DashedLinePainter()),
                ),

                const SizedBox(width: 16),

                /// CONTENIDO DINÁMICO
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tratamiento.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),

                        /// SI NO TIENE PROMOCIÓN
                        if (promocion == null) ...[
                          const Text(
                            "Sin promoción",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "\$/ ${widget.tratamiento.precio}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ]
                        /// SI TIENE PROMOCIÓN
                        else ...[
                          Text(
                            "Antes: \$/ ${promocion!.precioAntes}",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Promoción: \$/ ${promocion!.precioAhora}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "2 x 1: ${promocion!.es2x1 ? "Sí" : "No"}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                /// BOTÓN DINÁMICO
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: isLoading
                      ? const SizedBox(
                          width: 42,
                          height: 42,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : promocion == null
                      ? _buildButton(Icons.add, () {
                          _abrirModalPromocion();
                        })
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildButton(Icons.delete, () async {
                              await _promoService.eliminarPromocion(
                                promocion!.idPromocion!,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Promoción eliminada correctamente",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              await _loadPromocion(); 
                            }),
                          ],
                        ),
                ),
              ],
            ),
          ),

          Positioned(top: -12, left: 110, child: _cutCircle()),
          Positioned(bottom: -12, left: 110, child: _cutCircle()),
        ],
      ),
    );
  }

  Widget _cutCircle() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  void _abrirModalPromocion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromocionModal(
        tratamiento: widget.tratamiento,
        onSuccess: () {
          _loadPromocion();
        },
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 6;
    const dashSpace = 4;
    double startY = 0;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
