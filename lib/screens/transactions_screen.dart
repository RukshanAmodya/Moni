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
  String _typeFilter = 'All'; // 'All', 'Income', 'Expense', 'Transfer'
  String _categoryFilter = 'All';
  String _walletFilter = 'All';
  DateTimeRange? _dateRange;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;
    final categories = ['All', ...finance.expenseCategories, ...finance.incomeCategories].toSet().toList();

    // Filter transactions
    final filteredTxs = finance.transactions.whereType<Transaction>().where((t) {
      // Search text filter (matches title, category, or tags)
      final query = _searchController.text.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          t.title.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query) ||
          t.tags.any((tag) => tag.toLowerCase().contains(query));

      // Type filter
      final matchesType = _typeFilter == 'All' ||
          (_typeFilter == 'Income' && t.type == 'income') ||
          (_typeFilter == 'Expense' && t.type == 'expense') ||
          (_typeFilter == 'Transfer' && t.type == 'transfer');

      // Category filter
      final matchesCategory = _categoryFilter == 'All' || t.category == _categoryFilter;

      // Wallet filter
      final matchesWallet = _walletFilter == 'All' ||
          t.walletId == _walletFilter ||
          (t.type == 'transfer' && t.toWalletId == _walletFilter);

      // Date Range filter
      bool matchesDate = true;
      if (_dateRange != null) {
        matchesDate = t.date.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }

      return matchesQuery && matchesType && matchesCategory && matchesWallet && matchesDate;
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transactions',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  IconButton(
                    icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list, color: MoniTheme.sageGreen),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Search Bar Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search title, category, or #tag...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {});
                },
              ),
            ),

            // Collapsible Advanced Filter Section
            if (_showFilters)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Type dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _typeFilter,
                            decoration: const InputDecoration(labelText: 'Type', border: InputBorder.none),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Types')),
                              DropdownMenuItem(value: 'Income', child: Text('Income')),
                              DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                              DropdownMenuItem(value: 'Transfer', child: Text('Transfer')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _typeFilter = val;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Wallet Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _walletFilter,
                            decoration: const InputDecoration(labelText: 'Wallet', border: InputBorder.none),
                            items: [
                              const DropdownMenuItem(value: 'All', child: Text('All Wallets')),
                              ...finance.wallets.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _walletFilter = val;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Category Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _categoryFilter,
                            decoration: const InputDecoration(labelText: 'Category', border: InputBorder.none),
                            items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _categoryFilter = val;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Date picker button
                        Expanded(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              foregroundColor: MoniTheme.sageGreen,
                            ),
                            onPressed: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (range != null) {
                                setState(() {
                                  _dateRange = range;
                                });
                              }
                            },
                            icon: const Icon(Icons.date_range, size: 20),
                            label: Text(
                              _dateRange == null
                                  ? 'All Dates'
                                  : '${DateFormat('MM/dd').format(_dateRange!.start)} - ${DateFormat('MM/dd').format(_dateRange!.end)}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_dateRange != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _dateRange = null;
                            });
                          },
                          child: const Text('Reset Dates', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Transactions List (No Dividers, only spacious cards)
            Expanded(
              child: filteredTxs.isEmpty
                  ? const Center(child: Text('No transactions found.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredTxs.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTxs[index];
                        final isIncome = tx.type == 'income';
                        final isTransfer = tx.type == 'transfer';
                        final Color color = isIncome
                            ? Colors.green
                            : isTransfer
                                ? Colors.blueGrey
                                : Colors.redAccent;
                        final amountSign = isIncome
                            ? '+'
                            : isTransfer
                                ? ''
                                : '-';

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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: MoniTheme.premiumCardDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Custom visual icon representing type
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: _getCategoryColor(tx.category).withOpacity(0.12),
                                      child: Icon(
                                        isTransfer ? Icons.swap_horiz_rounded : _getCategoryIcon(tx.category),
                                        color: isTransfer ? Colors.blueGrey : _getCategoryColor(tx.category),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Title & Category/Wallet
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Text(
                                                isTransfer ? 'Transfer' : tx.category,
                                                style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                isTransfer
                                                    ? '${tx.walletId.toUpperCase()} → ${tx.toWalletId?.toUpperCase()}'
                                                    : tx.walletId.toUpperCase(),
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: MoniTheme.sageGreen),
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
                                            fontSize: 15,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          DateFormat('MMM d, y').format(tx.date),
                                          style: const TextStyle(fontSize: 10, color: MoniTheme.mutedText),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Custom extra markers section (Tags, location, attachments, pending status, linked refunds)
                                if (tx.tags.isNotEmpty || tx.location != null || tx.attachmentPath != null || tx.isPending || tx.refundLinkedTxId != null) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      // Pending marker
                                      if (tx.isPending)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('PENDING', style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                      // Refund marker
                                      if (tx.refundLinkedTxId != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('REFUND', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                      // Attachment marker
                                      if (tx.attachmentPath != null)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 2.0),
                                          child: Icon(Icons.attach_file, size: 14, color: MoniTheme.mutedText),
                                        ),
                                      // Location marker
                                      if (tx.location != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 12, color: MoniTheme.mutedText),
                                              const SizedBox(width: 2),
                                              Text(tx.location!, style: const TextStyle(color: MoniTheme.mutedText, fontSize: 9)),
                                            ],
                                          ),
                                        ),
                                      // Tags
                                      ...tx.tags.map((tag) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: MoniTheme.sageGreen.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(tag, style: const TextStyle(color: MoniTheme.sageGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                                          )),
                                    ],
                                  ),
                                ],
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
  final _tagsController = TextEditingController();
  final _locationController = TextEditingController();

  String _type = 'expense'; // 'income', 'expense', or 'transfer'
  String _category = '';
  String _walletId = 'cash';
  String? _toWalletId;
  bool _isRecurring = false;
  String _recurrenceInterval = 'none';
  bool _isPending = false;
  String? _refundLinkedTxId;
  String? _attachmentPath;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _tagsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final categories = _type == 'income' ? finance.incomeCategories : finance.expenseCategories;

    // Reset/initialize selected category if not in current category list
    if (_category.isEmpty || !categories.contains(_category)) {
      _category = categories.isNotEmpty ? categories.first : 'Other';
    }

    // Set default destination wallet for transfer
    if (_type == 'transfer' && _toWalletId == null && finance.wallets.length > 1) {
      _toWalletId = finance.wallets.firstWhere((w) => w.id != _walletId).id;
    }

    const Color brandPurple = Color(0xFF8A72F6);

    InputDecoration customInputDecoration({required String labelText, IconData? prefixIcon}) {
      return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandPurple, width: 1.8),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: Colors.grey.shade400) : null,
      );
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        'New Transaction',
        style: TextStyle(fontWeight: FontWeight.w900, color: MoniTheme.darkText, fontSize: 20),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Income / Expense / Transfer Custom Sliding Toggle Widget
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFC),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'expense';
                            _category = finance.expenseCategories.first;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _type == 'expense' ? brandPurple : Colors.transparent,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              color: _type == 'expense' ? Colors.white : brandPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'income';
                            _category = finance.incomeCategories.first;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _type == 'income' ? brandPurple : Colors.transparent,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income',
                            style: TextStyle(
                              color: _type == 'income' ? Colors.white : brandPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'transfer';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _type == 'transfer' ? brandPurple : Colors.transparent,
                            borderRadius: BorderRadius.circular(21),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Transfer',
                            style: TextStyle(
                              color: _type == 'transfer' ? Colors.white : brandPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title Input
              TextFormField(
                controller: _titleController,
                decoration: customInputDecoration(labelText: 'Description / Title', prefixIcon: Icons.edit_note),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: customInputDecoration(labelText: 'Amount', prefixIcon: Icons.payments_outlined),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter amount';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Conditional Category / Wallet dropdowns
              if (_type != 'transfer') ...[
                // Category Selector
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: customInputDecoration(labelText: 'Category'),
                  items: categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13))))
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
                // Wallet Selector
                DropdownButtonFormField<String>(
                  value: _walletId,
                  decoration: customInputDecoration(labelText: 'Wallet / Account'),
                  items: finance.wallets
                      .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _walletId = val;
                      });
                    }
                  },
                ),
              ] else ...[
                // Source Wallet Selector
                DropdownButtonFormField<String>(
                  value: _walletId,
                  decoration: customInputDecoration(labelText: 'From Wallet (Source)'),
                  items: finance.wallets
                      .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _walletId = val;
                        // Avoid choosing same source & dest wallet
                        if (_toWalletId == _walletId) {
                          _toWalletId = finance.wallets.firstWhere((w) => w.id != _walletId).id;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Destination Wallet Selector
                DropdownButtonFormField<String>(
                  value: _toWalletId,
                  decoration: customInputDecoration(labelText: 'To Wallet (Destination)'),
                  items: finance.wallets
                      .where((w) => w.id != _walletId)
                      .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _toWalletId = val;
                      });
                    }
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Tags Input (Optional)
              TextFormField(
                controller: _tagsController,
                decoration: customInputDecoration(labelText: 'Tags (e.g. #Trip2026, #Medical)', prefixIcon: Icons.tag),
              ),
              const SizedBox(height: 16),

              // Location Input (Optional)
              TextFormField(
                controller: _locationController,
                decoration: customInputDecoration(labelText: 'Location (Optional)', prefixIcon: Icons.location_on_outlined),
              ),
              const SizedBox(height: 16),

              // Attachment Picker Button (Simulated receipt upload)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: brandPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _attachmentPath = _attachmentPath == null ? 'receipt_${DateTime.now().millisecondsSinceEpoch}.png' : null;
                        });
                      },
                      icon: Icon(_attachmentPath == null ? Icons.camera_alt_outlined : Icons.check_circle, size: 20),
                      label: Text(_attachmentPath == null ? 'Upload Receipt Photo' : 'Receipt Linked', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Refund Linkage (Optional - Select original Transaction to link)
              if (_type == 'income') ...[
                DropdownButtonFormField<String>(
                  value: _refundLinkedTxId,
                  decoration: customInputDecoration(labelText: 'Link to original expense (Refund)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None (Standard Income)', style: TextStyle(fontSize: 13))),
                    ...finance.transactions
                        .whereType<Transaction>()
                        .where((t) => t.type == 'expense')
                        .map((t) => DropdownMenuItem(value: t.id, child: Text('${t.title} - LKR ${t.amount}', style: const TextStyle(fontSize: 13)))),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _refundLinkedTxId = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Recurring Settings
              CheckboxListTile(
                title: const Text('Recurring Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MoniTheme.darkText)),
                value: _isRecurring,
                activeColor: brandPurple,
                onChanged: (val) {
                  setState(() {
                    _isRecurring = val ?? false;
                    _recurrenceInterval = _isRecurring ? 'monthly' : 'none';
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _recurrenceInterval,
                  decoration: customInputDecoration(labelText: 'Interval'),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _recurrenceInterval = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Pending Checkbox
              CheckboxListTile(
                title: const Text('Mark as Pending', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MoniTheme.darkText)),
                value: _isPending,
                activeColor: brandPurple,
                onChanged: (val) {
                  setState(() {
                    _isPending = val ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: brandPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.tryParse(_amountController.text) ?? 0.0;
              
              // Process comma separated tags
              final List<String> parsedTags = _tagsController.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .map((t) => t.startsWith('#') ? t : '#$t')
                  .toList();

              final tx = Transaction(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                amount: amount,
                type: _type,
                category: _type == 'transfer' ? 'Transfer' : _category,
                date: DateTime.now(),
                walletId: _walletId,
                isRecurring: _isRecurring,
                recurrenceInterval: _recurrenceInterval,
                toWalletId: _type == 'transfer' ? _toWalletId : null,
                tags: parsedTags,
                location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
                attachmentPath: _attachmentPath,
                isPending: _isPending,
                refundLinkedTxId: _type == 'income' ? _refundLinkedTxId : null,
              );
              finance.addTransaction(tx);
              Navigator.pop(context);
            }
          },
          child: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}
