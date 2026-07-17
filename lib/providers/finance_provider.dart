import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/finance_models.dart';
import '../services/storage_service.dart';

class FinanceProvider with ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _goals = [];
  List<Wallet> _wallets = [];
  String _currency = '';
  bool _pinEnabled = false;
  String _pinHash = '';
  bool _biometricEnabled = false;

  double _overallMonthlyBudget = 0.0;
  double _overallWeeklyBudget = 0.0;
  double _overallDailyBudget = 0.0;
  double _piggyBankBalance = 0.0;
  bool _incognitoEnabled = false;
  bool _selfDestructEnabled = false;

  List<Transaction> get transactions => _transactions;
  List<Budget> get budgets => _budgets;
  List<SavingsGoal> get goals => _goals;
  List<Wallet> get wallets => _wallets;
  String get currency => _currency;
  bool get pinEnabled => _pinEnabled;
  bool get biometricEnabled => _biometricEnabled;
  double get overallMonthlyBudget => _overallMonthlyBudget;
  double get overallWeeklyBudget => _overallWeeklyBudget;
  double get overallDailyBudget => _overallDailyBudget;
  double get piggyBankBalance => _piggyBankBalance;
  bool get incognitoEnabled => _incognitoEnabled;
  bool get selfDestructEnabled => _selfDestructEnabled;

  List<String> _incomeCategories = ['Salary', 'Investment', 'Other'];
  List<String> _expenseCategories = ['Food', 'Transport', 'Bills', 'Shopping', 'Other'];

  List<String> get incomeCategories => _incomeCategories;
  List<String> get expenseCategories => _expenseCategories;

  void addCategory(String type, String category) {
    if (type == 'income') {
      if (!_incomeCategories.contains(category)) {
        _incomeCategories.add(category);
      }
    } else {
      if (!_expenseCategories.contains(category)) {
        _expenseCategories.add(category);
      }
    }
    _notifyAndSync();
  }

  void deleteCategory(String type, String category) {
    if (type == 'income') {
      _incomeCategories.remove(category);
    } else {
      _expenseCategories.remove(category);
    }
    _notifyAndSync();
  }

  Future<void> addWallet(Wallet wallet) async {
    _wallets.add(wallet);
    await _storage.saveWallets(_wallets);
    _notifyAndSync();
  }

  Future<void> deleteWallet(String id) async {
    _wallets.removeWhere((w) => w.id == id);
    _transactions.removeWhere((tx) => tx.walletId == id);
    await _storage.saveTransactions(_transactions);
    await _storage.saveWallets(_wallets);
    _notifyAndSync();
  }

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
    _biometricEnabled = await _storage.isBiometricEnabled();
    _pinHash = await _storage.getPinHash();
    _transactions = await _storage.loadTransactions();
    _budgets = await _storage.loadBudgets();
    _goals = await _storage.loadGoals();
    _wallets = await _storage.loadWallets();
    _overallMonthlyBudget = await _storage.getOverallMonthlyBudget();
    _overallWeeklyBudget = await _storage.getOverallWeeklyBudget();
    _overallDailyBudget = await _storage.getOverallDailyBudget();
    _piggyBankBalance = await _storage.getPiggyBankBalance();
    _incognitoEnabled = await _storage.isIncognitoEnabled();
    _selfDestructEnabled = await _storage.isSelfDestructEnabled();

    await processRecurringTransactions();
    notifyListeners();
  }

  Future<void> updateIncognitoEnabled(bool val) async {
    await _storage.setIncognitoEnabled(val);
    _incognitoEnabled = val;
    _notifyAndSync();
  }

  Future<void> updateSelfDestructEnabled(bool val) async {
    await _storage.setSelfDestructEnabled(val);
    _selfDestructEnabled = val;
    _notifyAndSync();
  }

  Future<void> wipeAllData() async {
    await _storage.saveTransactions([]);
    await _storage.saveBudgets([]);
    await _storage.saveGoals([]);
    await _storage.saveWallets([
      Wallet(id: 'cash', name: 'Cash Wallet', balance: 0.0, type: 'Cash'),
      Wallet(id: 'bank', name: 'Bank Account', balance: 0.0, type: 'Bank'),
      Wallet(id: 'card', name: 'Credit Card', balance: 0.0, type: 'Card'),
    ]);
    await disablePin();
    await updateBiometricEnabled(false);
    await updateOverallMonthlyBudget(0.0);
    await updateOverallWeeklyBudget(0.0);
    await updateOverallDailyBudget(0.0);
    _piggyBankBalance = 0.0;
    await _storage.setPiggyBankBalance(0.0);
    _incognitoEnabled = false;
    await _storage.setIncognitoEnabled(false);
    _selfDestructEnabled = false;
    await _storage.setSelfDestructEnabled(false);

    await init();
  }

  Future<void> addToPiggyBank(double amount) async {
    _piggyBankBalance += amount;
    await _storage.setPiggyBankBalance(_piggyBankBalance);
    
    // Deduct from Cash Wallet
    final cashIdx = _wallets.indexWhere((w) => w.id == 'cash');
    if (cashIdx != -1) {
      _wallets[cashIdx] = _wallets[cashIdx].copyWith(balance: _wallets[cashIdx].balance - amount);
      await _storage.saveWallets(_wallets);
    }
    _notifyAndSync();
  }

  Future<void> clearPiggyBank() async {
    // Return piggy bank balance back to Cash wallet
    final cashIdx = _wallets.indexWhere((w) => w.id == 'cash');
    if (cashIdx != -1) {
      _wallets[cashIdx] = _wallets[cashIdx].copyWith(balance: _wallets[cashIdx].balance + _piggyBankBalance);
      await _storage.saveWallets(_wallets);
    }
    _piggyBankBalance = 0.0;
    await _storage.setPiggyBankBalance(0.0);
    _notifyAndSync();
  }

  Future<void> updateOverallMonthlyBudget(double val) async {
    await _storage.setOverallMonthlyBudget(val);
    _overallMonthlyBudget = val;
    _notifyAndSync();
  }

  Future<void> updateOverallWeeklyBudget(double val) async {
    await _storage.setOverallWeeklyBudget(val);
    _overallWeeklyBudget = val;
    _notifyAndSync();
  }

  Future<void> updateOverallDailyBudget(double val) async {
    await _storage.setOverallDailyBudget(val);
    _overallDailyBudget = val;
    _notifyAndSync();
  }

  // Helper to notify listeners and sync automatically to Firestore
  void _notifyAndSync() {
    notifyListeners();
    syncToCloud();
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
    _notifyAndSync();
  }

  Future<void> disablePin() async {
    await _storage.setPinHash('');
    await _storage.setPinEnabled(false);
    _pinHash = '';
    _pinEnabled = false;
    _notifyAndSync();
  }

  Future<void> updateBiometricEnabled(bool val) async {
    await _storage.setBiometricEnabled(val);
    _biometricEnabled = val;
    _notifyAndSync();
  }

  Future<void> updateCurrency(String newCurrency) async {
    await _storage.setCurrency(newCurrency);
    _currency = newCurrency;
    _notifyAndSync();
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
      } else if (transaction.type == 'expense') {
        newBalance -= transaction.amount;
      } else if (transaction.type == 'transfer') {
        newBalance -= transaction.amount;
      }
      _wallets[walletIdx] = wallet.copyWith(balance: newBalance);
      await _storage.saveWallets(_wallets);
    }

    // For transfers, update destination wallet too
    if (transaction.type == 'transfer' && transaction.toWalletId != null) {
      final toWalletIdx = _wallets.indexWhere((w) => w.id == transaction.toWalletId);
      if (toWalletIdx != -1) {
        final toWallet = _wallets[toWalletIdx];
        _wallets[toWalletIdx] = toWallet.copyWith(balance: toWallet.balance + transaction.amount);
        await _storage.saveWallets(_wallets);
      }
    }

    // Spare Change Auto-Save: Round up expense to nearest 100 LKR/USD
    if (transaction.type == 'expense') {
      final double nextHundred = ((transaction.amount / 100).ceil() * 100).toDouble();
      final double spareChange = nextHundred - transaction.amount;
      if (spareChange > 0 && spareChange < 100) {
        _piggyBankBalance += spareChange;
        await _storage.setPiggyBankBalance(_piggyBankBalance);
        
        if (walletIdx != -1) {
          final wallet = _wallets[walletIdx];
          _wallets[walletIdx] = wallet.copyWith(balance: wallet.balance - spareChange);
          await _storage.saveWallets(_wallets);
        }
      }
    }

    await _storage.saveTransactions(_transactions);
    _notifyAndSync();
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
        } else if (transaction.type == 'expense') {
          newBalance += transaction.amount;
        } else if (transaction.type == 'transfer') {
          newBalance += transaction.amount;
        }
        _wallets[walletIdx] = wallet.copyWith(balance: newBalance);
        await _storage.saveWallets(_wallets);
      }

      // Reverse destination wallet for transfers
      if (transaction.type == 'transfer' && transaction.toWalletId != null) {
        final toWalletIdx = _wallets.indexWhere((w) => w.id == transaction.toWalletId);
        if (toWalletIdx != -1) {
          final toWallet = _wallets[toWalletIdx];
          _wallets[toWalletIdx] = toWallet.copyWith(balance: toWallet.balance - transaction.amount);
          await _storage.saveWallets(_wallets);
        }
      }

      _transactions.removeAt(idx);
      await _storage.saveTransactions(_transactions);
      _notifyAndSync();
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
    _notifyAndSync();
  }

  Future<void> deleteBudget(String category) async {
    _budgets.removeWhere((b) => b.category == category);
    await _storage.saveBudgets(_budgets);
    _notifyAndSync();
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
    _notifyAndSync();
  }

  Future<void> updateGoalProgress(String id, double addAmount) async {
    final idx = _goals.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final goal = _goals[idx];
      _goals[idx] = goal.copyWith(currentAmount: goal.currentAmount + addAmount);

      final cashIdx = _wallets.indexWhere((w) => w.id == 'cash');
      if (cashIdx != -1) {
        _wallets[cashIdx] = _wallets[cashIdx].copyWith(balance: _wallets[cashIdx].balance - addAmount);
        await _storage.saveWallets(_wallets);
      }

      await _storage.saveGoals(_goals);
      _notifyAndSync();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _storage.saveGoals(_goals);
    _notifyAndSync();
  }

  // Wallet Actions
  Future<void> setWalletBalance(String id, double newBalance) async {
    final idx = _wallets.indexWhere((w) => w.id == id);
    if (idx != -1) {
      _wallets[idx] = _wallets[idx].copyWith(balance: newBalance);
      await _storage.saveWallets(_wallets);
      _notifyAndSync();
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
      final recurringTemplates = _transactions.where((t) => t.isRecurring).toList();

      for (var template in recurringTemplates) {
        DateTime nextDate = template.date;
        while (true) {
          if (template.recurrenceInterval == 'daily') {
            nextDate = nextDate.add(const Duration(days: 1));
          } else if (template.recurrenceInterval == 'weekly') {
            nextDate = nextDate.add(const Duration(days: 7));
          } else if (template.recurrenceInterval == 'monthly') {
            nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          } else {
            break;
          }

          if (nextDate.isAfter(now)) {
            break;
          }

          if (nextDate.isAfter(lastCheck)) {
            final newTx = Transaction(
              id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + nextDate.millisecondsSinceEpoch.toString(),
              title: template.title,
              amount: template.amount,
              type: template.type,
              category: template.category,
              date: nextDate,
              walletId: template.walletId,
              isRecurring: false,
              recurrenceInterval: 'none',
            );
            _transactions.add(newTx);

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

  // Cloud Sync to Firestore
  Future<void> syncToCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final backupData = await exportBackup();
        final Map<String, dynamic> dataMap = jsonDecode(backupData);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
              'data': dataMap,
              'synced_at': FieldValue.serverTimestamp(),
            });
      } catch (e) {
        // Silently fail or handle log
      }
    }
  }

  // Cloud Restore from Firestore
  Future<bool> syncFromCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!['data'];
          if (data != null) {
            final jsonStr = jsonEncode(data);
            final success = await importBackup(jsonStr);
            if (success) {
              notifyListeners();
              return true;
            }
          }
        }
      } catch (e) {
        // Silently fail or log
      }
    }
    return false;
  }
}
