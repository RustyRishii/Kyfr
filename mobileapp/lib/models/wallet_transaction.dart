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
}
