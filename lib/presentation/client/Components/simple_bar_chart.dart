import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final Map<String, double> data;
  final Color barColor;

  const SimpleBarChart({
    super.key,
    required this.data,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;

        final double chartHeight = isTablet ? 280 : 200;
        final double labelFontSize = isTablet ? 13 : 11;
        final double verticalSpacing = isTablet ? 12 : 8;

        return SizedBox(
          height: chartHeight,
          child: Column(
            children: [
              // Área del gráfico
              Expanded(
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _BarChartPainter(
                    data: data,
                    barColor: barColor,
                    isTablet: isTablet,
                  ),
                ),
              ),

              SizedBox(height: verticalSpacing),

              // Etiquetas (NO se cortan)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data.keys.map((m) {
                  return SizedBox(
                    width: constraints.maxWidth / data.length,
                    child: Text(
                      m,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
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
        );
      },
    );
  }
}


class _BarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Color barColor;
  final bool isTablet;

  _BarChartPainter({
    required this.data,
    required this.barColor,
    required this.isTablet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = data.values.isEmpty
        ? 1
        : data.values.reduce((a, b) => a > b ? a : b);

    final double leftPadding = isTablet ? 24 : 12;
    final double bottomPadding = isTablet ? 24 : 14;
    final double topPadding = isTablet ? 18 : 12;

    final double usableWidth = size.width - leftPadding;
    final double usableHeight =
        size.height - bottomPadding - topPadding;

    final double barSpacing = usableWidth / data.length;
    final double barWidth = barSpacing * (isTablet ? 0.55 : 0.6);

    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: barColor,
      fontSize: isTablet ? 12 : 10,
      fontWeight: FontWeight.bold,
    );

    int i = 0;
    for (final value in data.values) {
      final double x =
          leftPadding + i * barSpacing + (barSpacing - barWidth) / 2;

      final double barHeight = maxValue == 0
          ? 0.0
          : (value / maxValue) * (usableHeight - 8);

      final double y = topPadding + usableHeight - barHeight;

      final rect = Rect.fromLTWH(
        x,
        y,
        barWidth,
        barHeight,
      );

      // 🔹 Barra
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(10)),
        paint,
      );

      // 🔹 Texto encima
      if (value > 0) {
        final textSpan = TextSpan(
          text: value.toInt().toString(),
          style: textStyle,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(minWidth: barWidth);

        final textX = x + (barWidth - textPainter.width) / 2;
        final textY = y - textPainter.height - 4;

        textPainter.paint(canvas, Offset(textX, textY));
      }

      i++;
    }

    // 🔹 Línea base
    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = isTablet ? 1.5 : 1;

    canvas.drawLine(
      Offset(leftPadding, topPadding + usableHeight),
      Offset(size.width, topPadding + usableHeight),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) {
    return old.data != data ||
        old.barColor != barColor ||
        old.isTablet != isTablet;
  }
}
