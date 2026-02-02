import 'package:flutter/material.dart';

class MonthlyBarChart extends StatelessWidget {
  final Map<String, double> data; // "1".."31"
  final Color barColor;

  const MonthlyBarChart({
    super.key,
    required this.data,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;

        final double barWidth = isTablet ? 18 : 12;
        final double spacing = isTablet ? 14 : 10;
        final double chartHeight = isTablet ? 300 : 230;
        final double labelFontSize = isTablet ? 11 : 9;

        final totalBars = data.length;
        final totalWidth =
            totalBars * (barWidth + spacing) + 20;

        return SizedBox(
          height: chartHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth < constraints.maxWidth
                  ? constraints.maxWidth
                  : totalWidth,
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: Size(
                        totalWidth < constraints.maxWidth
                            ? constraints.maxWidth
                            : totalWidth,
                        chartHeight,
                      ),
                      painter: _MonthlyBarChartPainter(
                        data: data,
                        barColor: barColor,
                        isTablet: isTablet,
                        barWidth: barWidth,
                        spacing: spacing,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Labels: TODOS los días, pero solo mostramos texto cada 5
                  Row(
                    children: data.keys.map((d) {
                      final day = int.tryParse(d) ?? 0;
                      final show = day == 1 || day % 5 == 0;

                      return SizedBox(
                        width: barWidth + spacing,
                        child: Text(
                          show ? d : "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: labelFontSize,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class _MonthlyBarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Color barColor;
  final bool isTablet;
  final double barWidth;
  final double spacing;

  _MonthlyBarChartPainter({
    required this.data,
    required this.barColor,
    required this.isTablet,
    required this.barWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = data.values.isEmpty
        ? 1
        : data.values.reduce((a, b) => a > b ? a : b);

    const double topPadding = 20;
    const double bottomPadding = 24;
    const double leftPadding = 12;

    final usableHeight =
        size.height - topPadding - bottomPadding;

    final paint = Paint()..style = PaintingStyle.fill;

    int i = 0;
    for (final entry in data.entries) {
      final value = entry.value;

      final double x =
          leftPadding + i * (barWidth + spacing);

      final double barHeight = maxValue == 0
          ? 0
          : (value / maxValue) * (usableHeight - 16);

      final rect = Rect.fromLTWH(
        x,
        topPadding + (usableHeight - barHeight),
        barWidth,
        barHeight,
      );

      paint.color =
          value > 0 ? barColor : barColor.withOpacity(0.15);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        paint,
      );

      // Valor encima
      if (value > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: value.toInt().toString(),
            style: TextStyle(
              color: barColor,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 12 : 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            x + barWidth / 2 - textPainter.width / 2,
            topPadding + (usableHeight - barHeight) - 16,
          ),
        );
      }

      i++;
    }

    // Línea base
    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = isTablet ? 1.4 : 1;

    canvas.drawLine(
      Offset(leftPadding, topPadding + usableHeight),
      Offset(size.width, topPadding + usableHeight),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MonthlyBarChartPainter old) {
    return old.data != data ||
        old.barColor != barColor ||
        old.isTablet != isTablet ||
        old.barWidth != barWidth ||
        old.spacing != spacing;
  }
}
