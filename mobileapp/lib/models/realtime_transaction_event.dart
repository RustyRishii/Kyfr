import 'wallet_transaction.dart';

class RealtimeTransactionEvent {
  const RealtimeTransactionEvent({
    required this.amount,
    required this.status,
    this.balance,
    this.transaction,
  });

  final double amount;
  final String status;
  final double? balance;
  final WalletTransaction? transaction;

  factory RealtimeTransactionEvent.fromJson(Map<String, dynamic> json) {
    final transactionJson = json['transaction'];

    return RealtimeTransactionEvent(
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      balance: (json['balance'] as num?)?.toDouble(),
      transaction: transactionJson is Map<String, dynamic>
          ? WalletTransaction.fromJson(transactionJson)
          : null,
    );
  }
}
