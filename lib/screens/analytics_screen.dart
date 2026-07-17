import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _activeTab = 'Expenses'; // 'Expenses' or 'Income'

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    // Filter sum calculations
    double totalExpenses = finance.transactions
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    double totalIncome = finance.transactions
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final displayAmount = _activeTab == 'Expenses' ? totalExpenses : totalIncome;

    // Categories and sum data matching mockup
    final List<Map<String, dynamic>> mockReportItems = [
      {
        'name': 'Groceries',
        'amount': displayAmount * 0.31,
        'percent': 31.0,
        'color': MoniTheme.pastelBlue,
        'icon': Icons.local_grocery_store_rounded,
        'trend': '+12% vs last month',
      },
      {
        'name': 'Clothing & Shoes',
        'amount': displayAmount * 0.248,
        'percent': 24.8,
        'color': MoniTheme.pastelOrange,
        'icon': Icons.checkroom_rounded,
        'trend': '+6% vs last month',
      },
      {
        'name': 'Utilities & Rent',
        'amount': displayAmount * 0.202,
        'percent': 20.2,
        'color': MoniTheme.pastelPurple,
        'icon': Icons.flash_on_rounded,
        'trend': '-2% vs last month',
      },
      {
        'name': 'Others',
        'amount': displayAmount * 0.24,
        'percent': 24.0,
        'color': MoniTheme.pastelGreen,
        'icon': Icons.more_horiz_rounded,
        'trend': '+1% vs last month',
      },
    ];

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Report',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('November 2025', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MoniTheme.darkText)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pill Toggle Swticher
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'Expenses'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeTab == 'Expenses' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Expenses',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _activeTab == 'Expenses' ? MoniTheme.darkText : MoniTheme.mutedText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'Income'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeTab == 'Income' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _activeTab == 'Income' ? MoniTheme.darkText : MoniTheme.mutedText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Expenses Report Subheading + icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_activeTab Report',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bar_chart_rounded, size: 16, color: MoniTheme.mutedText),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: MoniTheme.sageGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.pie_chart_rounded, size: 16, color: MoniTheme.sageGreen),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Donut Chart Vector Display
              Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: ReportDonutPainter(
                      items: mockReportItems,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total $_activeTab', style: const TextStyle(fontSize: 11, color: MoniTheme.mutedText)),
                          const SizedBox(height: 4),
                          Text(
                            '$currencySymbol ${NumberFormat('#,##0.00').format(displayAmount)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Legend Title block
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All $_activeTab', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MoniTheme.mutedText)),
                  Text(
                    'Total $currencySymbol ${NumberFormat('#,##0.00').format(displayAmount)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: MoniTheme.darkText),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Legend Card lists
              ...mockReportItems.map((item) {
                final color = item['color'] as Color;
                final amount = item['amount'] as double;
                final percent = item['percent'] as double;
                final trend = item['trend'] as String;
                final icon = item['icon'] as IconData;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: MoniTheme.premiumCardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                Text('$percent% of total', style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$currencySymbol ${NumberFormat('#,##0.00').format(amount)}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trend,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: trend.startsWith('+') ? Colors.green : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress Line indicator
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportDonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;

  ReportDonutPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width / 2, size.height / 2);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double strokeWidth = radius * 0.28;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    double startAngle = -pi / 2;

    for (var item in items) {
      final double percent = (item['percent'] as double) / 100;
      final double sweepAngle = percent * 2 * pi;
      paint.color = item['color'] as Color;

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
