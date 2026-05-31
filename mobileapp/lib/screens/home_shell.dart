import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/auth_session.dart';
import '../models/realtime_transaction_event.dart';
import '../models/wallet_snapshot.dart';
import '../models/wallet_transaction.dart';
import '../services/kyfr_api.dart';
import '../services/realtime_client.dart';
import 'dashboard_screen.dart';
import 'insights_screen.dart';
import 'send_money_screen.dart';
import 'transaction_history_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.session,
    required this.apiClient,
    required this.realtimeClient,
    required this.onLogout,
  });

  final AuthSession session;
  final KyfrApi apiClient;
  final RealtimeClient realtimeClient;
  final Future<void> Function() onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  double _balance = 0;
  bool _isLoadingWallet = true;
  bool _isAddingMoney = false;
  bool _isSendingMoney = false;
  String? _walletError;
  late final PageController _pageController;

  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadWallet();
    _connectRealtimeUpdates();
  }

  @override
  void dispose() {
    widget.realtimeClient.disconnect();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadWallet({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoadingWallet = true;
        _walletError = null;
      });
    }

    try {
      final snapshot = await widget.apiClient.fetchWallet(widget.session.token);
      if (!mounted) {
        return;
      }
      setState(() {
        _applySnapshot(snapshot);
        _isLoadingWallet = false;
        _walletError = null;
      });
    } catch (error) {
      if (!mounted || silent) {
        return;
      }
      setState(() {
        _isLoadingWallet = false;
        _walletError = _messageForError(error);
      });
    }
  }

  Future<void> _connectRealtimeUpdates() async {
    try {
      await widget.realtimeClient.connect(
        token: widget.session.token,
        onTransaction: _handleRealtimeEvent,
      );
    } catch (_) {
      // Real-time is additive; normal API calls still keep the app functional.
    }
  }

  void _handleRealtimeEvent(RealtimeTransactionEvent event) {
    if (!mounted) {
      return;
    }

    final transaction = event.transaction;
    setState(() {
      if (event.balance != null) {
        _balance = event.balance!;
      }
      if (transaction != null &&
          !_transactions.any((item) => item.id == transaction.id)) {
        _transactions = [transaction, ..._transactions];
      }
    });

    if (transaction == null) {
      _loadWallet(silent: true);
    }
  }

  void _applySnapshot(WalletSnapshot snapshot) {
    _balance = snapshot.balance;
    _transactions = snapshot.transactions;
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

  String _messageForError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _addMoney(double amount) async {
    if (_isAddingMoney) {
      return;
    }

    setState(() {
      _isAddingMoney = true;
    });

    try {
      final snapshot = await widget.apiClient.addMoney(
        token: widget.session.token,
        amount: amount,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _applySnapshot(snapshot);
      });
      _showMessage('Rs ${amount.toStringAsFixed(0)} added to your wallet');
    } catch (error) {
      if (mounted) {
        _showMessage(_messageForError(error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingMoney = false;
        });
      }
    }
  }

  Future<String?> _sendMoney(
    String recipient,
    double amount,
    String note,
  ) async {
    if (_isSendingMoney) {
      return 'A transfer is already in progress.';
    }
    if (amount > _balance) {
      return 'Insufficient wallet balance';
    }

    setState(() {
      _isSendingMoney = true;
    });

    try {
      final snapshot = await widget.apiClient.transferMoney(
        token: widget.session.token,
        recipientEmail: recipient,
        amount: amount,
        note: note,
      );
      if (!mounted) {
        return null;
      }
      setState(() {
        _applySnapshot(snapshot);
      });
      _showMessage('Transfer successful');
      return null;
    } catch (error) {
      return _messageForError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMoney = false;
        });
      }
    }
  }

  Future<String> _loadInsight() {
    return widget.apiClient.fetchWeeklyInsight(token: widget.session.token);
  }

  Future<void> _handleLogout() async {
    await widget.onLogout();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const _AppLogoTitle(),
      actions: [
        IconButton(
          tooltip: 'Logout',
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingWallet) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_walletError != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    _walletError!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _loadWallet(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final pages = [
      DashboardScreen(
        key: const PageStorageKey('dashboard-screen'),
        userName: widget.session.userName,
        balance: _balance,
        recentTransactions: _transactions.take(3).toList(),
        isAddingMoney: _isAddingMoney,
        onAddMoney: _addMoney,
        onSendMoney: _goToSendMoney,
        onLoadInsight: _loadInsight,
      ),
      SendMoneyScreen(
        key: const PageStorageKey('send-money-screen'),
        balance: _balance,
        isSubmitting: _isSendingMoney,
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
      appBar: _buildAppBar(),
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

class _AppLogoTitle extends StatelessWidget {
  const _AppLogoTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      height: 34,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF134E4A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SvgPicture.asset(
        'assets/images/kyfrlogo.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}
