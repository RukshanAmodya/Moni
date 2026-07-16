import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';
import 'transactions_screen.dart'; // to open the AddTransaction dialog
import 'wallet_details_screen.dart';
import 'budget_progress_screen.dart';
import '../widgets/category_pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _timeRange = 'Week'; // 'Week' or 'Month'
  int? _hoveredBarIndex;

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final warnings = finance.getBudgetWarnings();
    final currencySymbol = finance.currency;

    // Daily expenses calculation for current week
    final dailyExpenses = _calculateDailyExpenses(finance.transactions);
    final maxExpense = dailyExpenses.values.isEmpty
        ? 1.0
        : dailyExpenses.values.reduce((a, b) => a > b ? a : b);

    final double thisWeekTotal = dailyExpenses.values.fold(0.0, (a, b) => a + b);
    final double lastWeekTotal = finance.transactions
        .where((tx) {
          if (tx.type != 'expense') return false;
          final diff = DateTime.now().difference(tx.date).inDays;
          return diff >= 7 && diff < 14;
        })
        .fold(0.0, (sum, tx) => sum + tx.amount);

    double changePercent = 0.0;
    if (lastWeekTotal > 0) {
      changePercent = ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100;
    } else if (thisWeekTotal > 0) {
      changePercent = 100.0;
    }
    final bool isTrendUp = changePercent >= 0;

    final double savingsRate = finance.thisMonthIncome > 0
        ? ((finance.thisMonthIncome - finance.thisMonthExpense) / finance.thisMonthIncome) * 100
        : 0.0;

    final double lastMonthIncome = finance.transactions
        .where((tx) {
          if (tx.type != 'income') return false;
          final diff = DateTime.now().difference(tx.date).inDays;
          return diff >= 30 && diff < 60;
        })
        .fold(0.0, (sum, tx) => sum + tx.amount);

    double incomeChange = 0.0;
    if (lastMonthIncome > 0) {
      incomeChange = ((finance.thisMonthIncome - lastMonthIncome) / lastMonthIncome) * 100;
    } else if (finance.thisMonthIncome > 0) {
      incomeChange = 100.0;
    }

    final double lastMonthExpense = finance.transactions
        .where((tx) {
          if (tx.type != 'expense') return false;
          final diff = DateTime.now().difference(tx.date).inDays;
          return diff >= 30 && diff < 60;
        })
        .fold(0.0, (sum, tx) => sum + tx.amount);

    double expenseChange = 0.0;
    if (lastMonthExpense > 0) {
      expenseChange = ((finance.thisMonthExpense - lastMonthExpense) / lastMonthExpense) * 100;
    } else if (finance.thisMonthExpense > 0) {
      expenseChange = 100.0;
    }

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE5E7FD), // Soft lavender gradient
              MoniTheme.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.42],
          ),
        ),
        child: SafeArea(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONI',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: MoniTheme.blackAccent,
                            ),
                      ),
                      Text(
                        'Manage Your Money Smartly',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Notification bell with warnings indicator
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () => _showWarningsDialog(context, warnings),
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              size: 28,
                              color: MoniTheme.darkText,
                            ),
                          ),
                          if (warnings.isNotEmpty)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${warnings.length}',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: MoniTheme.sageGreenLight,
                        child: Icon(Icons.person, color: MoniTheme.darkText),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Time Range Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      borderRadius: BorderRadius.circular(16),
                      value: _timeRange,
                      items: ['Week', 'Month']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _timeRange = val;
                          });
                        }
                      },
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2x2 Grid of Metrics (Screen 2 Clone)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
                children: [
                  _buildMetricCard(
                    context,
                    title: 'Total Balance',
                    value: finance.incognitoEnabled ? '••••' : '$currencySymbol ${NumberFormat('#,##0').format(finance.totalBalance)}',
                    percentage: '${savingsRate.toStringAsFixed(1)}% Saved',
                    icon: Icons.account_balance_wallet_outlined,
                    iconBgColor: MoniTheme.sageGreenLight,
                    iconColor: MoniTheme.sageGreen,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletDetailsScreen())),
                  ),
                  _buildMetricCard(
                    context,
                    title: "Month's Income",
                    value: finance.incognitoEnabled ? '••••' : '$currencySymbol ${NumberFormat('#,##0').format(finance.thisMonthIncome)}',
                    percentage: '${incomeChange >= 0 ? '+' : ''}${incomeChange.toStringAsFixed(1)}% MoM',
                    icon: Icons.trending_up_rounded,
                    iconBgColor: const Color(0xFFE3EDF7),
                    iconColor: Colors.blueAccent,
                  ),
                  _buildMetricCard(
                    context,
                    title: "Month's Expense",
                    value: finance.incognitoEnabled ? '••••' : '$currencySymbol ${NumberFormat('#,##0').format(finance.thisMonthExpense)}',
                    percentage: '${expenseChange >= 0 ? '+' : ''}${expenseChange.toStringAsFixed(1)}% MoM',
                    icon: Icons.trending_down_rounded,
                    iconBgColor: const Color(0xFFFBEBEB),
                    iconColor: Colors.redAccent,
                  ),
                  _buildMetricCard(
                    context,
                    title: 'Active Goals',
                    value: '${finance.goals.length} Goals',
                    percentage: 'Progress',
                    icon: Icons.track_changes_rounded,
                    iconBgColor: const Color(0xFFF5EBFB),
                    iconColor: Colors.purpleAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetProgressScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bar Chart - Daily Expense Trend
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
                              'Daily Expense Trend',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Current Week Breakdown',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isTrendUp
                                ? Colors.redAccent.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isTrendUp ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isTrendUp ? Colors.redAccent : Colors.green,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${changePercent.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: isTrendUp ? Colors.redAccent : Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Beautiful custom bar chart
                    SizedBox(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final day = days[index];
                          final amount = dailyExpenses[day] ?? 0.0;
                          final heightRatio = amount / maxExpense;
                          final barHeight = 100 * (heightRatio > 0.05 ? heightRatio : 0.05);

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
                                if (isHovered && amount > 0)
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
                                  width: 22,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    color: isHovered ? MoniTheme.blackAccent : MoniTheme.sageGreen,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  day[0],
                                  style: TextStyle(
                                    fontSize: 12,
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
              const SizedBox(height: 24),

              // Virtual Piggy Bank Widget
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MoniTheme.sageGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: MoniTheme.sageGreen,
                      child: const Icon(Icons.savings_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Virtual Piggy Bank',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            finance.incognitoEnabled ? '••••' : '$currencySymbol ${NumberFormat('#,##0.00').format(finance.piggyBankBalance)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: MoniTheme.sageGreen),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Spare change rounded up automatically!',
                            style: TextStyle(fontSize: 11, color: MoniTheme.mutedText),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MoniTheme.blackAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () => _showAddPiggyBankDialog(context, finance),
                          child: const Text('Add LKR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            if (finance.piggyBankBalance > 0) {
                              finance.clearPiggyBank();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Piggy Bank funds returned to Cash wallet!')),
                              );
                            }
                          },
                          child: const Text('Cash Out', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              CategoryPieChart(
                transactions: finance.transactions,
                currency: currencySymbol,
              ),

              const SizedBox(height: 24),

              // Savings Goals Progress (Section 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Savings Goals',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => _showAddGoalDialog(context),
                    child: const Text('Add Goal', style: TextStyle(color: MoniTheme.sageGreen)),
                  ),
                ],
              ),
              if (finance.goals.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: MoniTheme.premiumCardDecoration,
                  child: const Center(
                    child: Text('No active savings goals. Add one above!'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: finance.goals.length,
                  itemBuilder: (context, index) {
                    final goal = finance.goals[index];
                    final progress = goal.targetAmount > 0
                        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
                        : 0.0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: MoniTheme.premiumCardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$currencySymbol ${NumberFormat('#,##0').format(goal.currentAmount)} / ${NumberFormat('#,##0').format(goal.targetAmount)}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.add_circle_outline, color: MoniTheme.sageGreen, size: 20),
                                    onPressed: () => _showContributeGoalDialog(context, goal),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => finance.deleteGoal(goal.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: MoniTheme.sageGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% Completed',
                            style: const TextStyle(fontSize: 11, color: MoniTheme.mutedText),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String percentage,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: MoniTheme.premiumCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: percentage.startsWith('-') ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MoniTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: MoniTheme.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateDailyExpenses(List<Transaction> txs) {
    final map = {'Mon': 0.0, 'Tue': 0.0, 'Wed': 0.0, 'Thu': 0.0, 'Fri': 0.0, 'Sat': 0.0, 'Sun': 0.0};
    final now = DateTime.now();
    // Start of current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    for (var tx in txs) {
      if (tx.type == 'expense' && tx.date.isAfter(startDay.subtract(const Duration(seconds: 1)))) {
        final dayStr = DateFormat('E').format(tx.date); // e.g. Mon, Tue
        if (map.containsKey(dayStr)) {
          map[dayStr] = (map[dayStr] ?? 0.0) + tx.amount;
        }
      }
    }
    return map;
  }

  void _showWarningsDialog(BuildContext context, List<String> warnings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Budget Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: warnings.isEmpty
              ? [const Text('No budget warnings. Great job spending smartly!')]
              : warnings.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                        const SizedBox(width: 8),
                        Expanded(child: Text(w)),
                      ],
                    ),
                  )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: MoniTheme.sageGreen)),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Goal Name (e.g., Buy Laptop)'),
            ),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = titleController.text.trim();
              final target = double.tryParse(targetController.text) ?? 0.0;
              if (name.isNotEmpty && target > 0) {
                Provider.of<FinanceProvider>(context, listen: false).addGoal(
                  SavingsGoal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    targetAmount: target,
                    currentAmount: 0.0,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: MoniTheme.sageGreen)),
          ),
        ],
      ),
    );
  }

  void _showContributeGoalDialog(BuildContext context, SavingsGoal goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contribute to ${goal.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount to add'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                Provider.of<FinanceProvider>(context, listen: false).updateGoalProgress(goal.id, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: MoniTheme.sageGreen)),
          ),
        ],
      ),
    );
  }

  void _showAddPiggyBankDialog(BuildContext context, FinanceProvider finance) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add to Piggy Bank', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (LKR)',
            hintText: 'Enter amount to transfer from Cash',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MoniTheme.blackAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                finance.addToPiggyBank(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Cash'),
          ),
        ],
      ),
    );
  }
}
