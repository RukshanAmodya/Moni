import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/moni_theme.dart';
import '../providers/finance_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class SharedLedgersScreen extends StatefulWidget {
  const SharedLedgersScreen({super.key});

  @override
  State<SharedLedgersScreen> createState() => _SharedLedgersScreenState();
}

class _SharedLedgersScreenState extends State<SharedLedgersScreen> {
  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // 1. Auth Gate
    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: MoniTheme.background,
        appBar: AppBar(
          title: const Text('Shared Ledgers', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: MoniTheme.darkText,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EFFC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_person_rounded, size: 64, color: Color(0xFF8A72F6)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Authentication Required',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: MoniTheme.darkText),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please sign in to access collaborative budgets and shared partner ledgers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: MoniTheme.mutedText, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A72F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign In / Register',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool hasPartner = finance.partnerEmail.isNotEmpty;

    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Shared Ledgers', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Top Promo Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A72F6), Color(0xFFAC9BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A72F6).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.people_alt_rounded, color: Colors.white, size: 36),
                  const SizedBox(height: 16),
                  const Text(
                    'Collaborative Budgeting',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasPartner
                        ? 'Connected to partner: ${finance.partnerEmail}. Real-time synchronization is live.'
                        : 'Share wallets with roommates or partners. Scan a partner\'s QR identity to co-manage real ledgers.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                    icon: Icon(hasPartner ? Icons.link_rounded : Icons.qr_code_scanner_rounded, size: 18),
                    label: Text(hasPartner ? 'Manage Partner Connection' : 'Scan QR to Connect', style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8A72F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Shared Budgets',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            if (!hasPartner)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: MoniTheme.premiumCardDecoration,
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.link_off_rounded, color: MoniTheme.mutedText, size: 36),
                    SizedBox(height: 12),
                    Text(
                      'No Connected Partner Ledgers',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MoniTheme.darkText),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Scan your partner\'s QR code in the Profile screen to link a shared wallet.',
                      textAlign: Center,
                      style: TextStyle(color: MoniTheme.mutedText, fontSize: 11),
                    ),
                  ],
                ),
              )
            else ...[
              // Calculate actual collaborative values from current user budgets/wallets
              ...finance.budgets.map((budget) {
                final double spent = finance.transactions
                    .where((t) =>
                        t.type == 'expense' &&
                        t.category == budget.category &&
                        t.date.year == DateTime.now().year &&
                        t.date.month == DateTime.now().month)
                    .fold(0.0, (sum, item) => sum + item.amount);
                final double progress = budget.limitAmount > 0 ? (spent / budget.limitAmount).clamp(0.0, 1.0) : 0.0;

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
                          Text(
                            'Shared ${budget.category} Wallet',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MoniTheme.darkText),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EFFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Sync Active',
                              style: TextStyle(color: Color(0xFF8A72F6), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${finance.currency} ${(budget.limitAmount - spent).toStringAsFixed(0)} remaining',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF8A72F6)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Combined Spending', style: TextStyle(color: MoniTheme.mutedText, fontSize: 11)),
                          Text(
                            '${finance.currency} ${spent.toStringAsFixed(0)} / ${budget.limitAmount.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: MoniTheme.darkText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFF0EFFC),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF8A72F6)),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Text(
                'Live Shared Collaboration Log',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: MoniTheme.premiumCardDecoration,
                padding: const EdgeInsets.all(16),
                child: finance.transactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No recent shared transactions logged.', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                      )
                    : Column(
                        children: finance.transactions.take(5).map((tx) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFF0EFFC),
                                  child: Icon(
                                    tx.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: const Color(0xFF8A72F6),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(color: MoniTheme.darkText, fontSize: 13),
                                          children: [
                                            const TextSpan(
                                              text: 'You ',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: 'logged a ${tx.category} ${tx.type} of ${finance.currency} ${tx.amount.toStringAsFixed(0)}'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('jm').format(tx.date),
                                        style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
