import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';

class CurrencySelectorSheet extends StatefulWidget {
  const CurrencySelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CurrencySelectorSheet(),
    );
  }

  @override
  State<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends State<CurrencySelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _currencies = [
    {'code': 'LKR', 'name': 'Sri Lankan Rupee', 'symbol': 'Rs', 'flag': '🇱🇰'},
    {'code': 'USD', 'name': 'United States Dollar', 'symbol': '\$', 'flag': '🇺🇸'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£', 'flag': '🇬🇧'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥', 'flag': '🇯🇵'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹', 'flag': '🇮🇳'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$', 'flag': '🇦🇺'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$', 'flag': '🇨🇦'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$', 'flag': '🇸🇬'},
    {'code': 'AED', 'name': 'UAE Dirham', 'symbol': 'د.إ', 'flag': '🇦🇪'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥', 'flag': '🇨🇳'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context, listen: false);

    final filtered = _currencies.where((c) {
      final query = _searchQuery.toLowerCase();
      return c['code']!.toLowerCase().contains(query) ||
          c['name']!.toLowerCase().contains(query);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 18),
          
          const Text(
            'Select Currency',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: MoniTheme.darkText),
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search currency code or name...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // List view
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index];
                final code = c['code']!;
                final isSelected = finance.currency == code;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0EFFC) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onTap: () {
                      finance.updateCurrency(code);
                      Navigator.pop(context);
                    },
                    leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
                    title: Row(
                      children: [
                        Text(
                          code,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: isSelected ? const Color(0xFF8A72F6) : MoniTheme.darkText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${c['symbol']!})',
                          style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Text(c['name']!, style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF8A72F6))
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
