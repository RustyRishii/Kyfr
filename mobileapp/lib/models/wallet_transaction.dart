enum TransactionKind { credit, debit }

enum TransactionStatus { success, pending, failed }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.kind,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionKind kind;
  final TransactionStatus status;
  final DateTime createdAt;

  bool get isCredit => kind == TransactionKind.credit;

  String get amountLabel {
    final prefix = isCredit ? '+' : '-';
    return '$prefix Rs ${amount.toStringAsFixed(0)}';
  }

  String get statusLabel {
    return switch (status) {
      TransactionStatus.success => 'Success',
      TransactionStatus.pending => 'Pending',
      TransactionStatus.failed => 'Failed',
    };
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      kind: _transactionKindFromJson(json['kind'] as String),
      status: _transactionStatusFromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

TransactionKind _transactionKindFromJson(String value) {
  return switch (value.toLowerCase()) {
    'credit' => TransactionKind.credit,
    'debit' => TransactionKind.debit,
    _ => throw FormatException('Unknown transaction kind: $value'),
  };
}

TransactionStatus _transactionStatusFromJson(String value) {
  return switch (value.toLowerCase()) {
    'success' => TransactionStatus.success,
    'pending' => TransactionStatus.pending,
    'failed' => TransactionStatus.failed,
    _ => throw FormatException('Unknown transaction status: $value'),
  };
}
