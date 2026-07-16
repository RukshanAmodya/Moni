class Transaction {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income', 'expense', or 'transfer'
  final String category;
  final DateTime date;
  final String walletId;
  final bool isRecurring;
  final String recurrenceInterval; // 'none', 'daily', 'weekly', 'monthly'
  final String? toWalletId; // Target wallet for transfers
  final List<String> tags; // Custom tags e.g. ['#Trip2026', '#Medical']
  final String? attachmentPath; // Local file path for uploaded bills/receipts
  final String? location; // GPS or text location
  final bool isPending; // Pending transaction marker
  final String? refundLinkedTxId; // Original transaction ID if this is a refund

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.walletId,
    this.isRecurring = false,
    this.recurrenceInterval = 'none',
    this.toWalletId,
    this.tags = const [],
    this.attachmentPath,
    this.location,
    this.isPending = false,
    this.refundLinkedTxId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date.toIso8601String(),
        'walletId': walletId,
        'isRecurring': isRecurring,
        'recurrenceInterval': recurrenceInterval,
        'toWalletId': toWalletId,
        'tags': tags,
        'attachmentPath': attachmentPath,
        'location': location,
        'isPending': isPending,
        'refundLinkedTxId': refundLinkedTxId,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        type: json['type'],
        category: json['category'],
        date: DateTime.parse(json['date']),
        walletId: json['walletId'],
        isRecurring: json['isRecurring'] ?? false,
        recurrenceInterval: json['recurrenceInterval'] ?? 'none',
        toWalletId: json['toWalletId'],
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        attachmentPath: json['attachmentPath'],
        location: json['location'],
        isPending: json['isPending'] ?? false,
        refundLinkedTxId: json['refundLinkedTxId'],
      );
}

class Budget {
  final String category;
  final double limitAmount;

  Budget({
    required this.category,
    required this.limitAmount,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'limitAmount': limitAmount,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        category: json['category'],
        limitAmount: (json['limitAmount'] as num).toDouble(),
      );
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        id: json['id'],
        name: json['name'],
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentAmount: (json['currentAmount'] as num).toDouble(),
      );

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
    );
  }
}

class Wallet {
  final String id;
  final String name;
  final double balance;
  final String type; // 'Cash', 'Bank', 'Card'

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'balance': balance,
        'type': type,
      };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'],
        name: json['name'],
        balance: (json['balance'] as num).toDouble(),
        type: json['type'],
      );

  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    String? type,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
    );
  }
}
