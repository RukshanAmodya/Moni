import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);
    final currencySymbol = finance.currency;

    // Budget data matching the mockup
    final mockBudgets = [
      {'name': 'Save for a Car', 'target': 7500.0, 'current': 2500.0, 'percent': 55, 'color': MoniTheme.pastelOrange, 'icon': Icons.directions_car_filled_rounded},
      {'name': 'Save for Education', 'target': 2500.0, 'current': 500.0, 'percent': 25, 'color': MoniTheme.pastelPurple, 'icon': Icons.school_rounded},
      {'name': 'Vacation fund', 'target': 5000.0, 'current': 750.0, 'percent': 65, 'color': MoniTheme.pastelBlue, 'icon': Icons.beach_access_rounded},
      {'name': 'Health Savings', 'target': 3000.0, 'current': 1350.0, 'percent': 45, 'color': MoniTheme.pastelGreen, 'icon': Icons.health_and_safety_rounded},
    ];

    return Scaffold(
      backgroundColor: MoniTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'My Plan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                          ],
                        ),
                        child: const Icon(Icons.add, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                          ],
                        ),
                        child: const Icon(Icons.north_east_rounded, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Goals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Goals', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Goal Card (House by the Sea)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MoniTheme.pastelOrange.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.home_work_rounded, color: MoniTheme.pastelOrange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('House by the Sea', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                              Text('View All', style: TextStyle(color: MoniTheme.mutedText, fontSize: 11)),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert_rounded, color: MoniTheme.mutedText),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: MoniTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900),
                            children: [
                              TextSpan(text: '$currencySymbol 8,750.00 '),
                              const TextSpan(
                                text: 'Out of \$1,750.00',
                                style: TextStyle(color: MoniTheme.mutedText, fontSize: 12, fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress Slider
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.65,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(MoniTheme.pastelOrange),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Progress', style: TextStyle(color: MoniTheme.mutedText, fontSize: 11)),
                        Text('\$750 Left', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: MoniTheme.pastelOrange)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Warning Alert Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECE5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: MoniTheme.pastelOrange, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You're 30% behind schedule and off target.",
                              style: TextStyle(color: MoniTheme.pastelOrange, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Budgets Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Budgets', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: MoniTheme.darkText)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Budgets List
              ...mockBudgets.map((b) {
                final target = b['target'] as double;
                final current = b['current'] as double;
                final percent = b['percent'] as int;
                final color = b['color'] as Color;
                final icon = b['icon'] as IconData;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: MoniTheme.premiumCardDecoration,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b['name'] as String, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              '$currencySymbol ${current.toStringAsFixed(0)} of $currencySymbol ${target.toStringAsFixed(0)}',
                              style: const TextStyle(color: MoniTheme.mutedText, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      // Circular indicator clone style
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$percent%',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
