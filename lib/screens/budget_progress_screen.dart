import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';

class BudgetProgressScreen extends StatelessWidget {
  const BudgetProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day;

    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Budgets & Spending Limits', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Month remaining card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: MoniTheme.blackCardDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Days Remaining this Month',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$daysRemaining Days left',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.calendar_month, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active Budgets
            const Text(
              'Active Budgets',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),
            if (finance.budgets.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: MoniTheme.premiumCardDecoration,
                child: const Center(
                  child: Text('No budgets configured. Set one in Settings!'),
                ),
              )
            else
              ...finance.budgets.map((budget) {
                final spent = finance.transactions
                    .whereType<Transaction>()
                    .where((t) =>
                        t.type == 'expense' &&
                        t.category == budget.category &&
                        t.date.year == now.year &&
                        t.date.month == now.month)
                    .fold<double>(0.0, (sum, item) => sum + item.amount);

                final ratio = budget.limitAmount > 0 ? (spent / budget.limitAmount).clamp(0.0, 1.0) : 0.0;
                final percentageStr = (ratio * 100).toStringAsFixed(0);

                Color progressColor = Colors.green;
                if (ratio >= 1.0) {
                  progressColor = Colors.redAccent;
                } else if (ratio >= 0.8) {
                  progressColor = Colors.orangeAccent;
                }

                // Daily advice recommendation
                final dailyBudgetRemaining = (budget.limitAmount - spent) / (daysRemaining > 0 ? daysRemaining : 1);
                String tip = "You are spending at a healthy rate.";
                if (ratio >= 1.0) {
                  tip = "Budget Exceeded! Stop spending in ${budget.category}.";
                } else if (ratio >= 0.8) {
                  tip = "Limit spending to $currencySymbol ${NumberFormat('#,##0').format(dailyBudgetRemaining)} daily to stay under.";
                } else if (dailyBudgetRemaining > 0) {
                  tip = "Spend less than $currencySymbol ${NumberFormat('#,##0').format(dailyBudgetRemaining)} daily to stay under budget.";
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: MoniTheme.premiumCardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            budget.category,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            '$currencySymbol ${NumberFormat('#,##0').format(spent)} / ${NumberFormat('#,##0').format(budget.limitAmount)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 10,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: progressColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$percentageStr% Used',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: progressColor),
                          ),
                          Text(
                            ratio >= 1.0 ? 'Exceeded' : '$currencySymbol ${NumberFormat('#,##0').format(budget.limitAmount - spent)} Left',
                            style: TextStyle(fontSize: 12, color: ratio >= 0.8 ? progressColor : MoniTheme.mutedText),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 18, color: progressColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(fontSize: 12, color: ratio >= 0.8 ? progressColor : MoniTheme.mutedText, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
