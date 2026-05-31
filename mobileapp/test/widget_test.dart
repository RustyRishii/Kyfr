import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kyfr/main.dart';
import 'package:kyfr/models/auth_session.dart';
import 'package:kyfr/models/wallet_snapshot.dart';
import 'package:kyfr/models/wallet_transaction.dart';
import 'package:kyfr/services/kyfr_api.dart';
import 'package:kyfr/services/realtime_client.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {FakeKyfrApi? api}) async {
    await tester.pumpWidget(
      KyfrApp(
        apiClient: api ?? FakeKyfrApi(),
        realtimeClient: const NoopRealtimeClient(),
      ),
    );
  }

  Future<void> login(WidgetTester tester, {FakeKyfrApi? api}) async {
    await pumpApp(tester, api: api);

    await tester.tap(find.text('Login').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).at(0), 'rishi@test.com');
    await tester.enterText(find.byType(EditableText).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  testWidgets('Shows signup by default on the authentication screen', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Create your wallet'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Signup'), findsOneWidget);
  });

  testWidgets('Can add money from the dashboard using the API layer', (
    WidgetTester tester,
  ) async {
    await login(tester);

    expect(find.text('Rs 12500'), findsOneWidget);

    await tester.tap(find.text('Add money'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).last, '500');
    await tester.tap(find.text('Add to wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Rs 13000'), findsOneWidget);
  });

  testWidgets('Send money requires valid email and amount', (
    WidgetTester tester,
  ) async {
    await login(tester);

    await tester.tap(find.text('Send').last);
    await tester.pumpAndSettle();

    ElevatedButton button() {
      return tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Send money'),
      );
    }

    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(EditableText).at(0), 'not-an-email');
    await tester.enterText(find.byType(EditableText).at(1), '100');
    await tester.pump();

    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(EditableText).at(0), 'priya@test.com');
    await tester.pump();

    expect(button().onPressed, isNotNull);

    await tester.enterText(find.byType(EditableText).at(1), '12.3.4');
    await tester.pump();

    expect(find.text('12.3.4'), findsNothing);
  });
}

class FakeKyfrApi implements KyfrApi {
  double _balance = 12500;
  final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 'txn-003',
      title: 'Sent to Priya',
      subtitle: 'Transfer',
      amount: 850,
      kind: TransactionKind.debit,
      status: TransactionStatus.success,
      createdAt: DateTime(2026, 5, 31, 10),
    ),
    WalletTransaction(
      id: 'txn-002',
      title: 'Added money',
      subtitle: 'Wallet top up',
      amount: 5000,
      kind: TransactionKind.credit,
      status: TransactionStatus.success,
      createdAt: DateTime(2026, 5, 30, 10),
    ),
    WalletTransaction(
      id: 'txn-001',
      title: 'Sent to Aman',
      subtitle: 'Transfer',
      amount: 1200,
      kind: TransactionKind.debit,
      status: TransactionStatus.success,
      createdAt: DateTime(2026, 5, 29, 10),
    ),
  ];

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return AuthSession(
      token: 'test-token',
      userId: 'user-test',
      userName: 'Rishi',
      email: email,
    );
  }

  @override
  Future<AuthSession> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    return AuthSession(
      token: 'test-token',
      userId: 'user-test',
      userName: name,
      email: email,
    );
  }

  @override
  Future<double> fetchBalance(String token) async => _balance;

  @override
  Future<WalletSnapshot> fetchWallet(String token) async {
    return WalletSnapshot(balance: _balance, transactions: [..._transactions]);
  }

  @override
  Future<WalletSnapshot> addMoney({
    required String token,
    required double amount,
  }) async {
    _balance += amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: 'txn-added',
        title: 'Added money',
        subtitle: 'Wallet top up',
        amount: amount,
        kind: TransactionKind.credit,
        status: TransactionStatus.success,
        createdAt: DateTime(2026, 5, 31, 11),
      ),
    );
    return WalletSnapshot(balance: _balance, transactions: [..._transactions]);
  }

  @override
  Future<WalletSnapshot> transferMoney({
    required String token,
    required String recipientEmail,
    required double amount,
    required String note,
  }) async {
    if (amount > _balance) {
      throw const ApiException('Insufficient wallet balance');
    }
    _balance -= amount;
    _transactions.insert(
      0,
      WalletTransaction(
        id: 'txn-sent',
        title: 'Sent to $recipientEmail',
        subtitle: note.isEmpty ? 'Transfer' : note,
        amount: amount,
        kind: TransactionKind.debit,
        status: TransactionStatus.success,
        createdAt: DateTime(2026, 5, 31, 11),
      ),
    );
    return WalletSnapshot(balance: _balance, transactions: [..._transactions]);
  }

  @override
  Future<List<WalletTransaction>> fetchTransactions(String token) async {
    return [..._transactions];
  }

  @override
  Future<String> fetchWeeklyInsight({String? token}) async {
    return 'You spent most of your money on transfers this week';
  }

  @override
  void close() {}
}
