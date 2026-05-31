import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.userName,
    required this.balance,
    required this.recentTransactions,
    required this.isAddingMoney,
    required this.onAddMoney,
    required this.onSendMoney,
    required this.onLoadInsight,
  });

  final String userName;
  final double balance;
  final List<WalletTransaction> recentTransactions;
  final bool isAddingMoney;
  final Future<void> Function(double amount) onAddMoney;
  final VoidCallback onSendMoney;
  final Future<String> Function() onLoadInsight;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoadingInsight = true;
  String? _insightMessage;
  String? _insightError;

  @override
  void initState() {
    super.initState();
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    setState(() {
      _isLoadingInsight = true;
      _insightError = null;
    });

    try {
      final message = await widget.onLoadInsight();
      if (!mounted) {
        return;
      }
      setState(() {
        _insightMessage = message;
        _isLoadingInsight = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _insightError = 'Unable to load insights right now.';
        _isLoadingInsight = false;
      });
    }
  }

  Future<void> _openAddMoneySheet(BuildContext context) async {
    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _AddMoneySheet(),
    );

    if (amount != null) {
      await widget.onAddMoney(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hi, ${widget.userName}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F8F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3E7)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF0F766E),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet balance',
                        style: TextStyle(color: Color(0xFF58706C)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rs ${widget.balance.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: const Color(0xFF134E4A),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.isAddingMoney
                      ? null
                      : () => _openAddMoneySheet(context),
                  icon: widget.isAddingMoney
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: Text(widget.isAddingMoney ? 'Adding...' : 'Add money'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onSendMoney,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Send'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InsightMessageCard(
            isLoading: _isLoadingInsight,
            message: _insightMessage,
            error: _insightError,
            onRetry: _loadInsight,
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent activity',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                '${widget.recentTransactions.length} items',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.recentTransactions.isEmpty)
            const _EmptyState()
          else
            ...widget.recentTransactions.map(TransactionTile.new),
        ],
      ),
    );
  }
}

class _InsightMessageCard extends StatelessWidget {
  const _InsightMessageCard({
    required this.isLoading,
    required this.message,
    required this.error,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD3F4F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F8F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? const Text(
                      'Loading insight...',
                      key: ValueKey('insight-loading'),
                    )
                  : error != null
                  ? Text(
                      error!,
                      key: const ValueKey('insight-error'),
                      style: const TextStyle(color: Colors.black54),
                    )
                  : Text(
                      message ?? '',
                      key: const ValueKey('insight-message'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          if (error != null && !isLoading)
            IconButton(
              tooltip: 'Retry',
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
    );
  }
}

class _AddMoneySheet extends StatefulWidget {
  const _AddMoneySheet();

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(double.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add money',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rs ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add to wallet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('No transactions yet. Add or send money to begin.'),
    );
  }
}
