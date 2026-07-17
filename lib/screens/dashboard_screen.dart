import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';
import 'wallet_details_screen.dart';
import '../widgets/currency_selector_sheet.dart';
import 'navigation_holder.dart';
import 'reports_export_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedMonth = DateTime.now();

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Period Month',
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    final selectedMonthTxs = finance.transactions.where((tx) {
      return tx.date.year == _selectedMonth.year && tx.date.month == _selectedMonth.month;
    }).toList();

    // Filter sum calculations
    double totalExpenses = selectedMonthTxs
        .where((tx) => tx.type == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    double totalIncome = selectedMonthTxs
        .where((tx) => tx.type == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    // Calculate weekly trend dynamically
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    double thisWeekNet = finance.transactions
        .where((tx) => tx.date.isAfter(thisWeekStart))
        .fold(0.0, (sum, tx) => sum + (tx.type == 'income' ? tx.amount : -tx.amount));

    double lastWeekNet = finance.transactions
        .where((tx) => tx.date.isAfter(lastWeekStart) && tx.date.isBefore(thisWeekStart))
        .fold(0.0, (sum, tx) => sum + (tx.type == 'income' ? tx.amount : -tx.amount));

    double weeklyDiff = thisWeekNet - lastWeekNet;
    String trendSign = weeklyDiff >= 0 ? '+' : '-';
    String trendText = '${trendSign}${currencySymbol.isEmpty ? '' : '$currencySymbol '}${NumberFormat('#,##0').format(weeklyDiff.abs())} than last week';

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Curved Purple Header Container
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9A85FE), // Soft lighter lavender shade
                    Color(0xFF8066F6), // Main brand purple
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 35),
              child: Column(
                children: [
                  // Top bar: profile, month selector, notification bell
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Avatar with Thumbs-up Badge
                      GestureDetector(
                        onTap: () {
                          context.findAncestorStateOfType<NavigationHolderState>()?.setIndex(3);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFFFD43F), width: 2),
                                image: const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFD43F),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.thumb_up_rounded, size: 8, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Month Selector Pill
                      GestureDetector(
                        onTap: () => _selectMonth(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(_selectedMonth),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),

                      // Notification Bell with Red Dot
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                            ),
                            if (finance.notifications.any((n) => !n.isRead))
                              Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Balance info
                  const Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      if (finance.currency.isEmpty) {
                        CurrencySelectorSheet.show(context);
                      }
                    },
                    child: Text(
                      finance.incognitoEnabled ? '••••' : (currencySymbol.isEmpty ? 'Select Currency' : '$currencySymbol ${NumberFormat('#,##0.00').format(finance.totalBalance)}'),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    trendText,
                    style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main Body Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Your Money" Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Money',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletDetailsScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Text('Details', style: TextStyle(color: MoniTheme.mutedText, fontSize: 11, fontWeight: FontWeight.bold)),
                              SizedBox(width: 2),
                              Icon(Icons.arrow_forward_ios_rounded, color: MoniTheme.mutedText, size: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Income & Expenses side-by-side cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMoneyCard(
                          title: 'Income',
                          amount: totalIncome,
                          currencySymbol: currencySymbol,
                          icon: Icons.account_balance_wallet_rounded,
                          color: MoniTheme.pastelBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMoneyCard(
                          title: 'Expenses',
                          amount: totalExpenses,
                          currencySymbol: currencySymbol,
                          icon: Icons.analytics_rounded,
                          color: MoniTheme.pastelOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Black insight promo banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1D20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Your insight is ready',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          'Get Pro >',
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transactions',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search_rounded, color: MoniTheme.mutedText, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Search and filter capabilities are fully active!')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune_rounded, color: MoniTheme.mutedText, size: 20),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ReportsExportScreen()),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E5FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'For the Period',
                              style: TextStyle(color: Color(0xFF8A72F6), fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Transactions List grouped by date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total $currencySymbol ${NumberFormat('#,##0.00').format(totalExpenses)}',
                        style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Transaction items list
                  if (selectedMonthTxs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: MoniTheme.premiumCardDecoration,
                      alignment: Alignment.center,
                      child: const Text('No transactions logged for this month.', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                    )
                  else
                    ...selectedMonthTxs.take(10).map((tx) {
                      final isExpense = tx.type == 'expense';
                      final color = isExpense ? MoniTheme.pastelOrange : MoniTheme.pastelBlue;
                      final walletName = finance.wallets.firstWhere((w) => w.id == tx.walletId, orElse: () => Wallet(id: '', name: 'Wallet', balance: 0, type: 'cash')).name;

                      return Container(
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
                              child: Icon(
                                isExpense ? Icons.shopping_bag_rounded : Icons.payments_rounded,
                                color: color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.title,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: MoniTheme.darkText),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${tx.category} • $walletName',
                                    style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isExpense ? '-' : '+'}${currencySymbol}${tx.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: isExpense ? Colors.redAccent : Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$currencySymbol ${(finance.totalBalance - tx.amount).toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 10, color: MoniTheme.mutedText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 100), // Space for floating bottom nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoneyCard({
    required String title,
    required double amount,
    required String currencySymbol,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: MoniTheme.premiumCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: MoniTheme.mutedText, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.info_outline_rounded, color: MoniTheme.mutedText, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$currencySymbol ${NumberFormat('#,##0.00').format(amount)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: MoniTheme.darkText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
