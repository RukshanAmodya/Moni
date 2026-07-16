import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/finance_models.dart';
import '../services/storage_service.dart';

class FinanceProvider with ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _goals = [];
  List<Wallet> _wallets = [];
  String _currency = 'LKR';
  bool _pinEnabled = false;
  String _pinHash = '';

  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<SavingsGoal> get goals => _goals;
  List<Wallet> get wallets => _wallets;
  String get currency => _currency;
  bool get pinEnabled => _pinEnabled;

  double get totalBalance {
    double bal = 0;
    for (var w in _wallets) {
      bal += w.balance;
    }
    return bal;
  }

  double get thisMonthIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get thisMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Load everything
  Future<void> init() async {
    _currency = await _storage.getCurrency();
    _pinEnabled = await _storage.isPinEnabled();
    _pinHash = await _storage.getPinHash();
    _transactions = await _storage.loadTransactions();
    _budgets = await _storage.loadBudgets();
    _goals = await _storage.loadGoals();
    _wallets = await _storage.loadWallets();

    await processRecurringTransactions();
    notifyListeners();
  }

  // Helper to hash PIN
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<bool> verifyPin(String pin) async {
    return _hashPin(pin) == _pinHash;
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _storage.setPinHash(hash);
    await _storage.setPinEnabled(true);
    _pinHash = hash;
    _pinEnabled = true;
    notifyListeners();
  }

  Future<void> disablePin() async {
    await _storage.setPinHash('');
    await _storage.setPinEnabled(false);
    _pinHash = '';
    _pinEnabled = false;
    notifyListeners();
  }

  Future<void> updateCurrency(String newCurrency) async {
    await _storage.setCurrency(newCurrency);
    _currency = newCurrency;
    notifyListeners();
  }

  // Transaction Actions
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    
    // Update Wallet Balance
    final walletIdx = _wallets.indexWhere((w) => w.id == transaction.walletId);
    if (walletIdx != -1) {
      final wallet = _wallets[walletIdx];
      double newBalance = wallet.balance;
      if (transaction.type == 'income') {
        newBalance += transaction.amount;
      } else {
        newBalance -= transaction.amount;
      }
      _wallets[walletIdx] = wallet.copyWith(balance: newBalance);
      await _storage.saveWallets(_wallets);
    }

    await _storage.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final transaction = _transactions[idx];
      // Reverse Wallet Balance
      final walletIdx = _wallets.indexWhere((w) => w.id == transaction.walletId);
      if (walletIdx != -1) {
        final wallet = _wallets[walletIdx];
        double newBalance = wallet.balance;
        if (transaction.type == 'income') {
          newBalance -= transaction.amount;
        } else {
          newBalance += transaction.amount;
        }
        _wallets[walletIdx] = wallet.copyWith(balance: newBalance);
        await _storage.saveWallets(_wallets);
      }

      _transactions.removeAt(idx);
      await _storage.saveTransactions(_transactions);
      notifyListeners();
    }
  }

  // Budget Actions
  Future<void> setBudget(String category, double limit) async {
    final idx = _budgets.indexWhere((b) => b.category == category);
    if (idx != -1) {
      _budgets[idx] = Budget(category: category, limitAmount: limit);
    } else {
      _budgets.add(Budget(category: category, limitAmount: limit));
    }
    await _storage.saveBudgets(_budgets);
    notifyListeners();
  }

  Future<void> deleteBudget(String category) async {
    _budgets.removeWhere((b) => b.category == category);
    await _storage.saveBudgets(_budgets);
    notifyListeners();
  }

  // Check budget warnings (returns warnings Map or list)
  List<String> getBudgetWarnings() {
    final List<String> warnings = [];
    final now = DateTime.now();
    for (var budget in _budgets) {
      final spent = _transactions
          .where((t) =>
              t.type == 'expense' &&
              t.category == budget.category &&
              t.date.year == now.year &&
              t.date.month == now.month)
          .fold(0.0, (sum, item) => sum + item.amount);
      
      if (budget.limitAmount > 0) {
        final ratio = spent / budget.limitAmount;
        if (ratio >= 1.0) {
          warnings.add("You have exceeded your budget for ${budget.category}!");
        } else if (ratio >= 0.8) {
          warnings.add("Warning: You used ${ (ratio * 100).toStringAsFixed(0) }% of your budget for ${budget.category}!");
        }
      }
    }
    return warnings;
  }

  // Goals Actions
  Future<void> addGoal(SavingsGoal goal) async {
    _goals.add(goal);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoalProgress(String id, double addAmount) async {
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final goal = _goals[idx];
      _goals[idx] = goal.copyWith(currentAmount: goal.currentAmount + addAmount);

      // We subtract this amount from the Cash Wallet as standard goal contribution (unless specific account selected, let's default to cash/bank)
      // For simplicity, contribute from Bank Account or Cash Wallet
      final cashIdx = _wallets.indexWhere((w) => w.id == 'cash');
      if (cashIdx != -1) {
        _wallets[cashIdx] = _wallets[cashIdx].copyWith(balance: _wallets[cashIdx].balance - addAmount);
        await _storage.saveWallets(_wallets);
      }

      await _storage.saveGoals(_goals);
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _storage.saveGoals(_goals);
    notifyListeners();
  }

  // Wallet Actions
  Future<void> setWalletBalance(String id, double newBalance) async {
    final idx = _wallets.indexWhere((w) => w.id == id);
    if (idx != -1) {
      _wallets[idx] = _wallets[idx].copyWith(balance: newBalance);
      await _storage.saveWallets(_wallets);
      notifyListeners();
    }
  }

  // Process Recurring Transactions
  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    final lastCheckStr = await _storage.getLastRecurringCheck();
    if (lastCheckStr == null) {
      await _storage.setLastRecurringCheck(now.toIso8601String());
      return;
    }

    final lastCheck = DateTime.parse(lastCheckStr);
    final daysDifference = now.difference(lastCheck).inDays;

    if (daysDifference >= 1) {
      // Find all recurring template transactions
      // To simulate auto-adding subscription transactions:
      final recurringTemplates = _transactions.where((t) => t.isRecurring).toList();

      for (var template in recurringTemplates) {
        // Find if we should add new instances
        DateTime nextDate = template.date;
        while (true) {
          if (template.recurrenceInterval == 'daily') {
            nextDate = nextDate.add(const Duration(days: 1));
          } else if (template.recurrenceInterval == 'weekly') {
            nextDate = nextDate.add(const Duration(days: 7));
          } else if (template.recurrenceInterval == 'monthly') {
            // approximation
            nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          } else {
            break;
          }

          if (nextDate.isAfter(now)) {
            break;
          }

          if (nextDate.isAfter(lastCheck)) {
            // Add a duplicate transaction for this recurrence
            final newTx = Transaction(
              id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + nextDate.millisecondsSinceEpoch.toString(),
              title: template.title,
              amount: template.amount,
              type: template.type,
              category: template.category,
              date: nextDate,
              walletId: template.walletId,
              isRecurring: false, // Instances themselves are not templates
              recurrenceInterval: 'none',
            );
            _transactions.add(newTx);

            // Update Wallet
            final walletIdx = _wallets.indexWhere((w) => w.id == newTx.walletId);
            if (walletIdx != -1) {
              final wallet = _wallets[walletIdx];
              double newBal = wallet.balance;
              if (newTx.type == 'income') {
                newBal += newTx.amount;
              } else {
                newBal -= newTx.amount;
              }
              _wallets[walletIdx] = wallet.copyWith(balance: newBal);
            }
          }
        }
      }
      await _storage.saveTransactions(_transactions);
      await _storage.saveWallets(_wallets);
      await _storage.setLastRecurringCheck(now.toIso8601String());
    }
  }

  // Backup & Import
  Future<String> exportBackup() async {
    return await _storage.exportBackupData();
  }

  Future<bool> importBackup(String jsonStr) async {
    final success = await _storage.importBackupData(jsonStr);
    if (success) {
      await init();
    }
    return success;
  }

  // Export transactions to CSV format
  String exportTransactionsToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Amount,Type,Category,Date,Wallet,Recurring,Interval');
    for (var tx in _transactions) {
      buffer.writeln(
        '${tx.id},"${tx.title}",${tx.amount},${tx.type},${tx.category},${tx.date.toIso8601String()},${tx.walletId},${tx.isRecurring},${tx.recurrenceInterval}'
      );
    }
    return buffer.toString();
  }
}
