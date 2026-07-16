import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _typeFilter = 'All'; // 'All', 'Income', 'Expense'
  String _categoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;
    final categories = ['All', ...finance.expenseCategories, ...finance.incomeCategories].toSet().toList();

    // Filter transactions
    final filteredTxs = finance.transactions.where((t) {
      final matchesType = _typeFilter == 'All' ||
          (_typeFilter == 'Income' && t.type == 'income') ||
          (_typeFilter == 'Expense' && t.type == 'expense');
      final matchesCategory = _categoryFilter == 'All' || t.category == _categoryFilter;
      return matchesType && matchesCategory;
    }).toList();

    // Sort: Latest first
    filteredTxs.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Text(
                'Transactions',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  // Type selection pill
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _typeFilter,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ['All', 'Income', 'Expense']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _typeFilter = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category selection pill
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _categoryFilter,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _categoryFilter = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transactions list
            Expanded(
              child: filteredTxs.isEmpty
                  ? const Center(child: Text('No transactions found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredTxs.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTxs[index];
                        final isIncome = tx.type == 'income';
                        final color = isIncome ? Colors.green : Colors.redAccent;
                        final amountSign = isIncome ? '+' : '-';

                        return Dismissible(
                          key: Key(tx.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            finance.deleteTransaction(tx.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction deleted')),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: MoniTheme.premiumCardDecoration,
                            child: Row(
                              children: [
                                // Category Icon placeholder
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: _getCategoryColor(tx.category).withOpacity(0.2),
                                  child: Icon(
                                    _getCategoryIcon(tx.category),
                                    color: _getCategoryColor(tx.category),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Title and Wallet
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            tx.category,
                                            style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: MoniTheme.mutedText,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            tx.walletId.toUpperCase(),
                                            style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Amount & Date
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$amountSign$currencySymbol ${NumberFormat('#,##0').format(tx.amount)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('MMM d, y').format(tx.date),
                                      style: const TextStyle(fontSize: 11, color: MoniTheme.mutedText),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72.0),
        child: FloatingActionButton(
          backgroundColor: MoniTheme.blackAccent,
          shape: const CircleBorder(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddTransactionDialog(),
            );
          },
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Food':
        return Colors.orangeAccent;
      case 'Transport':
        return Colors.blueAccent;
      case 'Bills':
        return Colors.purpleAccent;
      case 'Shopping':
        return Colors.pinkAccent;
      case 'Salary':
        return Colors.green;
      case 'Investment':
        return MoniTheme.sageGreen;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Food':
        return Icons.fastfood_outlined;
      case 'Transport':
        return Icons.directions_car_outlined;
      case 'Bills':
        return Icons.receipt_long_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Salary':
        return Icons.payments_outlined;
      case 'Investment':
        return Icons.show_chart_rounded;
      default:
        return Icons.category_outlined;
    }
  }
}

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _type = 'expense'; // 'income' or 'expense'
  String _category = '';
  String _walletId = 'cash';
  bool _isRecurring = false;
  String _recurrenceInterval = 'none';

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final categories = _type == 'income' ? finance.incomeCategories : finance.expenseCategories;

    // Reset/initialize selected category if not in current category list
    if (_category.isEmpty || !categories.contains(_category)) {
      _category = categories.isNotEmpty ? categories.first : 'Other';
    }

    return AlertDialog(
      title: const Text('Add Transaction'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Income / Expense Selector Toggle
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Expense')),
                      selected: _type == 'expense',
                      selectedColor: Colors.redAccent.withOpacity(0.2),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _type = 'expense';
                            _category = finance.expenseCategories.first;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Income')),
                      selected: _type == 'income',
                      selectedColor: Colors.green.withOpacity(0.2),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _type = 'income';
                            _category = finance.incomeCategories.first;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter amount';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _category = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Wallet Dropdown
              DropdownButtonFormField<String>(
                value: _walletId,
                decoration: const InputDecoration(labelText: 'Wallet / Account', border: OutlineInputBorder()),
                items: finance.wallets
                    .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _walletId = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Recurring Checkbox
              CheckboxListTile(
                title: const Text('Recurring Transaction'),
                value: _isRecurring,
                onChanged: (val) {
                  setState(() {
                    _isRecurring = val ?? false;
                    _recurrenceInterval = _isRecurring ? 'monthly' : 'none';
                  });
                },
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _recurrenceInterval,
                  decoration: const InputDecoration(labelText: 'Interval', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _recurrenceInterval = val;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.tryParse(_amountController.text) ?? 0.0;
              final tx = Transaction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                amount: amount,
                type: _type,
                category: _category,
                date: DateTime.now(),
                walletId: _walletId,
                isRecurring: _isRecurring,
                recurrenceInterval: _recurrenceInterval,
              );
              finance.addTransaction(tx);
              Navigator.pop(context);
            }
          },
          child: const Text('Add', style: TextStyle(color: MoniTheme.sageGreen)),
        ),
      ],
    );
  }
}
