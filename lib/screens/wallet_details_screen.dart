import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';

class WalletDetailsScreen extends StatelessWidget {
  const WalletDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Wallets & Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Wallets list
            ...finance.wallets.map((wallet) {
              // Get transactions for this specific wallet
              final txs = finance.transactions.where((t) => t.walletId == wallet.id).toList();

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
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: MoniTheme.sageGreenLight,
                              child: Icon(_getWalletIcon(wallet.type), color: MoniTheme.sageGreen),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  wallet.type,
                                  style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _showEditBalanceDialog(context, finance, wallet),
                            ),
                            if (wallet.id != 'cash' && wallet.id != 'bank' && wallet.id != 'card')
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => finance.deleteWallet(wallet.id),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$currencySymbol ${NumberFormat('#,##0.00').format(wallet.balance)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: MoniTheme.darkText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recent Activity (${txs.length} transactions)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MoniTheme.mutedText),
                    ),
                    const SizedBox(height: 8),
                    if (txs.isEmpty)
                      const Text('No recent transactions for this wallet.', style: TextStyle(fontSize: 12, color: MoniTheme.mutedText))
                    else
                      Column(
                        children: txs.take(3).map((tx) {
                          final isIncome = tx.type == 'income';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(tx.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text(
                                  '${isIncome ? '+' : '-'}$currencySymbol ${NumberFormat('#,##0').format(tx.amount)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isIncome ? Colors.green : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            // Add Wallet Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MoniTheme.blackAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              ),
              onPressed: () => _showAddWalletDialog(context, finance),
              icon: const Icon(Icons.add_card),
              label: const Text('Add New Account / Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWalletIcon(String type) {
    switch (type) {
      case 'Bank':
        return Icons.account_balance;
      case 'Card':
        return Icons.credit_card;
      default:
        return Icons.wallet;
    }
  }

  void _showAddWalletDialog(BuildContext context, FinanceProvider finance) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'Bank';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Account / Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Account Name (e.g. HNB Savings)'),
              ),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Initial Balance'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Account Type', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash / Pocket Money')),
                  DropdownMenuItem(value: 'Bank', child: Text('Bank Account')),
                  DropdownMenuItem(value: 'Card', child: Text('Credit Card')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedType = val;
                    });
                  }
                },
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
                final name = nameController.text.trim();
                final balance = double.tryParse(balanceController.text) ?? 0.0;
                if (name.isNotEmpty) {
                  finance.addWallet(
                    Wallet(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      balance: balance,
                      type: selectedType,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: MoniTheme.sageGreen)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBalanceDialog(BuildContext context, FinanceProvider finance, Wallet wallet) {
    final balanceController = TextEditingController(text: wallet.balance.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${wallet.name} Balance'),
        content: TextField(
          controller: balanceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New Balance'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newBal = double.tryParse(balanceController.text) ?? wallet.balance;
              finance.setWalletBalance(wallet.id, newBal);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: MoniTheme.sageGreen)),
          ),
        ],
      ),
    );
  }
}
