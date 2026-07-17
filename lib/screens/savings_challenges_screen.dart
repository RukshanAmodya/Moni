import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/moni_theme.dart';
import '../providers/finance_provider.dart';

class SavingsChallengesScreen extends StatefulWidget {
  const SavingsChallengesScreen({super.key});

  @override
  State<SavingsChallengesScreen> createState() => _SavingsChallengesScreenState();
}

class _SavingsChallengesScreenState extends State<SavingsChallengesScreen> {
  int _streak = 12; // 12 days streak default

  final List<Map<String, dynamic>> _challenges = [
    {
      'id': 'c1',
      'title': '52-Week Challenge',
      'subtitle': 'Save LKR 500 incremented weekly.',
      'progress': 0.35,
      'status': 'Active',
      'icon': Icons.calendar_today_rounded,
      'color': Color(0xFF8A72F6),
    },
    {
      'id': 'c2',
      'title': 'No-Spend Weekend',
      'subtitle': 'Avoid non-essential expenses this Sat & Sun.',
      'progress': 1.0,
      'status': 'Completed',
      'icon': Icons.block_rounded,
      'color': MoniTheme.sageGreen,
    },
    {
      'id': 'c3',
      'title': '30-Day Budget Champ',
      'subtitle': 'Stay under all categories budget for 30 days.',
      'progress': 0.8,
      'status': 'Active',
      'icon': Icons.emoji_events_rounded,
      'color': Colors.amber,
    }
  ];

  final List<Map<String, dynamic>> _badges = [
    {
      'name': 'Frugal King',
      'description': 'Stay under budget for 7 consecutive days',
      'unlocked': true,
      'icon': '👑',
    },
    {
      'name': 'Incognito Saver',
      'description': 'Save using incognito vaults 5 times',
      'unlocked': true,
      'icon': '🕵️',
    },
    {
      'name': 'Halfway Hero',
      'description': 'Reach 50% of any active savings goal',
      'unlocked': false,
      'icon': '🛡️',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Savings Challenges', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Streak Dashboard Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: MoniTheme.blackCardDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR SAVING STREAK',
                          style: TextStyle(color: MoniTheme.sageGreen, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_streak Days Active!',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Keep logging daily to build solid financial habits and unlock rare badges.',
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Active Challenges Section
            const Text(
              'Active Challenges',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            ..._challenges.map((challenge) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: MoniTheme.premiumCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: challenge['color'].withOpacity(0.1),
                          child: Icon(challenge['icon'], color: challenge['color']),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                challenge['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MoniTheme.darkText),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                challenge['subtitle'],
                                style: const TextStyle(color: MoniTheme.mutedText, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: challenge['status'] == 'Completed'
                                ? MoniTheme.sageGreenLight.withOpacity(0.4)
                                : const Color(0xFFF0EFFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            challenge['status'],
                            style: TextStyle(
                              color: challenge['status'] == 'Completed'
                                  ? MoniTheme.sageGreen
                                  : const Color(0xFF8A72F6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Challenge Progress', style: TextStyle(color: MoniTheme.mutedText, fontSize: 11)),
                        Text(
                          '${(challenge['progress'] * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: MoniTheme.darkText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: challenge['progress'],
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF0EFFC),
                        valueColor: AlwaysStoppedAnimation(challenge['color']),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Achievement Badges Section
            const Text(
              'Achievement Badges',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: MoniTheme.premiumCardDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _badges.map((badge) {
                  return Opacity(
                    opacity: badge['unlocked'] ? 1.0 : 0.45,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: badge['unlocked']
                                  ? const Color(0xFFF0EFFC)
                                  : const Color(0xFFF3F3F3),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              badge['icon'],
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  badge['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MoniTheme.darkText),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  badge['description'],
                                  style: const TextStyle(color: MoniTheme.mutedText, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (badge['unlocked'])
                            const Icon(Icons.check_circle_rounded, color: MoniTheme.sageGreen, size: 20),
                        ],
                      ),
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
