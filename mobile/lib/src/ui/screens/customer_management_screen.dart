import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/customer.dart';
import 'package:andalus_smart_pos/src/data/models/credit_transaction.dart';
import 'package:andalus_smart_pos/src/data/repositories/customer_repository.dart';
import 'package:andalus_smart_pos/src/data/local/database.dart';
// import 'package:andalus_smart_pos/src/ui/screens/customer_detail_screen.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState
    extends ConsumerState<CustomerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Customer> _filteredCustomers = [];
  List<Customer> _allCustomers = [];
  bool _isLoading = true;
  String _filter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Attempt to access the customers via the repository to ensure DB is initialized,
    // and reset the database if accessing customers fails.
    try {
      final repository = ref.read(customerRepositoryProvider);
      final customers = await repository.getAllCustomers();
      print('Loaded ${customers.length} customers from database');
    } catch (e) {
      print('Database access error: $e');
      try {
        print('Resetting database...');
        await AppDatabase.resetDatabase();
      } catch (resetError) {
        print('Failed to reset database: $resetError');
      }
    }

    await _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final repository = ref.read(customerRepositoryProvider);
      List<Customer> customers;

      switch (_filter) {
        case 'with_balance':
          customers = await repository.getCustomersWithBalance();
          break;
        case 'overdue':
          customers = await repository.getOverdueCustomers();
          break;
        case 'all':
        default:
          customers = await repository.getAllCustomers();
      }

      if (mounted) {
        setState(() {
          _allCustomers = customers;
          _filteredCustomers = _applySearchFilter(customers, _searchQuery);
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading customers: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading customers: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadCustomers,
            ),
          ),
        );
      }
    }
  }

  List<Customer> _applySearchFilter(List<Customer> customers, String query) {
    if (query.isEmpty) return customers;

    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase()) ||
          (customer.phone?.toLowerCase().contains(query.toLowerCase()) ??
              false) ||
          (customer.email?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _searchQuery = query;
      _filteredCustomers = _applySearchFilter(_allCustomers, query);
    });
  }

  void _changeFilter(String newFilter) {
    setState(() {
      _filter = newFilter;
    });
    _loadCustomers();
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCustomerDialog(
        onCustomerAdded: _loadCustomers,
      ),
    ).then((_) {
      // This ensures the screen resizes properly after dialog closes
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _showCustomerDetails(Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailScreen(customer: customer),
      ),
    );
  }

  void _showRecordPaymentDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => RecordPaymentDialog(
        customer: customer,
        onPaymentRecorded: _loadCustomers,
      ),
    );
  }

  // Statistics
  int get _totalCustomers => _allCustomers.length;
  int get _customersWithBalance =>
      _allCustomers.where((c) => c.currentBalance != 0).length;
  int get _overdueCustomers => _allCustomers.where((c) => c.isOverdue).length;
  double get _totalOutstanding =>
      _allCustomers.fold(0, (sum, c) => sum + c.currentBalance);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isVerySmallScreen = screenSize.width < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Customer Management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 1,
        shadowColor: Colors.black12,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 22),
            onPressed: _showAddCustomerDialog,
            tooltip: 'Add Customer',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: _loadCustomers,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Header Section with Search
          _buildHeaderSection(isSmallScreen, isVerySmallScreen),

          // Statistics Cards
          if (_allCustomers.isNotEmpty)
            _buildStatisticsSection(isSmallScreen, isVerySmallScreen),

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredCustomers.isEmpty
                    ? _buildEmptyState(isSmallScreen)
                    : _buildCustomersList(isSmallScreen),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.person_add_alt_1, size: 24),
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallScreen, bool isVerySmallScreen) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isVerySmallScreen ? 16 : 20,
        16,
        isVerySmallScreen ? 16 : 20,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers by name, phone, or email...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SizedBox(
            height: isVerySmallScreen ? 36 : 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All Customers', 'all', isVerySmallScreen),
                SizedBox(width: isVerySmallScreen ? 8 : 12),
                _buildFilterChip(
                    'With Balance', 'with_balance', isVerySmallScreen),
                SizedBox(width: isVerySmallScreen ? 8 : 12),
                _buildFilterChip('Overdue', 'overdue', isVerySmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isVerySmallScreen) {
    final isSelected = _filter == value;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: isVerySmallScreen ? 12 : 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) => _changeFilter(value),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF10B981),
      side: BorderSide(
        color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 12 : 16,
        vertical: isVerySmallScreen ? 4 : 6,
      ),
    );
  }

  Widget _buildStatisticsSection(bool isSmallScreen, bool isVerySmallScreen) {
    final stats = [
      _StatItem('Total Customers', _totalCustomers.toString(), Icons.people_alt,
          const Color(0xFF10B981)),
      _StatItem('With Balance', _customersWithBalance.toString(),
          Icons.account_balance_wallet, const Color(0xFFF59E0B)),
      _StatItem('Overdue', _overdueCustomers.toString(), Icons.warning_amber,
          const Color(0xFFEF4444)),
      _StatItem('Outstanding', 'ETB ${_totalOutstanding.toStringAsFixed(0)}',
          Icons.attach_money, const Color(0xFF8B5CF6)),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 16 : 20,
        vertical: 16,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isVerySmallScreen ? 2 : (isSmallScreen ? 2 : 4),
          crossAxisSpacing: isVerySmallScreen ? 12 : 16,
          mainAxisSpacing: isVerySmallScreen ? 12 : 16,
          childAspectRatio: isVerySmallScreen ? 1.2 : 1.4,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return _buildStatCard(stats[index], isVerySmallScreen);
        },
      ),
    );
  }

  Widget _buildStatCard(_StatItem stat, bool isVerySmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: stat.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(stat.icon, color: stat.color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label,
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 11 : 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF10B981),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading customers...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 32 : 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isSmallScreen ? 120 : 150,
              height: isSmallScreen ? 120 : 150,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(75),
              ),
              child: Icon(
                Icons.people_outline,
                size: isSmallScreen ? 50 : 60,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getEmptyStateTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _showAddCustomerDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Add First Customer',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateTitle() {
    switch (_filter) {
      case 'with_balance':
        return 'No Customers with Balance';
      case 'overdue':
        return 'No Overdue Customers';
      default:
        return 'No Customers Yet';
    }
  }

  String _getEmptyStateMessage() {
    switch (_filter) {
      case 'with_balance':
        return 'All customers are paid up! Great job managing credit.';
      case 'overdue':
        return 'No customers have exceeded their credit limits. Excellent credit control!';
      default:
        return 'Start building your customer database to track sales, credit, and customer relationships.';
    }
  }

  Widget _buildCustomersList(bool isSmallScreen) {
    return RefreshIndicator(
      onRefresh: _loadCustomers,
      color: const Color(0xFF10B981),
      backgroundColor: Colors.white,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          isSmallScreen ? 16 : 20,
          8,
          isSmallScreen ? 16 : 20,
          20,
        ),
        itemCount: _filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = _filteredCustomers[index];
          return _buildCustomerCard(customer, isSmallScreen);
        },
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, bool isSmallScreen) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showCustomerDetails(customer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person,
                      color: const Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Customer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Status Badges
                            if (customer.isOverdue)
                              _buildStatusBadge('OVERDUE', Colors.red),
                            if (customer.currentBalance > 0 &&
                                !customer.isOverdue)
                              _buildStatusBadge('BALANCE', Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Contact Info
                        if (customer.phone != null) ...[
                          Row(
                            children: [
                              Icon(Icons.phone,
                                  size: 14, color: const Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                customer.phone!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                        ],

                        if (customer.email != null) ...[
                          Row(
                            children: [
                              Icon(Icons.email,
                                  size: 14, color: const Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.email!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Balance and Actions
              Row(
                children: [
                  // Balance Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.balanceStatus,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: customer.currentBalance > 0
                                ? (customer.isOverdue
                                    ? Colors.red
                                    : const Color(0xFF2563EB))
                                : const Color(0xFF10B981),
                          ),
                        ),
                        if (customer.hasCredit)
                          Text(
                            'Credit Limit: ETB ${customer.creditLimit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  if (customer.currentBalance > 0)
                    ElevatedButton(
                      onPressed: () => _showRecordPaymentDialog(customer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Receive Payment',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// Stat Item Helper Class
class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem(this.label, this.value, this.icon, this.color);
}

// Enhanced Add Customer Dialog
// Enhanced AddCustomerDialog in customer_management_screen.dart
class AddCustomerDialog extends ConsumerStatefulWidget {
  final VoidCallback onCustomerAdded;

  const AddCustomerDialog({super.key, required this.onCustomerAdded});

  @override
  ConsumerState<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _tinController = TextEditingController();
  final _addressController = TextEditingController();
  final _creditLimitController = TextEditingController(text: '0.00');
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  bool _allowCredit = false;
  String _paymentTerms = '30'; // Default to 30 days
  DateTime? _customDueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _tinController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Ethiopian phone format validation (starts with +251 or 09)
    final phoneRegex = RegExp(r'^(\+251|0)(9|7)\d{8}$');
    final digitsOnly = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (!phoneRegex.hasMatch(digitsOnly)) {
      return 'Please enter a valid Ethiopian phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }
    return null;
  }

  String? _validateCreditLimit(String? value) {
    if (_allowCredit) {
      if (value == null || value.trim().isEmpty) {
        return 'Credit limit is required when credit is allowed';
      }
      final amount = double.tryParse(value);
      if (amount == null || amount < 0) {
        return 'Please enter a valid credit limit';
      }
    }
    return null;
  }

  String? _validateTIN(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      // Basic TIN validation (Ethiopian TIN is typically 10 digits)
      final tinRegex = RegExp(r'^\d{10}$');
      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

      if (digitsOnly.length != 10) {
        return 'TIN should be 10 digits';
      }
    }
    return null;
  }

  Future<void> _addCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(customerRepositoryProvider);

      // Calculate due date based on payment terms
      DateTime? dueDate;
      if (_paymentTerms == 'custom' && _customDueDate != null) {
        dueDate = _customDueDate;
      } else if (_paymentTerms != 'none' && _paymentTerms != 'custom') {
        final days = int.tryParse(_paymentTerms) ?? 30;
        dueDate = DateTime.now().add(Duration(days: days));
      }

      final customer = Customer(
        localId: 'cust_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        businessName: _businessNameController.text.trim().isNotEmpty
            ? _businessNameController.text.trim()
            : null,
        phone: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim().isNotEmpty
            ? _whatsappController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        tinNumber: _tinController.text.trim().isNotEmpty
            ? _tinController.text.trim()
            : null,
        creditLimit: _allowCredit
            ? (double.tryParse(_creditLimitController.text) ?? 0)
            : 0,
        currentBalance: 0, // Always start with zero balance
        dueDate: dueDate,
        allowCredit: _allowCredit,
        paymentTerms: _allowCredit ? _paymentTerms : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createCustomer(customer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Customer added successfully!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        Navigator.pop(context);
        widget.onCustomerAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding customer: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _selectCustomDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _customDueDate = picked;
        _paymentTerms = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.all(isSmallScreen ? 8 : 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header that stays fixed
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add New Customer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter customer details for your POS system',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Your form fields here (same as before)
                      // Personal Information Section
                      _buildSectionHeader('Personal Information'),
                      _buildFormField(
                        label: 'Full Name *',
                        controller: _nameController,
                        validator: (value) =>
                            _validateRequired(value, 'Full name'),
                        icon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12), // Reduced spacing

                      _buildFormField(
                        label: 'Business/Company Name',
                        controller: _businessNameController,
                        icon: Icons.business_outlined,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Contact Information Section
                      _buildSectionHeader('Contact Information'),
                      _buildFormField(
                        label: 'Phone Number *',
                        controller: _phoneController,
                        validator: _validatePhone,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'WhatsApp Number',
                        controller: _whatsappController,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return _validatePhone(value);
                          }
                          return null;
                        },
                        icon: Icons.chat,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'Email Address',
                        controller: _emailController,
                        validator: _validateEmail,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Business Information Section
                      _buildSectionHeader('Business Information'),
                      _buildFormField(
                        label: 'TIN/VAT Number',
                        controller: _tinController,
                        validator: _validateTIN,
                        icon: Icons.assignment_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),

                      _buildFormField(
                        label: 'Address',
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),

                      // Credit Control Section
                      _buildSectionHeader('Credit Control'),
                      _buildCreditControlSection(),
                      const SizedBox(height: 16),

                      // Additional Information Section
                      _buildSectionHeader('Additional Information'),
                      _buildFormField(
                        label: 'Notes',
                        controller: _notesController,
                        icon: Icons.notes_outlined,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditControlSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Allow Credit Switch
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.credit_card_outlined,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allow Credit',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Enable credit facility for this customer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _allowCredit,
                  onChanged: (value) {
                    setState(() {
                      _allowCredit = value;
                      if (!value) {
                        _paymentTerms = 'none';
                        _customDueDate = null;
                      }
                    });
                  },
                  activeColor: const Color(0xFF10B981),
                ),
              ],
            ),

            // Credit Limit (only show if credit is allowed)
            if (_allowCredit) ...[
              const SizedBox(height: 16),
              _buildFormField(
                label: 'Credit Limit (ETB) *',
                controller: _creditLimitController,
                validator: _validateCreditLimit,
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Payment Terms
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Payment Terms',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _paymentTerms,
                    decoration: const InputDecoration(
                      labelText: 'Select Payment Terms',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'none',
                        child: Text('No Credit Terms'),
                      ),
                      DropdownMenuItem(
                        value: '7',
                        child: Text('7 Days'),
                      ),
                      DropdownMenuItem(
                        value: '15',
                        child: Text('15 Days'),
                      ),
                      DropdownMenuItem(
                        value: '30',
                        child: Text('30 Days'),
                      ),
                      DropdownMenuItem(
                        value: 'custom',
                        child: Text('Custom Date'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _paymentTerms = value ?? '30';
                        if (value != 'custom') {
                          _customDueDate = null;
                        }
                      });
                    },
                  ),
                  if (_paymentTerms == 'custom') ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _selectCustomDueDate,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _customDueDate != null
                            ? 'Due Date: ${_formatDate(_customDueDate!)}'
                            : 'Select Custom Due Date',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _addCustomer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
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
                : const Text(
                    'Add Customer',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF10B981),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 18,
        ),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
// Keep the existing RecordPaymentDialog and CustomerDetailScreen as they are
// but ensure they also use ref.read(customerRepositoryProvider)

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
    _notesController.dispose();
    super.dispose();
  }

  void _recordPayment() async {
    if (_formKey.currentState!.validate()) {
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
        final transaction = CreditTransaction(
          localId: 'payment_${DateTime.now().millisecondsSinceEpoch}',
          customerId: widget.customer.id!,
          customerName: widget.customer.name,
          type: 'payment',
          amount: amount,
          balanceBefore: widget.customer.currentBalance,
          balanceAfter: widget.customer.currentBalance - amount,
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
          createdAt: DateTime.now(),
        );

        await repository.addCreditTransaction(transaction);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Payment of ETB ${amount.toStringAsFixed(2)} recorded!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );

        Navigator.pop(context);
        widget.onPaymentRecorded();
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
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Customer: ${widget.customer.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Outstanding Balance: ETB ${widget.customer.currentBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: widget.customer.isOverdue ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (ETB) *',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter payment amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
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

// Add this to your customer_management_screen.dart or create separate files

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

// CustomerDetailScreen remains the same but ensure it uses ref.read
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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final repository = ref.read(customerRepositoryProvider);
      final transactions =
          await repository.getCustomerTransactions(widget.customer.id!);

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading transactions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customer.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.customer.phone != null) ...[
                      const SizedBox(height: 8),
                      Text('Phone: ${widget.customer.phone}'),
                    ],
                    if (widget.customer.email != null) ...[
                      const SizedBox(height: 4),
                      Text('Email: ${widget.customer.email}'),
                    ],
                    if (widget.customer.address != null) ...[
                      const SizedBox(height: 4),
                      Text('Address: ${widget.customer.address}'),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Balance:'),
                            Text(
                              widget.customer.formattedBalance,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: widget.customer.currentBalance > 0
                                    ? (widget.customer.isOverdue
                                        ? Colors.red
                                        : Colors.blue)
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (widget.customer.hasCredit)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Credit Limit:'),
                              Text(
                                'ETB ${widget.customer.creditLimit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                    child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: _transactions
                            .map((transaction) =>
                                _buildTransactionCard(transaction))
                            .toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(CreditTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (transaction.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year} ${transaction.createdAt.hour}:${transaction.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.amountColor,
                  ),
                ),
                Text(
                  'Balance: ETB ${transaction.balanceAfter.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
