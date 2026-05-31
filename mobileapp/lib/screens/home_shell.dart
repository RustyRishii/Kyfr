import 'package:flutter/material.dart';

import '../models/wallet_transaction.dart';
import 'dashboard_screen.dart';
import 'insights_screen.dart';
import 'send_money_screen.dart';
import 'transaction_history_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.userName, required this.onLogout});

  final String userName;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  double _balance = 12500;
  late final PageController _pageController;

  final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 'txn-003',
      title: 'Sent to Priya',
      subtitle: 'Transfer',
      amount: 850,
      kind: TransactionKind.debit,
      status: TransactionStatus.success,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    WalletTransaction(
      id: 'txn-002',
      title: 'Added money',
      subtitle: 'Wallet top up',
      amount: 5000,
      kind: TransactionKind.credit,
      status: TransactionStatus.success,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WalletTransaction(
      id: 'txn-001',
      title: 'Sent to Aman',
      subtitle: 'Transfer',
      amount: 1200,
      kind: TransactionKind.debit,
      status: TransactionStatus.success,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToSendMoney() {
    _selectTab(1);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _addMoney(double amount) {
    setState(() {
      _balance += amount;
      _transactions.insert(
        0,
        WalletTransaction(
          id: 'txn-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Added money',
          subtitle: 'Wallet top up',
          amount: amount,
          kind: TransactionKind.credit,
          status: TransactionStatus.success,
          createdAt: DateTime.now(),
        ),
      );
    });
    _showMessage('Rs ${amount.toStringAsFixed(0)} added to your wallet');
  }

  String? _sendMoney(String recipient, double amount, String note) {
    if (amount > _balance) {
      return 'Insufficient wallet balance';
    }

    setState(() {
      _balance -= amount;
      _transactions.insert(
        0,
        WalletTransaction(
          id: 'txn-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Sent to $recipient',
          subtitle: note.isEmpty ? 'Transfer' : note,
          amount: amount,
          kind: TransactionKind.debit,
          status: TransactionStatus.success,
          createdAt: DateTime.now(),
        ),
      );
    });
    _showMessage('Transfer successful');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        key: const PageStorageKey('dashboard-screen'),
        userName: widget.userName,
        balance: _balance,
        recentTransactions: _transactions.take(3).toList(),
        onAddMoney: _addMoney,
        onSendMoney: _goToSendMoney,
      ),
      SendMoneyScreen(
        key: const PageStorageKey('send-money-screen'),
        balance: _balance,
        onSendMoney: _sendMoney,
      ),
      TransactionHistoryScreen(
        key: const PageStorageKey('transaction-history-screen'),
        transactions: _transactions,
      ),
      InsightsScreen(
        key: const PageStorageKey('insights-screen'),
        balance: _balance,
        transactions: _transactions,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kyfr'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            if (index != _selectedIndex) {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send),
            label: 'Send',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}
