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
        title: Text('Add $type Category'),
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final cat = _categoryController.text.trim();
              if (cat.isNotEmpty) {
                Provider.of<FinanceProvider>(context, listen: false).addCategory(type, cat);
                _categoryController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: MoniTheme.sageGreen)),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: MoniTheme.blackAccent,
          unselectedLabelColor: MoniTheme.mutedText,
          indicatorColor: MoniTheme.sageGreen,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Incomes'),
          ],
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
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final cat = list[index];
              final isDefault = ['Food', 'Transport', 'Bills', 'Shopping', 'Salary', 'Investment', 'Other'].contains(cat);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    if (!isDefault)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => finance.deleteCategory(type, cat),
                      )
                    else
                      const Text(
                        'System Default',
                        style: TextStyle(fontSize: 11, color: MoniTheme.mutedText, fontStyle: FontStyle.italic),
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
            ),
            onPressed: () => _addCategoryDialog(type),
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
