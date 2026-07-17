import 'dart:math';
import 'package:flutter/material.dart';
import 'navigation_holder.dart';
import 'budget_progress_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  void _showAddBudgetOrGoalDialog(BuildContext context, FinanceProvider finance) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add New Limit or Goal',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: MoniTheme.pastelPurple.withOpacity(0.12),
                child: const Icon(Icons.pie_chart_rounded, color: MoniTheme.pastelPurple),
              ),
              title: const Text('Add Category Budget Limit', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Restrict monthly category expenditures'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddBudgetDialog(context, finance);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: MoniTheme.pastelOrange.withOpacity(0.12),
                child: const Icon(Icons.savings_rounded, color: MoniTheme.pastelOrange),
              ),
              title: const Text('Add Savings Goal', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Save up for a major purchase or target'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddGoalDialog(context, finance);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, FinanceProvider finance) {
    final catController = TextEditingController();
    final amtController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Budget Limit', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amtController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Limit Amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MoniTheme.blackAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final cat = catController.text.trim();
              final limit = double.tryParse(amtController.text) ?? 0.0;
              if (cat.isNotEmpty && limit > 0) {
                finance.setBudget(cat, limit);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget limit for $cat set to $limit!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, FinanceProvider finance) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Savings Goal', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Goal Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: currentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Starting Balance',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MoniTheme.blackAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              final target = double.tryParse(targetController.text) ?? 0.0;
              final current = double.tryParse(currentController.text) ?? 0.0;
              if (name.isNotEmpty && target > 0) {
                finance.addGoal(SavingsGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  targetAmount: target,
                  currentAmount: current,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Goal "$name" added successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
        return MoniTheme.pastelBlue;
      case 'transport':
      case 'car':
        return MoniTheme.pastelOrange;
      case 'bills':
      case 'utilities':
        return MoniTheme.pastelPurple;
      case 'shopping':
        return MoniTheme.pastelGreen;
      default:
        return MoniTheme.pastelPink;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
        return Icons.local_grocery_store_rounded;
      case 'transport':
      case 'car':
        return Icons.directions_car_filled_rounded;
      case 'bills':
      case 'utilities':
        return Icons.flash_on_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    // Build real budgets based on actual entries
    final List<Map<String, dynamic>> activeBudgets = [];
    final now = DateTime.now();

    for (var budget in finance.budgets) {
      final spent = finance.transactions
          .where((t) =>
              t.type == 'expense' &&
              t.category == budget.category &&
              t.date.year == now.year &&
              t.date.month == now.month)
          .fold(0.0, (sum, item) => sum + item.amount);

      final double percent = budget.limitAmount > 0 ? (spent / budget.limitAmount) * 100 : 0.0;

      activeBudgets.add({
        'name': '${budget.category} Budget',
        'target': budget.limitAmount,
        'current': spent,
        'percent': percent.clamp(0.0, 100.0).round(),
        'color': _getCategoryColor(budget.category),
        'icon': _getCategoryIcon(budget.category),
      });
    }

    final activeGoals = finance.goals;

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
                        onPressed: () {
                          context.findAncestorStateOfType<NavigationHolderState>()?.setIndex(0);
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'My Plan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAddBudgetOrGoalDialog(context, finance),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                            ],
                          ),
                          child: const Icon(Icons.add, size: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BudgetProgressScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                            ],
                          ),
                          child: const Icon(Icons.north_east_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Goals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Goals', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Goals Section
              if (activeGoals.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: MoniTheme.premiumCardDecoration,
                  alignment: Alignment.center,
                  child: const Text('No savings goals registered yet.', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                )
              else
                ...activeGoals.map((goal) {
                  final double percent = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) : 0.0;
                  final double left = max(0.0, goal.targetAmount - goal.currentAmount);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
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
                                color: MoniTheme.pastelOrange.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.home_work_rounded, color: MoniTheme.pastelOrange, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(goal.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                  const Text('Target Progress', style: TextStyle(color: MoniTheme.mutedText, fontSize: 11)),
                                ],
                              ),
                            ),
                            const Icon(Icons.more_vert_rounded, color: MoniTheme.mutedText),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: MoniTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900),
                                children: [
                                  TextSpan(text: '$currencySymbol ${NumberFormat('#,##0.00').format(goal.currentAmount)} '),
                                  TextSpan(
                                    text: 'Out of $currencySymbol ${NumberFormat('#,##0.00').format(goal.targetAmount)}',
                                    style: const TextStyle(color: MoniTheme.mutedText, fontSize: 12, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percent.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(MoniTheme.pastelOrange),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Your Progress', style: TextStyle(color: MoniTheme.mutedText, fontSize: 11)),
                            Text('$currencySymbol ${left.toStringAsFixed(0)} Left', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: MoniTheme.pastelOrange)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),

              const SizedBox(height: 24),

              // Budgets Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Budgets', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Budgets List
              if (activeBudgets.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: MoniTheme.premiumCardDecoration,
                  alignment: Alignment.center,
                  child: const Text('No category budgets defined yet.', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                )
              else
                ...activeBudgets.map((b) {
                  final target = b['target'] as double;
                  final current = b['current'] as double;
                  final percent = b['percent'] as int;
                  final color = b['color'] as Color;
                  final icon = b['icon'] as IconData;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BudgetProgressScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: MoniTheme.premiumCardDecoration,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b['name'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  '$currencySymbol ${current.toStringAsFixed(0)} of $currencySymbol ${target.toStringAsFixed(0)}',
                                  style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$percent%',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded, color: MoniTheme.mutedText),
                        ],
                      ),
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
