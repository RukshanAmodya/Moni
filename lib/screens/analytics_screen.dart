import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeRange = 'Week';
  int? _hoveredBarIndex;

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    // Calculate category breakdown percentages for current month
    final expenseMap = _calculateCategoryExpenses(finance.transactions);
    final double totalExpenses = expenseMap.values.fold(0.0, (sum, val) => sum + val);

    // Calculate monthly savings trend (last 6 months)
    final savingsTrend = _calculateSavingsTrend(finance.transactions);
    final maxSavings = savingsTrend.values.isEmpty
        ? 1.0
        : savingsTrend.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Screen Header (similar to Screen 3: "Active Users Detail")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expense Breakdown',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Pie Chart container (Screen 3 Adaption)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Category Distribution',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _timeRange,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Pie Chart
                    totalExpenses == 0
                        ? const SizedBox(
                            height: 180,
                            child: Center(child: Text('No expenses recorded for this month')),
                          )
                        : SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 50,
                                sections: _buildPieChartSections(expenseMap, totalExpenses),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    // Legend / Breakdown labels
                    _buildLegend(expenseMap, totalExpenses),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Monthly Savings Trend Container (Screen 3 Adaptation: "User Activity Trend")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Savings Trend',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Income vs Expense gap',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Text(
                          '6 Months',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Savings Trend Custom Bar Chart
                    SizedBox(
                      height: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(savingsTrend.length, (index) {
                          final key = savingsTrend.keys.elementAt(index);
                          final amount = savingsTrend[key] ?? 0.0;
                          final displayAmount = amount < 0 ? 0.0 : amount;
                          final heightRatio = displayAmount / (maxSavings > 0 ? maxSavings : 1.0);
                          final barHeight = 110 * (heightRatio > 0.05 ? heightRatio : 0.05);

                          final isHovered = _hoveredBarIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _hoveredBarIndex = isHovered ? null : index;
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isHovered && amount != 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: MoniTheme.blackAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${NumberFormat.compact().format(amount)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 26,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    color: isHovered ? MoniTheme.blackAccent : MoniTheme.sageGreen,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  key,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isHovered ? MoniTheme.blackAccent : MoniTheme.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryExpenses(List<Transaction> txs) {
    final map = <String, double>{};
    final now = DateTime.now();
    for (var tx in txs) {
      if (tx.type == 'expense' && tx.date.year == now.year && tx.date.month == now.month) {
        map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  Map<String, double> _calculateSavingsTrend(List<Transaction> txs) {
    final map = <String, double>{};
    final now = DateTime.now();

    // Last 6 months in chronological order
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMM').format(date);

      double income = 0.0;
      double expense = 0.0;

      for (var tx in txs) {
        if (tx.date.year == date.year && tx.date.month == date.month) {
          if (tx.type == 'income') {
            income += tx.amount;
          } else {
            expense += tx.amount;
          }
        }
      }
      map[monthName] = income - expense;
    }
    return map;
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data, double total) {
    int index = 0;
    final colors = [
      MoniTheme.sageGreen,
      MoniTheme.pastelBlue,
      MoniTheme.pastelPink,
      MoniTheme.pastelPurple,
      MoniTheme.pastelOrange,
    ];

    return data.entries.map((e) {
      final percentage = (e.value / total) * 100;
      final color = colors[index % colors.length];
      index++;

      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> data, double total) {
    int index = 0;
    final colors = [
      MoniTheme.sageGreen,
      MoniTheme.pastelBlue,
      MoniTheme.pastelPink,
      MoniTheme.pastelPurple,
      MoniTheme.pastelOrange,
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: data.entries.map((e) {
        final color = colors[index % colors.length];
        index++;
        final percentage = (e.value / total) * 100;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '${e.key} (${percentage.toStringAsFixed(0)}%)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        );
      }).toList(),
    );
  }
}
