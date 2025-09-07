import 'package:flutter/foundation.dart';

enum TransactionType {
  credit,
  debit,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

enum PaymentMethod {
  upi,
  creditCard,
  debitCard,
  netBanking,
  wallet,
  bankTransfer,
}

enum TransactionCategory {
  challengeEntry,
  challengeWinnings,
  addFunds,
  withdrawal,
  referralBonus,
  activityReward,
  zenCoinsPurchase,
  zenCoinsEarned,
}

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionCategory category;
  final PaymentMethod? paymentMethod;
  final String description;
  final DateTime timestamp;
  final String? referenceId;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.status,
    required this.category,
    this.paymentMethod,
    required this.description,
    required this.timestamp,
    this.referenceId,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == 'TransactionCategory.${json['category']}',
      ),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
            )
          : null,
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      referenceId: json['referenceId'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'category': category.toString().split('.').last,
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'referenceId': referenceId,
      'metadata': metadata,
    };
  }
}

class Wallet {
  final String userId;
  final double balance;
  final int zenCoins;
  final List<Transaction> transactions;
  final List<ReferralBonus> referralBonuses;
  final List<ActivityReward> activityRewards;

  Wallet({
    required this.userId,
    required this.balance,
    required this.zenCoins,
    required this.transactions,
    required this.referralBonuses,
    required this.activityRewards,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: json['userId'],
      balance: json['balance'].toDouble(),
      zenCoins: json['zenCoins'],
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      referralBonuses: (json['referralBonuses'] as List)
          .map((r) => ReferralBonus.fromJson(r))
          .toList(),
      activityRewards: (json['activityRewards'] as List)
          .map((a) => ActivityReward.fromJson(a))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'zenCoins': zenCoins,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'referralBonuses': referralBonuses.map((r) => r.toJson()).toList(),
      'activityRewards': activityRewards.map((a) => a.toJson()).toList(),
    };
  }
}

class ReferralBonus {
  final String id;
  final String referredUserId;
  final String referredUserName;
  final double bonusAmount;
  final int zenCoinsBonus;
  final DateTime timestamp;
  bool isClaimed;

  ReferralBonus({
    required this.id,
    required this.referredUserId,
    required this.referredUserName,
    required this.bonusAmount,
    required this.zenCoinsBonus,
    required this.timestamp,
    required this.isClaimed,
  });

  factory ReferralBonus.fromJson(Map<String, dynamic> json) {
    return ReferralBonus(
      id: json['id'],
      referredUserId: json['referredUserId'],
      referredUserName: json['referredUserName'],
      bonusAmount: json['bonusAmount'].toDouble(),
      zenCoinsBonus: json['zenCoinsBonus'],
      timestamp: DateTime.parse(json['timestamp']),
      isClaimed: json['isClaimed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referredUserId': referredUserId,
      'referredUserName': referredUserName,
      'bonusAmount': bonusAmount,
      'zenCoinsBonus': zenCoinsBonus,
      'timestamp': timestamp.toIso8601String(),
      'isClaimed': isClaimed,
    };
  }
}

class ActivityReward {
  final String id;
  final String activityType;
  final String description;
  final int zenCoinsEarned;
  final DateTime timestamp;
  bool isClaimed;

  ActivityReward({
    required this.id,
    required this.activityType,
    required this.description,
    required this.zenCoinsEarned,
    required this.timestamp,
    required this.isClaimed,
  });

  factory ActivityReward.fromJson(Map<String, dynamic> json) {
    return ActivityReward(
      id: json['id'],
      activityType: json['activityType'],
      description: json['description'],
      zenCoinsEarned: json['zenCoinsEarned'],
      timestamp: DateTime.parse(json['timestamp']),
      isClaimed: json['isClaimed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityType': activityType,
      'description': description,
      'zenCoinsEarned': zenCoinsEarned,
      'timestamp': timestamp.toIso8601String(),
      'isClaimed': isClaimed,
    };
  }
}

 