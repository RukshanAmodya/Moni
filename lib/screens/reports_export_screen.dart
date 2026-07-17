import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import '../models/finance_models.dart';

class ReportsExportScreen extends StatefulWidget {
  const ReportsExportScreen({super.key});

  @override
  State<ReportsExportScreen> createState() => _ReportsExportScreenState();
}

class _ReportsExportScreenState extends State<ReportsExportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedCategory = 'All';
  String _selectedWallet = 'All';

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    // Filter categories & wallets for drop downs
    final categories = ['All', ...finance.expenseCategories, ...finance.incomeCategories];
    final wallets = ['All', ...finance.wallets.map((w) => w.id)];

    // Filtered transaction list for report preview
    final filteredTxs = finance.transactions.whereType<Transaction>().where((t) {
      final inRange = t.date.isAfter(_startDate.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(_endDate.add(const Duration(days: 1)));
      final matchesCategory = _selectedCategory == 'All' || t.category == _selectedCategory;
      final matchesWallet = _selectedWallet == 'All' || t.walletId == _selectedWallet;
      return inRange && matchesCategory && matchesWallet;
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in filteredTxs) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Export Reports Wizard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Filter selectors card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: MoniTheme.premiumCardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date Ranges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectStartDate(context),
                                icon: const Icon(Icons.calendar_today, size: 14, color: MoniTheme.sageGreen),
                                label: Text(DateFormat('yyyy-MM-dd').format(_startDate), style: const TextStyle(color: MoniTheme.darkText)),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('to'),
                            ),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectEndDate(context),
                                icon: const Icon(Icons.calendar_today, size: 14, color: MoniTheme.sageGreen),
                                label: Text(DateFormat('yyyy-MM-dd').format(_endDate), style: const TextStyle(color: MoniTheme.darkText)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                                items: categories.toSet().map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCategory = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedWallet,
                                decoration: const InputDecoration(labelText: 'Account / Wallet', border: OutlineInputBorder()),
                                items: wallets.toSet().map((w) => DropdownMenuItem(value: w, child: Text(w.toUpperCase()))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedWallet = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Report Preview & Summary
                  const Text('Report Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: MoniTheme.premiumCardDecoration,
                    child: Column(
                      children: [
                        _buildSummaryRow('Total Income', '$currencySymbol ${NumberFormat('#,##0').format(totalIncome)}', Colors.green),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Total Expenses', '$currencySymbol ${NumberFormat('#,##0').format(totalExpense)}', Colors.redAccent),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Net Balance',
                          '$currencySymbol ${NumberFormat('#,##0').format(totalIncome - totalExpense)}',
                          (totalIncome - totalExpense) >= 0 ? Colors.green : Colors.redAccent,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Transactions matching preview list
                  Text('Matching Transactions (${filteredTxs.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (filteredTxs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: MoniTheme.premiumCardDecoration,
                      child: const Center(child: Text('No transactions fit the filters.')),
                    )
                  else
                    ...filteredTxs.map((tx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: MoniTheme.premiumCardDecoration,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${tx.category} • ${DateFormat('yyyy-MM-dd').format(tx.date)}', style: const TextStyle(fontSize: 11, color: MoniTheme.mutedText)),
                                ],
                              ),
                              Text(
                                '${tx.type == 'income' ? '+' : '-'}$currencySymbol ${NumberFormat('#,##0').format(tx.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tx.type == 'income' ? Colors.green : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            // Bottom Action pill button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MoniTheme.blackAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                ),
                onPressed: () async {
                  try {
                    final buffer = StringBuffer();
                    buffer.writeln('ID,Title,Amount,Type,Category,Date,Wallet');
                    for (var tx in filteredTxs) {
                      buffer.writeln('${tx.id},"${tx.title}",${tx.amount},${tx.type},${tx.category},${tx.date.toIso8601String()},${tx.walletId}');
                    }

                    Directory? downloadsDir;
                    if (Platform.isAndroid) {
                      downloadsDir = Directory('/storage/emulated/0/Download');
                    } else {
                      downloadsDir = await getDownloadsDirectory();
                    }
                    if (downloadsDir == null || !await downloadsDir.exists()) {
                      downloadsDir = await getApplicationDocumentsDirectory();
                    }

                    final moniDir = Directory('${downloadsDir.path}/Moni');
                    if (!await moniDir.exists()) {
                      await moniDir.create(recursive: true);
                    }

                    final String timestamp = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
                    final File file = File('${moniDir.path}/${timestamp}_report.csv');
                    await file.writeAsString(buffer.toString());

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Report exported to: ${file.path}')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error exporting report: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Export Filtered CSV Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
