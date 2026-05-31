import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';
import '../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key, required this.transactions});

  final List<WalletTransaction> transactions;

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  TransactionKind? _filter;

  List<WalletTransaction> get _visibleTransactions {
    if (_filter == null) {
      return widget.transactions;
    }
    return widget.transactions.where((txn) => txn.kind == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _visibleTransactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Transaction history',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              ChoiceChip(
                label: const Text('Money in'),
                selected: _filter == TransactionKind.credit,
                onSelected: (_) {
                  setState(() => _filter = TransactionKind.credit);
                },
              ),
              ChoiceChip(
                label: const Text('Money out'),
                selected: _filter == TransactionKind.debit,
                onSelected: (_) {
                  setState(() => _filter = TransactionKind.debit);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE3F5F2)),
              ),
              child: const Text('No transactions found for this filter.'),
            )
          else
            ...transactions.map(TransactionTile.new),
        ],
      ),
    );
  }
}
