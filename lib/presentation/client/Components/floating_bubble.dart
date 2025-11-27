import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FloatingBubble extends StatefulWidget {
  const FloatingBubble({super.key});

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble>
    with TickerProviderStateMixin {
  Offset position = Offset.zero;
  late AnimationController entryController;
  late AnimationController tapController;
  late Animation<double> scaleAnimation;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    scaleAnimation = CurvedAnimation(
      parent: tapController,
      curve: Curves.easeOut,
    );

    tapController.value = 1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        position = Offset(screenSize.width - 100, screenSize.height - 265);
        isReady = true;
      });
      entryController.forward();
    });
  }

  @override
  void dispose() {
    entryController.dispose();
    tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) return const SizedBox(); 

    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  position += details.delta;
                });
              },
              onTapDown: (_) => tapController.reverse(),
              onTapUp: (_) {
                tapController.forward();
                context.push('/history-chat');
              },
              child: FadeTransition(
                opacity: entryController,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    width: 85, 
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE0F7FA),
                          Color(0xFFB2EBF2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(4, 6),
                        ),
                        const BoxShadow(
                          color: Colors.white24,
                          blurRadius: 8,
                          offset: Offset(-4, -4),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/dentista.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
