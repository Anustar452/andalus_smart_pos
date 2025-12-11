// src/ui/screens/business_registration_screen.dart
// Screen for registering a business during the onboarding process.
import 'package:andalus_smart_pos/src/data/models/category.dart';
import 'package:andalus_smart_pos/src/data/repositories/category_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/data/models/business.dart';
import 'package:andalus_smart_pos/src/data/repositories/business_repository.dart';
import 'package:andalus_smart_pos/src/widgets/common/custom_card.dart';
import 'package:andalus_smart_pos/src/widgets/common/loading_shimmer.dart';

class BusinessRegistrationScreen extends ConsumerStatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  ConsumerState<BusinessRegistrationScreen> createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState
    extends ConsumerState<BusinessRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessNameAmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _tinController = TextEditingController();
  final _vatController = TextEditingController();
  final _licenseController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();

  String _selectedBusinessType = 'retail';
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessNameAmController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _tinController.dispose();
    _vatController.dispose();
    _licenseController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  Future<void> _registerBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final businessRepo = ref.read(businessRepositoryProvider);
      final business = BusinessProfile(
        businessId: 'biz_${DateTime.now().millisecondsSinceEpoch}',
        name: _businessNameController.text.trim(),
        nameAm: _businessNameAmController.text.trim(),
        businessType: _selectedBusinessType,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        region: _regionController.text.trim().isEmpty
            ? null
            : _regionController.text.trim(),
        tinNumber: _tinController.text.trim(),
        vatNumber: _vatController.text.trim().isEmpty
            ? null
            : _vatController.text.trim(),
        businessLicense: _licenseController.text.trim().isEmpty
            ? null
            : _licenseController.text.trim(),
        ownerName: _ownerNameController.text.trim().isEmpty
            ? null
            : _ownerNameController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim().isEmpty
            ? null
            : _ownerPhoneController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim().isEmpty
            ? null
            : _ownerEmailController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await businessRepo.saveBusinessProfile(business);

      // Create default categories for the business type
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final defaultCategories =
          DefaultCategories.forBusinessType(_selectedBusinessType);
      for (final category in defaultCategories) {
        await categoryRepo.createCategory(category);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registering business: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Registration'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusinessTypeSection(),
                    const SizedBox(height: 24),
                    _buildBusinessInfoSection(),
                    const SizedBox(height: 24),
                    _buildOwnerInfoSection(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          LoadingShimmer(height: 60, borderRadius: 12),
          SizedBox(height: 16),
          LoadingShimmer(height: 200, borderRadius: 12),
          SizedBox(height: 16),
          LoadingShimmer(height: 150, borderRadius: 12),
        ],
      ),
    );
  }

  Widget _buildBusinessTypeSection() {
    return CustomCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Type',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BusinessType.allTypes.map((type) {
              final isSelected = _selectedBusinessType == type.id;
              return FilterChip(
                label: Text(type.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedBusinessType = type.id);
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                checkmarkColor: const Color(0xFF10B981),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          if (_selectedBusinessType.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              BusinessType.allTypes
                  .firstWhere((type) => type.id == _selectedBusinessType)
                  .description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBusinessInfoSection() {
    return CustomCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessNameController,
            label: 'Business Name (English) *',
            hintText: 'Enter business name in English',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _businessNameAmController,
            label: 'Business Name (Amharic) *',
            hintText: 'የንግድ ስም በአማርኛ',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business name in Amharic is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: 'Business Phone *',
            hintText: '+251 XXX XXX XXX',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (!RegExp(r'^(\+251|251|0)\d{9}$').hasMatch(value.trim())) {
                return 'Please enter a valid Ethiopian phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: 'Business Email',
            hintText: 'business@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _addressController,
            label: 'Address *',
            hintText: 'Full business address',
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hintText: 'City',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _regionController,
                  label: 'Region',
                  hintText: 'Region/State',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _tinController,
            label: 'TIN Number *',
            hintText: 'Tax Identification Number',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'TIN number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _vatController,
                  label: 'VAT Number',
                  hintText: 'VAT Registration Number',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _licenseController,
                  label: 'Business License',
                  hintText: 'License Number',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfoSection() {
    return CustomCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owner Information (Optional)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide owner details for business records',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ownerNameController,
            label: 'Owner Name',
            hintText: 'Full name of business owner',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _ownerPhoneController,
            label: 'Owner Phone',
            hintText: 'Owner phone number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _ownerEmailController,
            label: 'Owner Email',
            hintText: 'Owner email address',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registerBusiness,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Register Business',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
