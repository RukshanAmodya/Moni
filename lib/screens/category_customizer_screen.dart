import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../theme/moni_theme.dart';

class CategoryCustomizerScreen extends StatefulWidget {
  const CategoryCustomizerScreen({super.key});

  @override
  State<CategoryCustomizerScreen> createState() => _CategoryCustomizerScreenState();
}

class _CategoryCustomizerScreenState extends State<CategoryCustomizerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategoryDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add $type Category', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g. Health, Gift, Fuel',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: MoniTheme.mutedText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MoniTheme.blackAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final cat = _categoryController.text.trim();
              if (cat.isNotEmpty) {
                Provider.of<FinanceProvider>(context, listen: false).addCategory(type, cat);
                _categoryController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
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
        title: const Text('Customize Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: MoniTheme.sageGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: MoniTheme.sageGreen,
                unselectedLabelColor: MoniTheme.mutedText,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Incomes'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCategoryTab(finance, 'expense', finance.expenseCategories),
            _buildCategoryTab(finance, 'income', finance.incomeCategories),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(FinanceProvider finance, String type, List<String> list) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final cat = list[index];
              final isDefault = ['Food', 'Transport', 'Bills', 'Shopping', 'Salary', 'Investment', 'Other'].contains(cat);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: MoniTheme.premiumCardDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: MoniTheme.sageGreenLight.withOpacity(0.4),
                          child: const Icon(Icons.folder_open_outlined, color: MoniTheme.sageGreen),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          cat,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MoniTheme.darkText),
                        ),
                      ],
                    ),
                    if (!isDefault)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => finance.deleteCategory(type, cat),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'System Default',
                          style: TextStyle(fontSize: 10, color: MoniTheme.mutedText, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: MoniTheme.blackAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              elevation: 0,
            ),
            onPressed: () => _addCategoryDialog(type),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
