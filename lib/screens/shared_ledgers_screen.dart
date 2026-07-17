import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/moni_theme.dart';
import '../providers/finance_provider.dart';

class SharedLedgersScreen extends StatefulWidget {
  const SharedLedgersScreen({super.key});

  @override
  State<SharedLedgersScreen> createState() => _SharedLedgersScreenState();
}

class _SharedLedgersScreenState extends State<SharedLedgersScreen> {
  final List<Map<String, dynamic>> _sharedWallets = [
    {
      'id': 'sw1',
      'name': 'Home Expenses',
      'balance': 45800.0,
      'partner': 'Asha (Partner)',
      'limit': 60000.0,
      'spent': 14200.0,
    },
    {
      'id': 'sw2',
      'name': 'Vacation fund',
      'balance': 120000.0,
      'partner': 'Ruwan (Brother)',
      'limit': 150000.0,
      'spent': 30000.0,
    }
  ];

  final List<Map<String, dynamic>> _activities = [
    {
      'user': 'Asha',
      'action': 'added an expense of LKR 3,200',
      'category': 'Grocery',
      'time': '10 mins ago'
    },
    {
      'user': 'You',
      'action': 'deposited LKR 10,000 to Vacation fund',
      'category': 'Transfer',
      'time': '2 hours ago'
    },
    {
      'user': 'Asha',
      'action': 'joined the Home Expenses ledger',
      'category': 'System',
      'time': '1 day ago'
    }
  ];

  void _showInviteDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Invite Partner', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your partner or family member\'s email to share this ledger in real-time.',
              style: TextStyle(color: MoniTheme.mutedText, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'partner@example.com',
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8A72F6)),
                filled: true,
                fillColor: const Color(0xFFF6F5FD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invitation sent to ${emailController.text}!'),
                  backgroundColor: const Color(0xFF8A72F6),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A72F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Send Invite', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);

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
                  const Text(
                    'Share wallets with roommates or partners. Live Firestore sync guarantees both stay within the budget limits.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showInviteDialog,
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text('Invite a Partner', style: TextStyle(fontWeight: FontWeight.bold)),
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
              'Shared Wallets',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            ..._sharedWallets.map((wallet) {
              final double progress = wallet['spent'] / wallet['limit'];
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
                          wallet['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EFFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            wallet['partner'],
                            style: const TextStyle(color: Color(0xFF8A72F6), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${finance.currency} ${wallet['balance'].toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF8A72F6)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Budget Progress', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                        Text(
                          '${finance.currency} ${wallet['spent'].toStringAsFixed(0)} / ${wallet['limit'].toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: MoniTheme.darkText),
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
              'Live Collaboration Log',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: MoniTheme.premiumCardDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _activities.map((act) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFF0EFFC),
                          child: Text(
                            act['user'][0],
                            style: const TextStyle(color: Color(0xFF8A72F6), fontWeight: FontWeight.bold),
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
                                    TextSpan(
                                      text: '${act['user']} ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: act['action']),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                act['time'],
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
