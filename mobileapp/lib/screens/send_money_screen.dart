import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({
    super.key,
    required this.balance,
    required this.isSubmitting,
    required this.onSendMoney,
  });

  final double balance;
  final bool isSubmitting;
  final Future<String?> Function(String recipient, double amount, String note)
  onSendMoney;

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isFormValid = false;

  static final _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final _linkPattern = RegExp(
    r'((https?:\/\/|www\.)\S+)|\b[A-Za-z0-9-]+\.(com|in|net|org|io|co|dev|app|ai)\b',
    caseSensitive: false,
  );
  static final _webPrefixPattern = RegExp(
    r'(https?:\/\/|www\.)',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    _recipientController.addListener(_updateFormValidity);
    _amountController.addListener(_updateFormValidity);
    _noteController.addListener(_updateFormValidity);
  }

  @override
  void dispose() {
    _recipientController.removeListener(_updateFormValidity);
    _amountController.removeListener(_updateFormValidity);
    _noteController.removeListener(_updateFormValidity);
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateFormValidity() {
    final isValid =
        _validateRecipient(_recipientController.text) == null &&
        _validateAmount(_amountController.text) == null &&
        _validateNote(_noteController.text) == null;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _submit() async {
    if (!_isFormValid || widget.isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final error = await widget.onSendMoney(
      _recipientController.text.trim(),
      double.parse(_amountController.text.trim()),
      _noteController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    _recipientController.clear();
    _amountController.clear();
    _noteController.clear();
  }

  String? _validateRecipient(String? value) {
    final recipient = value?.trim() ?? '';
    if (recipient.isEmpty) {
      return 'Recipient email is required';
    }
    if (_webPrefixPattern.hasMatch(recipient)) {
      return 'Links are not allowed';
    }
    if (!_emailPattern.hasMatch(recipient)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    final rawAmount = value?.trim() ?? '';
    final amount = double.tryParse(rawAmount);
    if (rawAmount.isEmpty || amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }
    if (rawAmount.split('.').length > 2) {
      return 'Only one decimal point is allowed';
    }
    return null;
  }

  String? _validateNote(String? value) {
    final note = value?.trim() ?? '';
    if (note.isNotEmpty && _linkPattern.hasMatch(note)) {
      return 'Links are not allowed';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Send money',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Available balance: Rs ${widget.balance.toStringAsFixed(0)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _recipientController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Recipient email',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  inputFormatters: [
                    _NoLinksTextInputFormatter(prefixOnly: true),
                  ],
                  validator: _validateRecipient,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'Rs ',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  inputFormatters: const [_SingleDecimalInputFormatter()],
                  validator: _validateAmount,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Note optional',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  inputFormatters: const [_NoLinksTextInputFormatter()],
                  validator: _validateNote,
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isFormValid && !widget.isSubmitting ? _submit : null,
            icon: widget.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(widget.isSubmitting ? 'Sending...' : 'Send money'),
          ),
        ],
      ),
    );
  }
}

class _SingleDecimalInputFormatter extends TextInputFormatter {
  const _SingleDecimalInputFormatter();

  static final _amountPattern = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty || _amountPattern.hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

class _NoLinksTextInputFormatter extends TextInputFormatter {
  const _NoLinksTextInputFormatter({this.prefixOnly = false});

  final bool prefixOnly;

  static final _linkPattern = RegExp(
    r'((https?:\/\/|www\.)\S+)|\b[A-Za-z0-9-]+\.(com|in|net|org|io|co|dev|app|ai)\b',
    caseSensitive: false,
  );
  static final _webPrefixPattern = RegExp(
    r'(https?:\/\/|www\.)',
    caseSensitive: false,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final hasLink = prefixOnly
        ? _webPrefixPattern.hasMatch(newValue.text)
        : _linkPattern.hasMatch(newValue.text);
    return hasLink ? oldValue : newValue;
  }
}
