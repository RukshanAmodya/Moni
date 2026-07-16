import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';
import 'pin_lock_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),

              // Account & Preferences
              _buildSectionTitle(context, 'Preferences'),
              Container(
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  children: [
                    // Currency Selector
                    ListTile(
                      title: const Text('Primary Currency'),
                      trailing: DropdownButton<String>(
                        value: finance.currency,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'LKR', child: Text('LKR (රු)')),
                          DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                          DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            finance.updateCurrency(val);
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    // Budget Management Button
                    ListTile(
                      title: const Text('Configure Budgets'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showConfigureBudgetsDialog(context, finance),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Security Section
              _buildSectionTitle(context, 'Security'),
              Container(
                decoration: MoniTheme.premiumCardDecoration,
                child: SwitchListTile(
                  title: const Text('PIN Code Protection'),
                  subtitle: const Text('Secure your financial data'),
                  activeColor: MoniTheme.sageGreen,
                  value: finance.pinEnabled,
                  onChanged: (bool value) {
                    if (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PinLockScreen(
                            isSettingPin: true,
                            onSuccess: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    } else {
                      finance.disablePin();
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Data Backup Section
              _buildSectionTitle(context, 'Backup & Sync'),
              Container(
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_upload_outlined, color: MoniTheme.sageGreen),
                      title: const Text('Export Backup'),
                      subtitle: const Text('Copy backup JSON data to clipboard'),
                      onTap: () async {
                        final data = await finance.exportBackup();
                        await Clipboard.setData(ClipboardData(text: data));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup JSON copied to clipboard!')),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.cloud_download_outlined, color: Colors.blueAccent),
                      title: const Text('Import Backup'),
                      subtitle: const Text('Paste previously exported backup JSON'),
                      onTap: () => _showImportBackupDialog(context, finance),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Monetization & Support
              _buildSectionTitle(context, 'Support Moni'),
              Container(
                decoration: MoniTheme.premiumCardDecoration,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Donation / Buy Me a Coffee',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Moni is completely free. If you find it useful, consider supporting our solo developer with a donation.',
                      style: TextStyle(fontSize: 13, color: MoniTheme.mutedText),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoniTheme.sageGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thank you! Redirecting to BuyMeACoffee/PayPal mock.')),
                        );
                      },
                      icon: const Icon(Icons.coffee_outlined),
                      label: const Text('Donate Now', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Non-intrusive Ad/Affiliate banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MoniTheme.blackAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rate_rounded, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SPONSORED',
                          style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Get Rich Dad Poor Dad - Audio Book',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Learn the financial rules of the rich to start investing intelligently. Grab the best-selling guide today.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: MoniTheme.mutedText,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showConfigureBudgetsDialog(BuildContext context, FinanceProvider finance) {
    showDialog(
      context: context,
      builder: (context) {
        final categories = ['Food', 'Transport', 'Bills', 'Shopping'];
        final Map<String, TextEditingController> controllers = {};

        for (var cat in categories) {
          final budget = finance.budgets.firstWhere((b) => b.category == cat, orElse: () => Budget(category: cat, limitAmount: 0.0));
          controllers[cat] = TextEditingController(text: budget.limitAmount > 0 ? budget.limitAmount.toString() : '');
        }

        return AlertDialog(
          title: const Text('Category Budgets'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((cat) {
              return TextField(
                controller: controllers[cat],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '$cat Limit (${finance.currency})',
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                for (var cat in categories) {
                  final limit = double.tryParse(controllers[cat]!.text) ?? 0.0;
                  if (limit > 0) {
                    finance.setBudget(cat, limit);
                  } else {
                    finance.deleteBudget(cat);
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: MoniTheme.sageGreen)),
            ),
          ],
        );
      },
    );
  }

  void _showImportBackupDialog(BuildContext context, FinanceProvider finance) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste Backup Data'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Paste backup JSON string here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final jsonStr = controller.text.trim();
              if (jsonStr.isNotEmpty) {
                final success = await finance.importBackup(jsonStr);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Backup imported successfully!' : 'Invalid backup data format.'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Import', style: TextStyle(color: MoniTheme.sageGreen)),
          ),
        ],
      ),
    );
  }
}
