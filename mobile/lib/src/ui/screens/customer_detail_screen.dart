// src/ui/screens/customer_detail_screen.dart
// Screen for viewing and managing detailed information about a specific customer, including credit sales and payments.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/customer.dart';
import 'package:andalus_smart_pos/src/data/models/credit_transaction.dart';
import 'package:andalus_smart_pos/src/data/repositories/customer_repository.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  List<CreditTransaction> _transactions = [];
  bool _isLoading = true;
  Customer? _currentCustomer;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCustomer();
    await _loadTransactions();
  }

  Future<void> _loadCustomer() async {
    try {
      final repository = ref.read(customerRepositoryProvider);
      final customer = await repository.getCustomerById(widget.customer.id!);
      if (customer != null && mounted) {
        setState(() {
          _currentCustomer = customer;
        });
      }
    } catch (e) {
      print('Error loading customer: $e');
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final repository = ref.read(customerRepositoryProvider);
      final transactions =
          await repository.getCustomerTransactions(widget.customer.id!);

      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading transactions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddCreditSaleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCreditSaleDialog(
        customer: _currentCustomer!,
        onSaleCompleted: _loadData,
      ),
    );
  }

  void _showRecordPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => RecordPaymentDialog(
        customer: _currentCustomer!,
        onPaymentRecorded: _loadData,
      ),
    );
  }

  void _showEditCreditLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => EditCreditLimitDialog(
        customer: _currentCustomer!,
        onCreditLimitUpdated: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentCustomer == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final customer = _currentCustomer!;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            _buildCustomerInfoCard(customer, isSmallScreen),
            const SizedBox(height: 24),

            // Credit Control Actions
            _buildCreditActionsCard(customer, isSmallScreen),
            const SizedBox(height: 24),

            // Transaction History
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

// In customer_detail_screen.dart, update the customer info card
  Widget _buildCustomerInfoCard(Customer customer, bool isSmallScreen) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with business name if available
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (customer.businessName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          customer.businessName!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (customer.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          customer.phone!,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: customer.isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : customer.currentBalance > 0
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: customer.isOverdue
                          ? Colors.red
                          : customer.currentBalance > 0
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  child: Text(
                    customer.isOverdue
                        ? 'OVERDUE'
                        : customer.currentBalance > 0
                            ? 'PENDING'
                            : 'PAID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: customer.isOverdue
                          ? Colors.red
                          : customer.currentBalance > 0
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Additional customer info
            if (customer.tinNumber != null ||
                customer.whatsappNumber != null ||
                customer.email != null) ...[
              _buildAdditionalInfo(customer),
              const SizedBox(height: 16),
            ],

            // Rest of the existing credit information grid...
            // ... [keep the existing credit info grid code]
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(Customer customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Information',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (customer.tinNumber != null)
            _buildInfoRow('TIN/VAT:', customer.tinNumber!),
          if (customer.whatsappNumber != null)
            _buildInfoRow('WhatsApp:', customer.whatsappNumber!),
          if (customer.email != null) _buildInfoRow('Email:', customer.email!),
          if (customer.notes != null) _buildInfoRow('Notes:', customer.notes!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditActionsCard(Customer customer, bool isSmallScreen) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credit Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: customer.canMakeCreditSale
                      ? _showAddCreditSaleDialog
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Add Credit Sale'),
                ),
                ElevatedButton.icon(
                  onPressed: customer.currentBalance > 0
                      ? _showRecordPaymentDialog
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Record Payment'),
                ),
                OutlinedButton.icon(
                  onPressed: _showEditCreditLimitDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.credit_card, size: 18),
                  label: const Text('Edit Credit Limit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child:
                          CircularProgressIndicator(color: Color(0xFF10B981)),
                    ),
                  )
                : _transactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          return _buildTransactionItem(transaction);
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(CreditTransaction transaction) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: transaction.amountColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(transaction.icon, color: transaction.amountColor, size: 20),
      ),
      title: Text(transaction.description),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (transaction.reference != null)
            Text('Reference: ${transaction.reference}'),
          if (transaction.notes != null) Text(transaction.notes!),
          Text(
            '${_formatDateTime(transaction.createdAt)} • Balance: ETB ${transaction.balanceAfter.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: Text(
        transaction.formattedAmount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: transaction.amountColor,
          fontSize: 16,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  int _daysOverdue(DateTime dueDate) {
    return DateTime.now().difference(dueDate).inDays;
  }
}

// Add these dialog classes to your customer_detail_screen.dart file

// Add Credit Sale Dialog
class AddCreditSaleDialog extends ConsumerStatefulWidget {
  final Customer customer;
  final VoidCallback onSaleCompleted;

  const AddCreditSaleDialog({
    super.key,
    required this.customer,
    required this.onSaleCompleted,
  });

  @override
  ConsumerState<AddCreditSaleDialog> createState() =>
      _AddCreditSaleDialogState();
}

class _AddCreditSaleDialogState extends ConsumerState<AddCreditSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final _dueDaysController = TextEditingController(text: '30');

  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    _dueDaysController.dispose();
    super.dispose();
  }

  Future<void> _addCreditSale() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final dueDays = int.tryParse(_dueDaysController.text) ?? 30;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale amount must be greater than zero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(customerRepositoryProvider);
      final result = await repository.createCreditSale(
        customerId: widget.customer.id!,
        amount: amount,
        saleReference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : 'SALE-${DateTime.now().millisecondsSinceEpoch}',
        dueDays: dueDays,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Credit sale of ETB ${amount.toStringAsFixed(2)} added successfully!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
        widget.onSaleCompleted();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding credit sale: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_shopping_cart,
                        color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add Credit Sale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customer: ${widget.customer.name}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Available Credit: ETB ${widget.customer.availableCredit.toStringAsFixed(2)}',
                style: TextStyle(
                  color: widget.customer.availableCredit > 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Sale Amount (ETB) *',
                  border: OutlineInputBorder(),
                  prefixText: 'ETB ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sale amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > widget.customer.availableCredit) {
                    return 'Amount exceeds available credit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Sale Reference',
                  border: OutlineInputBorder(),
                  hintText: 'Optional reference number',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dueDaysController,
                decoration: const InputDecoration(
                  labelText: 'Due Days',
                  border: OutlineInputBorder(),
                  hintText: '30',
                  suffixText: 'days',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final days = int.tryParse(value);
                    if (days == null || days <= 0) {
                      return 'Please enter valid number of days';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Optional notes about this sale',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _addCreditSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Add Sale'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Record Payment Dialog
class RecordPaymentDialog extends ConsumerStatefulWidget {
  final Customer customer;
  final VoidCallback onPaymentRecorded;

  const RecordPaymentDialog({
    super.key,
    required this.customer,
    required this.onPaymentRecorded,
  });

  @override
  ConsumerState<RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.customer.currentBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid payment amount'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (amount > widget.customer.currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment amount cannot exceed outstanding balance'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(customerRepositoryProvider);
      final result = await repository.recordPayment(
        customerId: widget.customer.id!,
        amount: amount,
        paymentReference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Payment of ETB ${amount.toStringAsFixed(2)} recorded successfully!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
        widget.onPaymentRecorded();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.payment,
                        color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Record Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customer: ${widget.customer.name}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Current Balance: ETB ${widget.customer.currentBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: widget.customer.currentBalance > 0
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (ETB) *',
                  border: OutlineInputBorder(),
                  prefixText: 'ETB ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter payment amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Payment Reference',
                  border: OutlineInputBorder(),
                  hintText: 'Optional reference number',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Optional notes about this payment',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _recordPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Record Payment'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Credit Limit Dialog
class EditCreditLimitDialog extends ConsumerStatefulWidget {
  final Customer customer;
  final VoidCallback onCreditLimitUpdated;

  const EditCreditLimitDialog({
    super.key,
    required this.customer,
    required this.onCreditLimitUpdated,
  });

  @override
  ConsumerState<EditCreditLimitDialog> createState() =>
      _EditCreditLimitDialogState();
}

class _EditCreditLimitDialogState extends ConsumerState<EditCreditLimitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _creditLimitController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _creditLimitController.text =
        widget.customer.creditLimit.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _updateCreditLimit() async {
    if (!_formKey.currentState!.validate()) return;

    final newLimit = double.tryParse(_creditLimitController.text) ?? 0;

    if (newLimit < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credit limit cannot be negative'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(customerRepositoryProvider);
      final result = await repository.updateCreditLimit(
        customerId: widget.customer.id!,
        newCreditLimit: newLimit,
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Credit limit updated to ETB ${newLimit.toStringAsFixed(2)}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
        widget.onCreditLimitUpdated();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating credit limit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.credit_card,
                        color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit Credit Limit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customer: ${widget.customer.name}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Current Balance: ETB ${widget.customer.currentBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Form Field
              TextFormField(
                controller: _creditLimitController,
                decoration: const InputDecoration(
                  labelText: 'New Credit Limit (ETB) *',
                  border: OutlineInputBorder(),
                  prefixText: 'ETB ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter credit limit';
                  }
                  final limit = double.tryParse(value);
                  if (limit == null) {
                    return 'Please enter a valid amount';
                  }
                  if (limit < widget.customer.currentBalance) {
                    return 'Credit limit cannot be less than current balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _updateCreditLimit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Limit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
