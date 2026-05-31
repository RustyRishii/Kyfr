import 'wallet_transaction.dart';

class WalletSnapshot {
  const WalletSnapshot({required this.balance, required this.transactions});

  final double balance;
  final List<WalletTransaction> transactions;

  factory WalletSnapshot.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'];
    if (rawTransactions is! List) {
      throw const FormatException('Wallet response is missing transactions');
    }

    return WalletSnapshot(
      balance: (json['balance'] as num).toDouble(),
      transactions: rawTransactions
          .map(
            (transaction) =>
                WalletTransaction.fromJson(transaction as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
