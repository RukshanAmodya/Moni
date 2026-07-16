import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import '../theme/moni_theme.dart';

class CategoryPieChart extends StatelessWidget {
  final List<Transaction> transactions;
  final String currency;

  const CategoryPieChart({
    super.key,
    required this.transactions,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Group expense transactions by category
    final Map<String, double> categorySums = {};
    double totalExpense = 0.0;

    for (var tx in transactions) {
      if (tx.type == 'expense') {
        categorySums[tx.category] = (categorySums[tx.category] ?? 0.0) + tx.amount;
        totalExpense += tx.amount;
      }
    }

    if (totalExpense == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: MoniTheme.premiumCardDecoration,
        child: const Column(
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 48, color: MoniTheme.mutedText),
            SizedBox(height: 12),
            Text(
              'No expense logs yet this month.',
              style: TextStyle(color: MoniTheme.mutedText, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // Map categories to premium preset colors
    final List<Color> colors = [
      MoniTheme.sageGreen,
      MoniTheme.pastelBlue,
      MoniTheme.pastelOrange,
      MoniTheme.pastelPurple,
      MoniTheme.pastelPink,
      MoniTheme.pastelGreen,
    ];

    final List<PieChartSegment> segments = [];
    int colorIdx = 0;

    categorySums.forEach((category, sum) {
      segments.add(
        PieChartSegment(
          category: category,
          amount: sum,
          percentage: sum / totalExpense,
          color: colors[colorIdx % colors.length],
        ),
      );
      colorIdx++;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: MoniTheme.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Beautiful Custom Painter Pie Chart
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: DonutChartPainter(segments: segments),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Spent', style: TextStyle(fontSize: 10, color: MoniTheme.mutedText)),
                        Text(
                          '$currency\n${NumberFormat.compact().format(totalExpense)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: MoniTheme.darkText, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legends
              Expanded(
                child: Column(
                  children: segments.map((seg) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: seg.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              seg.category,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: MoniTheme.darkText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${(seg.percentage * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PieChartSegment {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  PieChartSegment({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class DonutChartPainter extends CustomPainter {
  final List<PieChartSegment> segments;

  DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width / 2, size.height / 2);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double strokeWidth = radius * 0.35;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    double startAngle = -pi / 2;

    for (var seg in segments) {
      final double sweepAngle = seg.percentage * 2 * pi;
      paint.color = seg.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
