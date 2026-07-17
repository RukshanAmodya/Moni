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
import '../widgets/currency_selector_sheet.dart';
import 'profile_screen.dart';

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
    final currencySymbol = finance.currency;

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

              // Premium User Account Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A72F6), Color(0xFFAC9BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A72F6).withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        child: Text(
                          auth.isAuthenticated ? '${auth.user?.email?[0].toUpperCase()}' : 'M',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.isAuthenticated ? '${auth.user?.email}' : 'Moni Account',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              auth.isAuthenticated ? 'Tap to view identity QR & connect partners' : 'Sign in to sync cloud data and invite partners',
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionTitle(context, 'Preferences'),
              Container(
                decoration: MoniTheme.premiumCardDecoration,
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Primary Currency'),
                        subtitle: Text(finance.currency.isEmpty ? 'No Currency' : finance.currency, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => CurrencySelectorSheet.show(context),
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
              ),
              const SizedBox(height: 24),

              // Security Section
              _buildSectionTitle(context, 'Security'),
              Container(
                decoration: MoniTheme.premiumCardDecoration,
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(24),
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
                                  onSuccess: (pinContext) => Navigator.pop(pinContext),
                                ),
                              ),
                            );
                          } else {
                            finance.disablePin();
                          }
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Incognito Mode'),
                        subtitle: const Text('Hide account balances and cash values'),
                        activeColor: MoniTheme.sageGreen,
                        value: finance.incognitoEnabled,
                        onChanged: (bool value) {
                          finance.updateIncognitoEnabled(value);
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
                        SwitchListTile(
                          title: const Text('Self-Destruct Security'),
                          subtitle: const Text('Wipe all local data after 5 failed PIN attempts'),
                          activeColor: MoniTheme.sageGreen,
                          value: finance.selfDestructEnabled,
                          onChanged: (bool value) {
                            finance.updateSelfDestructEnabled(value);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Backup & Sync Grid Actions
              _buildSectionTitle(context, 'Backup & Export'),
              Column(
                children: [
                  Row(
                    children: [
                      // Card 1: Export Backup
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final data = await finance.exportBackup();
                            await Clipboard.setData(ClipboardData(text: data));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Backup JSON copied to clipboard!')),
                            );
                          },
                          child: Container(
                            height: 110,
                            padding: const EdgeInsets.all(16),
                            decoration: MoniTheme.premiumCardDecoration,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: MoniTheme.sageGreenLight,
                                  child: Icon(Icons.cloud_upload_outlined, color: MoniTheme.sageGreen, size: 18),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Export Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    SizedBox(height: 2),
                                    Text('Copy JSON to clipboard', style: TextStyle(fontSize: 10, color: MoniTheme.mutedText)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Card 2: Import Backup
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showImportBackupDialog(context, finance),
                          child: Container(
                            height: 110,
                            padding: const EdgeInsets.all(16),
                            decoration: MoniTheme.premiumCardDecoration,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFE3EDF7),
                                  child: Icon(Icons.cloud_download_outlined, color: Colors.blueAccent, size: 18),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Import Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    SizedBox(height: 2),
                                    Text('Paste backup JSON', style: TextStyle(fontSize: 10, color: MoniTheme.mutedText)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Card 3: Export CSV
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final csv = finance.exportTransactionsToCsv();
                            await Clipboard.setData(ClipboardData(text: csv));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('CSV Report copied to clipboard!')),
                            );
                          },
                          child: Container(
                            height: 110,
                            padding: const EdgeInsets.all(16),
                            decoration: MoniTheme.premiumCardDecoration,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFE2F3E7),
                                  child: Icon(Icons.description_outlined, color: Colors.green, size: 18),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Export CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    SizedBox(height: 2),
                                    Text('Copy monthly reports', style: TextStyle(fontSize: 10, color: MoniTheme.mutedText)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Card 4: Report Wizard
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsExportScreen())),
                          child: Container(
                            height: 110,
                            padding: const EdgeInsets.all(16),
                            decoration: MoniTheme.premiumCardDecoration,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFFFBECEB),
                                  child: Icon(Icons.analytics_outlined, color: Colors.deepOrangeAccent, size: 18),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Report Wizard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    SizedBox(height: 2),
                                    Text('Filter & copy custom CSV', style: TextStyle(fontSize: 10, color: MoniTheme.mutedText)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Full width Education Hub card
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialTipsScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: MoniTheme.premiumCardDecoration,
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFFFF7E6),
                            child: Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 20),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Financial Education Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('Read personal finance tips & recommendations', style: TextStyle(fontSize: 11, color: MoniTheme.mutedText)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: MoniTheme.mutedText),
                        ],
                      ),
                    ),
                  ),
                ],
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
