import 'package:flutter/material.dart';
import 'package:prototipo1_app/presentation/client/Components/tratamientos_modal.dart';
import 'package:prototipo1_app/presentation/employee/dto/tratamiento_model.dart';

class CategoryCard extends StatefulWidget {
  final String title;
  final String? imageUrl;
  final List<Tratamiento> tratamientos;

  const CategoryCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.tratamientos,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _toggleModal() {
    setState(() {
      isOpen = !isOpen;
      isOpen ? _controller.forward() : _controller.reverse();
    });

    if (isOpen) {
      _showTratamientosModal();
    }
  }

  void _showTratamientosModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TratamientosModal(
        tratamientos: widget.tratamientos,
      ),
    ).whenComplete(() {
      setState(() {
        isOpen = false;
        _controller.reverse();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [

            Positioned.fill(
              child: widget.imageUrl != null
                  ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                  : Container(color: primaryColor),
            ),

            Positioned(
              bottom: 75,
              left: 16,
              right: 16,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(offset: Offset(-2, -2), color: Colors.white),
                    Shadow(offset: Offset(2, -2), color: Colors.white),
                    Shadow(offset: Offset(2, 2), color: Colors.white),
                    Shadow(offset: Offset(-2, 2), color: Colors.white),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleModal,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5)
                          .animate(_controller),
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
