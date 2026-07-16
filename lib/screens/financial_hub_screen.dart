import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';

class FinancialHubScreen extends StatefulWidget {
  const FinancialHubScreen({super.key});

  @override
  State<FinancialHubScreen> createState() => _FinancialHubScreenState();
}

class _FinancialHubScreenState extends State<FinancialHubScreen> {
  // EMI Calculator State
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _monthsController = TextEditingController();
  double _emiResult = 0.0;
  double _totalInterest = 0.0;

  // Debt Tracker State
  final List<Map<String, dynamic>> _debts = [
    {'name': 'Amal (Friend)', 'amount': 15000.0, 'type': 'lend', 'due': '2026-08-10'},
    {'name': 'Commercial Bank Loan', 'amount': 250000.0, 'type': 'borrow', 'due': '2030-12-01'},
  ];
  final _debtNameController = TextEditingController();
  final _debtAmountController = TextEditingController();
  String _debtType = 'lend';

  // Tax Calculator State
  final _incomeController = TextEditingController();
  double _taxResult = 0.0;

  // Shopping List State
  double _shoppingBudget = 5000.0;
  final List<Map<String, dynamic>> _shoppingItems = [
    {'name': 'Milk powder', 'price': 1200.0, 'checked': false},
    {'name': 'Rice (5kg)', 'price': 1100.0, 'checked': true},
  ];
  final _shoppingItemController = TextEditingController();
  final _shoppingPriceController = TextEditingController();

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _monthsController.dispose();
    _debtNameController.dispose();
    _debtAmountController.dispose();
    _incomeController.dispose();
    _shoppingItemController.dispose();
    _shoppingPriceController.dispose();
    super.dispose();
  }

  // Calculate EMI
  void _calculateEmi() {
    final double p = double.tryParse(_principalController.text) ?? 0.0;
    final double r = (double.tryParse(_rateController.text) ?? 0.0) / 12 / 100;
    final int n = int.tryParse(_monthsController.text) ?? 0;

    if (p > 0 && r > 0 && n > 0) {
      // EMI = [P x R x (1+R)^N]/[((1+R)^N)-1]
      final double powValue = (1 + r);
      double temp = 1.0;
      for (int i = 0; i < n; i++) {
        temp *= powValue;
      }
      final double emi = (p * r * temp) / (temp - 1);
      setState(() {
        _emiResult = emi;
        _totalInterest = (emi * n) - p;
      });
    }
  }

  // Calculate Simple Sri Lankan Income Tax (Simulated rules)
  void _calculateTax() {
    final double income = double.tryParse(_incomeController.text) ?? 0.0;
    // Simple progressive tax calculation
    double tax = 0.0;
    if (income > 1200000) {
      tax = (income - 1200000) * 0.06;
    }
    setState(() {
      _taxResult = tax;
    });
  }

  // Shopping list helpers
  double get _totalShoppingSpent {
    return _shoppingItems
        .where((item) => item['checked'] == true)
        .fold(0.0, (sum, item) => sum + (item['price'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: MoniTheme.background,
        appBar: AppBar(
          title: const Text('Financial Tools Hub', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: MoniTheme.darkText,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  height: 48,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: MoniTheme.sageGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: MoniTheme.sageGreen,
                    unselectedLabelColor: MoniTheme.mutedText,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    tabs: const [
                      Tab(text: 'EMI Calc'),
                      Tab(text: 'Debts & Reminders'),
                      Tab(text: 'Tax Calc'),
                      Tab(text: 'Shopping List'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // 1. EMI Calculator View
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loan EMI Calculator',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _principalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Loan Principal Amount ($currencySymbol)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Annual Interest Rate (%)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _monthsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tenure (Months)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoniTheme.blackAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: _calculateEmi,
                      child: const Text('Calculate EMI', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    if (_emiResult > 0)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: MoniTheme.premiumCardDecoration,
                        child: Column(
                          children: [
                            Text(
                              'Monthly EMI: $currencySymbol ${NumberFormat('#,##0.00').format(_emiResult)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: MoniTheme.sageGreen),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total Interest Payable: $currencySymbol ${NumberFormat('#,##0.00').format(_totalInterest)}',
                              style: const TextStyle(fontSize: 14, color: MoniTheme.mutedText),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // 2. Debt Tracker View
              ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Borrow & Lend Log',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: MoniTheme.sageGreen, size: 30),
                        onPressed: () => _showAddDebtDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._debts.map((debt) {
                    final isLend = debt['type'] == 'lend';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: MoniTheme.premiumCardDecoration,
                      child: Row(
                        children: [
                          Icon(
                            isLend ? Icons.arrow_outward : Icons.call_received,
                            color: isLend ? Colors.green : Colors.redAccent,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(debt['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Due Date: ${debt['due']}', style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$currencySymbol ${NumberFormat('#,##0').format(debt['amount'])}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLend ? Colors.green : Colors.redAccent),
                              ),
                              const SizedBox(height: 4),
                              // Send Quick Whatsapp reminder for Lend
                              if (isLend)
                                TextButton.icon(
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('WhatsApp reminder template copied for ${debt['name']}')),
                                    );
                                  },
                                  icon: const Icon(Icons.share, size: 12, color: Colors.green),
                                  label: const Text('WhatsApp Reminder', style: TextStyle(fontSize: 10, color: Colors.green)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),

              // 3. Tax Calculator View
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Annual Income Tax Estimator',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _incomeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Annual Net Income ($currencySymbol)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoniTheme.blackAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: _calculateTax,
                      child: const Text('Estimate Tax', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    if (_taxResult > 0)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: MoniTheme.premiumCardDecoration,
                        child: Center(
                          child: Text(
                            'Estimated Tax: $currencySymbol ${NumberFormat('#,##0.00').format(_taxResult)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent),
                          ),
                        ),
                      )
                    else if (_incomeController.text.isNotEmpty)
                      const Center(
                        child: Text('Your income is below the taxable threshold!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),

              // 4. Shopping List View
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: MoniTheme.premiumCardDecoration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Shopping List Budget', style: TextStyle(fontSize: 12, color: MoniTheme.mutedText)),
                            Text('$currencySymbol ${NumberFormat('#,##0').format(_shoppingBudget)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Checked Spent', style: TextStyle(fontSize: 12, color: MoniTheme.mutedText)),
                            Text('$currencySymbol ${NumberFormat('#,##0').format(_totalShoppingSpent)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _totalShoppingSpent > _shoppingBudget ? Colors.redAccent : MoniTheme.sageGreen)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _shoppingItems.length,
                      itemBuilder: (context, index) {
                        final item = _shoppingItems[index];
                        return ListTile(
                          leading: Checkbox(
                            value: item['checked'],
                            activeColor: MoniTheme.sageGreen,
                            onChanged: (val) {
                              setState(() {
                                item['checked'] = val ?? false;
                              });
                            },
                          ),
                          title: Text(item['name'], style: TextStyle(decoration: item['checked'] ? TextDecoration.lineThrough : null)),
                          trailing: Text('$currencySymbol ${NumberFormat('#,##0').format(item['price'])}'),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _shoppingItemController,
                            decoration: const InputDecoration(labelText: 'Item name'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _shoppingPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Price'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: MoniTheme.sageGreen),
                          onPressed: () {
                            final name = _shoppingItemController.text.trim();
                            final price = double.tryParse(_shoppingPriceController.text) ?? 0.0;
                            if (name.isNotEmpty && price > 0) {
                              setState(() {
                                _shoppingItems.add({'name': name, 'price': price, 'checked': false});
                                _shoppingItemController.clear();
                                _shoppingPriceController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDebtDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Debt Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _debtNameController,
              decoration: const InputDecoration(labelText: 'Person / Institution'),
            ),
            TextField(
              controller: _debtAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Lend'),
                    value: 'lend',
                    groupValue: _debtType,
                    onChanged: (val) {
                      setState(() {
                        _debtType = val!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Borrow'),
                    value: 'borrow',
                    groupValue: _debtType,
                    onChanged: (val) {
                      setState(() {
                        _debtType = val!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MoniTheme.blackAccent),
            onPressed: () {
              final name = _debtNameController.text.trim();
              final amount = double.tryParse(_debtAmountController.text) ?? 0.0;
              if (name.isNotEmpty && amount > 0) {
                setState(() {
                  _debts.add({
                    'name': name,
                    'amount': amount,
                    'type': _debtType,
                    'due': '2026-08-30',
                  });
                  _debtNameController.clear();
                  _debtAmountController.clear();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save Entry'),
          ),
        ],
      ),
    );
  }
}
