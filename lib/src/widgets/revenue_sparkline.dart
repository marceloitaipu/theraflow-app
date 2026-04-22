import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/finance_service.dart';

/// Gráfico simples de receita mensal (sparkline + área).
/// Sem dependências externas — usa CustomPainter.
class RevenueSparkline extends StatelessWidget {
  final List<MonthlyRevenuePoint> points;
  final double height;

  const RevenueSparkline({
    super.key,
    required this.points,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency =
        NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$');

    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Sem dados de receita')),
      );
    }

    final lastValue = points.last.received;
    final firstValue = points.first.received;
    final delta = lastValue - firstValue;
    final pctDelta = firstValue > 0 ? (delta / firstValue * 100) : 0.0;
    final isUp = delta >= 0;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currency.format(lastValue),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isUp ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 2),
                Text(
                  '${pctDelta.abs().toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isUp ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'vs. ${points.length}m atrás',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: CustomPaint(
                size: Size.infinite,
                painter: _SparklinePainter(
                  points: points.map((p) => p.received).toList(),
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: points
                  .map((p) => Text(
                        _shortMonthLabel(p.month),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey[600], fontSize: 10),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _shortMonthLabel(int month) {
    const labels = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return labels[month - 1];
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final minV = points.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final dx = points.length > 1 ? size.width / (points.length - 1) : 0.0;

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final normalized = (points[i] - minV) / range;
      final y = size.height - (normalized * size.height * 0.85) - 4;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo((points.length - 1) * dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Pontos
    final dotPaint = Paint()..color = color;
    for (int i = 0; i < points.length; i++) {
      final x = i * dx;
      final normalized = (points[i] - minV) / range;
      final y = size.height - (normalized * size.height * 0.85) - 4;
      canvas.drawCircle(Offset(x, y), i == points.length - 1 ? 4 : 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) {
    return old.points != points || old.color != color;
  }
}
