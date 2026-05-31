import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    super.key,
    required this.balance,
    required this.transactions,
  });

  final double balance;
  final List<WalletTransaction> transactions;

  double get _moneyIn {
    return transactions
        .where((txn) => txn.kind == TransactionKind.credit)
        .fold<double>(0, (total, txn) => total + txn.amount);
  }

  double get _moneyOut {
    return transactions
        .where((txn) => txn.kind == TransactionKind.debit)
        .fold<double>(0, (total, txn) => total + txn.amount);
  }

  @override
  Widget build(BuildContext context) {
    final moneyIn = _moneyIn;
    final moneyOut = _moneyOut;
    final totalActivity = moneyIn + moneyOut;
    final transferShare = totalActivity == 0 ? 0.0 : moneyOut / totalActivity;
    final message = moneyOut > 0
        ? 'You spent most of your money on transfers this week.'
        : 'Add or send money to unlock your first spending insight.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Insights',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _InsightCard(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Current balance',
            value: 'Rs ${balance.toStringAsFixed(0)}',
          ),
          _InsightCard(
            icon: Icons.south_west,
            title: 'Money added',
            value: 'Rs ${moneyIn.toStringAsFixed(0)}',
          ),
          _InsightCard(
            icon: Icons.north_east,
            title: 'Money sent',
            value: 'Rs ${moneyOut.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE3F5F2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer share',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: transferShare.clamp(0, 1),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(transferShare * 100).toStringAsFixed(0)}% of wallet activity is outgoing transfers.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3F5F2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
