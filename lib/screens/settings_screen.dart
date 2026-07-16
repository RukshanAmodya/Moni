import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/moni_theme.dart';
import 'pin_lock_screen.dart';
import '../models/finance_models.dart';
import 'wallet_details_screen.dart';
import 'budget_progress_screen.dart';
import 'recurring_subscriptions_screen.dart';
import 'category_customizer_screen.dart';
import 'reports_export_screen.dart';
import 'financial_tips_screen.dart';
import 'login_screen.dart';
import 'financial_hub_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Premium custom dialog box helper
  void _showPremiumDialog(
    BuildContext context, {
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, color: MoniTheme.darkText, fontSize: 20),
        ),
        content: content,
        actions: actions,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

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

              // Cloud Sync Status Card (Custom Restyled Header)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: MoniTheme.premiumCardDecoration,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: auth.isAuthenticated ? MoniTheme.sageGreen.withOpacity(0.15) : Colors.grey.shade100,
                      child: Icon(
                        auth.isAuthenticated ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                        color: auth.isAuthenticated ? MoniTheme.sageGreen : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.isAuthenticated ? 'Cloud Sync Connected' : 'Sync Offline Mode',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            auth.isAuthenticated ? '${auth.user?.email}' : 'Sign in to backup data to cloud',
                            style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: auth.isAuthenticated ? Colors.redAccent.withOpacity(0.1) : MoniTheme.sageGreen.withOpacity(0.15),
                        foregroundColor: auth.isAuthenticated ? Colors.redAccent : MoniTheme.sageGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (auth.isAuthenticated) {
                          auth.signOut();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      child: Text(auth.isAuthenticated ? 'Logout' : 'Connect'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionTitle(context, 'Preferences'),
              Container(
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  children: [
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
                    ListTile(
                      title: const Text('Configure Budgets'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showConfigureBudgetsDialog(context, finance),
                    ),
                    ListTile(
                      title: const Text('Configure Overall Limits'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showConfigureOverallLimitsDialog(context, finance),
                    ),
                    ListTile(
                      title: const Text('Wallets & Accounts'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletDetailsScreen())),
                    ),
                    ListTile(
                      title: const Text('Budget Tracking Progress'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetProgressScreen())),
                    ),
                    ListTile(
                      title: const Text('Recurring Subscriptions'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringSubscriptionsScreen())),
                    ),
                    ListTile(
                      title: const Text('Customize Categories'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryCustomizerScreen())),
                    ),
                    ListTile(
                      title: const Text('Financial Tools Hub'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialHubScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Security Section
              _buildSectionTitle(context, 'Security'),
              Container(
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  children: [
                    SwitchListTile(
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
                    if (finance.pinEnabled) ...[
                      SwitchListTile(
                        title: const Text('Biometric Fingerprint Lock'),
                        subtitle: const Text('Unlock using device biometric scans'),
                        activeColor: MoniTheme.sageGreen,
                        value: finance.biometricEnabled,
                        onChanged: (bool value) {
                          finance.updateBiometricEnabled(value);
                        },
                      ),
                    ],
                  ],
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
                    ListTile(
                      leading: const Icon(Icons.cloud_download_outlined, color: Colors.blueAccent),
                      title: const Text('Import Backup'),
                      subtitle: const Text('Paste previously exported backup JSON'),
                      onTap: () => _showImportBackupDialog(context, finance),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined, color: Colors.green),
                      title: const Text('Export CSV Report'),
                      subtitle: const Text('Copy monthly report in Excel/CSV format'),
                      onTap: () async {
                        final csv = finance.exportTransactionsToCsv();
                        await Clipboard.setData(ClipboardData(text: csv));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('CSV Report copied to clipboard!')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.analytics_outlined, color: Colors.deepOrangeAccent),
                      title: const Text('Export Report Wizard'),
                      subtitle: const Text('Filter and copy custom reports to CSV'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsExportScreen())),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
                      title: const Text('Financial Education Hub'),
                      subtitle: const Text('Read personal finance tips & recommendations'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialTipsScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
    final categories = ['Food', 'Transport', 'Bills', 'Shopping'];
    final Map<String, TextEditingController> controllers = {};

    for (var cat in categories) {
      final budget = finance.budgets.firstWhere((b) => b.category == cat, orElse: () => Budget(category: cat, limitAmount: 0.0));
      controllers[cat] = TextEditingController(text: budget.limitAmount > 0 ? budget.limitAmount.toString() : '');
    }

    _showPremiumDialog(
      context,
      title: 'Category Budgets',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: controllers[cat],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '$cat Limit (${finance.currency})',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MoniTheme.sageGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
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
          child: const Text('Save Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showConfigureOverallLimitsDialog(BuildContext context, FinanceProvider finance) {
    final monthlyController = TextEditingController(text: finance.overallMonthlyBudget > 0 ? finance.overallMonthlyBudget.toString() : '');
    final weeklyController = TextEditingController(text: finance.overallWeeklyBudget > 0 ? finance.overallWeeklyBudget.toString() : '');
    final dailyController = TextEditingController(text: finance.overallDailyBudget > 0 ? finance.overallDailyBudget.toString() : '');

    _showPremiumDialog(
      context,
      title: 'Overall Budgets',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: monthlyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monthly Limit (${finance.currency})',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: weeklyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weekly Limit (${finance.currency})',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: dailyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Limit (${finance.currency})',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MoniTheme.sageGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: () {
            final monthly = double.tryParse(monthlyController.text) ?? 0.0;
            final weekly = double.tryParse(weeklyController.text) ?? 0.0;
            final daily = double.tryParse(dailyController.text) ?? 0.0;

            finance.updateOverallMonthlyBudget(monthly);
            finance.updateOverallWeeklyBudget(weekly);
            finance.updateOverallDailyBudget(daily);

            Navigator.pop(context);
          },
          child: const Text('Save Limits', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showImportBackupDialog(BuildContext context, FinanceProvider finance) {
    final controller = TextEditingController();
    _showPremiumDialog(
      context,
      title: 'Paste Backup Data',
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Paste backup JSON string here...',
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: MoniTheme.sageGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
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
          child: const Text('Import Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
