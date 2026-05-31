import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile(this.transaction, {super.key});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isCredit
        ? const Color(0xFF15803D)
        : const Color(0xFFB91C1C);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3F5F2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: amountColor.withValues(alpha: 0.12),
            child: Icon(
              transaction.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: amountColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.subtitle} - ${transaction.statusLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            transaction.amountLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
