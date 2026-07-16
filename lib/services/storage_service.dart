import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/finance_models.dart';

class StorageService {
  static const String _transactionsFile = 'moni_transactions.json';
  static const String _budgetsFile = 'moni_budgets.json';
  static const String _goalsFile = 'moni_goals.json';
  static const String _walletsFile = 'moni_wallets.json';

  static const String keyCurrency = 'moni_currency';
  static const String keyPinEnabled = 'moni_pin_enabled';
  static const String keyPinHash = 'moni_pin_hash';
  static const String keyLastRecurringCheck = 'moni_last_recurring_check';

  // Get local path for files
  Future<File> _getFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  // Generic file saving
  Future<void> _saveToFile(String filename, String content) async {
    final file = await _getFile(filename);
    await file.writeAsString(content);
  }

  // Generic file reading
  Future<String> _readFromFile(String filename) async {
    try {
      final file = await _getFile(filename);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      // Log or handle error
    }
    return '';
  }

  // Load Transactions
  Future<List<Transaction>> loadTransactions() async {
    final content = await _readFromFile(_transactionsFile);
    if (content.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(content);
      return decoded.map((item) => Transaction.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save Transactions
  Future<void> saveTransactions(List<Transaction> transactions) async {
    final content = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await _saveToFile(_transactionsFile, content);
  }

  // Load Budgets
  Future<List<Budget>> loadBudgets() async {
    final content = await _readFromFile(_budgetsFile);
    if (content.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(content);
      return decoded.map((item) => Budget.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save Budgets
  Future<void> saveBudgets(List<Budget> budgets) async {
    final content = jsonEncode(budgets.map((b) => b.toJson()).toList());
    await _saveToFile(_budgetsFile, content);
  }

  // Load Goals
  Future<List<SavingsGoal>> loadGoals() async {
    final content = await _readFromFile(_goalsFile);
    if (content.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(content);
      return decoded.map((item) => SavingsGoal.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save Goals
  Future<void> saveGoals(List<SavingsGoal> goals) async {
    final content = jsonEncode(goals.map((g) => g.toJson()).toList());
    await _saveToFile(_goalsFile, content);
  }

  // Load Wallets
  Future<List<Wallet>> loadWallets() async {
    final content = await _readFromFile(_walletsFile);
    if (content.isEmpty) {
      // Default Wallets
      return [
        Wallet(id: 'cash', name: 'Cash Wallet', balance: 0.0, type: 'Cash'),
        Wallet(id: 'bank', name: 'Bank Account', balance: 0.0, type: 'Bank'),
        Wallet(id: 'card', name: 'Credit Card', balance: 0.0, type: 'Card'),
      ];
    }
    try {
      final List<dynamic> decoded = jsonDecode(content);
      return decoded.map((item) => Wallet.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save Wallets
  Future<void> saveWallets(List<Wallet> wallets) async {
    final content = jsonEncode(wallets.map((w) => w.toJson()).toList());
    await _saveToFile(_walletsFile, content);
  }

  // Settings SharedPreferences
  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyCurrency) ?? 'LKR';
  }

  Future<void> setCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCurrency, value);
  }

  Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyPinEnabled) ?? false;
  }

  Future<void> setPinEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyPinEnabled, value);
  }

  Future<String> getPinHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPinHash) ?? '';
  }

  Future<void> setPinHash(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPinHash, value);
  }

  Future<String?> getLastRecurringCheck() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastRecurringCheck);
  }

  Future<void> setLastRecurringCheck(String dateStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastRecurringCheck, dateStr);
  }

  // Backup data as a single JSON map string
  Future<String> exportBackupData() async {
    final transactions = await loadTransactions();
    final budgets = await loadBudgets();
    final goals = await loadGoals();
    final wallets = await loadWallets();

    final backup = {
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
      'wallets': wallets.map((w) => w.toJson()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };

    return jsonEncode(backup);
  }

  // Restore data from JSON string
  Future<bool> importBackupData(String jsonString) async {
    try {
      final Map<String, dynamic> backup = jsonDecode(jsonString);
      if (backup.containsKey('transactions')) {
        final List<dynamic> txs = backup['transactions'];
        final transactions = txs.map((item) => Transaction.fromJson(item)).toList();
        await saveTransactions(transactions);
      }
      if (backup.containsKey('budgets')) {
        final List<dynamic> bgs = backup['budgets'];
        final budgets = bgs.map((item) => Budget.fromJson(item)).toList();
        await saveBudgets(budgets);
      }
      if (backup.containsKey('goals')) {
        final List<dynamic> gls = backup['goals'];
        final goals = gls.map((item) => SavingsGoal.fromJson(item)).toList();
        await saveGoals(goals);
      }
      if (backup.containsKey('wallets')) {
        final List<dynamic> wls = backup['wallets'];
        final wallets = wls.map((item) => Wallet.fromJson(item)).toList();
        await saveWallets(wallets);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
