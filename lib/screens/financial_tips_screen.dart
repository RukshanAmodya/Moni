import 'package:flutter/material.dart';
import '../theme/moni_theme.dart';

class FinancialTipsScreen extends StatelessWidget {
  const FinancialTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Moni Financial Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Prominent Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: MoniTheme.blackCardDecoration,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUILD WEALTH SMARTLY',
                    style: TextStyle(color: MoniTheme.sageGreen, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 11),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Learn the Core Rules of Personal Finance',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Read articles curated by experts to manage, save, and grow your money effortlessly.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Expert Articles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            _buildArticleCard(
              title: 'The 50/30/20 Budgeting Rule',
              description: 'Divide your income into three categories: 50% for Needs, 30% for Wants, and 20% for Savings and debt repayment. An excellent framework for beginners.',
              readTime: '3 min read',
            ),
            _buildArticleCard(
              title: 'Building an Emergency Fund',
              description: 'Save 3 to 6 months of expenses in a highly liquid account. This ensures you do not fall into high-interest debt when unexpected situations arise.',
              readTime: '4 min read',
            ),
            _buildArticleCard(
              title: 'Understanding Compound Interest',
              description: 'Albert Einstein called compound interest the eighth wonder of the world. Learn how small monthly investments accumulate into large fortunes over time.',
              readTime: '5 min read',
            ),

            const SizedBox(height: 16),
            const Text(
              'Recommended Reading (Affiliate)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MoniTheme.darkText),
            ),
            const SizedBox(height: 12),

            // Affiliate Book 1
            Container(
              padding: const EdgeInsets.all(16),
              decoration: MoniTheme.premiumCardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: MoniTheme.sageGreenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.book_rounded, color: MoniTheme.sageGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rich Dad Poor Dad',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'by Robert Kiyosaki',
                          style: TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Explains the difference between assets and liabilities and how the rich make money work for them.',
                          style: TextStyle(fontSize: 11, color: MoniTheme.mutedText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Affiliate Book 2
            Container(
              padding: const EdgeInsets.all(16),
              decoration: MoniTheme.premiumCardDecoration,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBEBEB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.book_rounded, color: Colors.redAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Richest Man in Babylon',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'by George S. Clason',
                          style: TextStyle(fontSize: 12, color: MoniTheme.mutedText),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'A classic book containing simple financial truths about saving at least 10% of everything you earn.',
                          style: TextStyle(fontSize: 11, color: MoniTheme.mutedText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard({required String title, required String description, required String readTime}) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: MoniTheme.sageGreenLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  readTime,
                  style: const TextStyle(color: MoniTheme.sageGreen, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.bookmark_border, size: 20, color: MoniTheme.mutedText),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: MoniTheme.mutedText, height: 1.4),
          ),
        ],
      ),
    );
  }
}
