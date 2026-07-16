import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';

class RecurringSubscriptionsScreen extends StatelessWidget {
  const RecurringSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    final recurringTxs = finance.transactions.whereType<Transaction>().where((t) => t.isRecurring).toList();

    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Recurring & Subscriptions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Info Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MoniTheme.sageGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: MoniTheme.sageGreen.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: MoniTheme.sageGreen, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Recurring items are processed automatically. Moni adds them to your list when their recurrence interval triggers.',
                      style: TextStyle(fontSize: 13, color: MoniTheme.darkText, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Active Subscriptions & Templates',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            if (recurringTxs.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: MoniTheme.premiumCardDecoration,
                child: const Center(
                  child: Text(
                    'No recurring subscriptions. Create one using the Quick Add button by checking "Recurring Transaction"!',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...recurringTxs.map((tx) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: MoniTheme.premiumCardDecoration,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: MoniTheme.sageGreenLight,
                        child: const Icon(Icons.replay_circle_filled_rounded, color: MoniTheme.sageGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: MoniTheme.blackAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tx.recurrenceInterval.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tx.category,
                                  style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tx.type == 'income' ? '+' : '-'}$currencySymbol ${NumberFormat('#,##0').format(tx.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: tx.type == 'income' ? Colors.green : Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                            onPressed: () {
                              finance.deleteTransaction(tx.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Recurring template removed.')),
                              );
                            },
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
