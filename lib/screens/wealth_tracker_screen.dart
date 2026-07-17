import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/moni_theme.dart';
import '../providers/finance_provider.dart';
import '../models/finance_models.dart';

class WealthTrackerScreen extends StatefulWidget {
  const WealthTrackerScreen({super.key});

  @override
  State<WealthTrackerScreen> createState() => _WealthTrackerScreenState();
}

class _WealthTrackerScreenState extends State<WealthTrackerScreen> {
  final double _totalLiabilities = 45000.0; // Simulated/actual liabilities

  void _showAddAssetSheet() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final sharesController = TextEditingController();
    String category = 'Stock';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final finance = Provider.of<FinanceProvider>(context, listen: false);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Asset Portfolio',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: MoniTheme.darkText),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Asset Name (e.g. Tesla Stock)',
                      filled: true,
                      fillColor: const Color(0xFFF6F5FD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Current Valuation',
                      filled: true,
                      fillColor: const Color(0xFFF6F5FD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sharesController,
                    decoration: InputDecoration(
                      labelText: 'Shares / Quantity (e.g. 5 units)',
                      filled: true,
                      fillColor: const Color(0xFFF6F5FD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Stock', 'Crypto', 'Commodity', 'Real Estate'].map((cat) {
                      final bool isSelected = category == cat;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            category = cat;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8A72F6) : const Color(0xFFF0EFFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF8A72F6),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final double val = double.tryParse(valueController.text) ?? 0.0;
                        if (nameController.text.isNotEmpty && val > 0) {
                          finance.addPortfolioAsset(PortfolioAsset(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameController.text,
                            value: val,
                            category: category,
                            shares: sharesController.text.isNotEmpty ? sharesController.text : '1 Unit',
                          ));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A72F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: const Text('Add Asset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final portfolio = finance.portfolioAssets;

    final double totalAssets = portfolio.fold(0.0, (sum, item) => sum + item.value);
    final double netWorth = totalAssets - _totalLiabilities;

    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Wealth & Portfolio', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
        actions: [
          IconButton(
            onPressed: _showAddAssetSheet,
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF8A72F6)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Net Worth Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E24), Color(0xFF3A3A45)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NET WORTH',
                    style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${finance.currency} ${netWorth.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Assets', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '${finance.currency} ${totalAssets.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Liabilities', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(
                            '${finance.currency} ${_totalLiabilities.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Portfolio Distribution',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            if (portfolio.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: MoniTheme.premiumCardDecoration,
                alignment: Alignment.center,
                child: const Text('No assets registered. Tap + to add assets.', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
              )
            else
              ...portfolio.map((item) {
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  ),
                  onDismissed: (direction) {
                    finance.deletePortfolioAsset(item.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: MoniTheme.premiumCardDecoration,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: item.category == 'Crypto'
                                ? Colors.orange.withOpacity(0.1)
                                : (item.category == 'Stock' ? Colors.blue.withOpacity(0.1) : Colors.amber.withOpacity(0.1)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.category == 'Crypto'
                                ? Icons.currency_bitcoin_rounded
                                : (item.category == 'Stock' ? Icons.show_chart_rounded : Icons.diamond_rounded),
                            color: item.category == 'Crypto'
                                ? Colors.orange
                                : (item.category == 'Stock' ? Colors.blue : Colors.amber),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.shares,
                                style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${finance.currency} ${item.value.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
