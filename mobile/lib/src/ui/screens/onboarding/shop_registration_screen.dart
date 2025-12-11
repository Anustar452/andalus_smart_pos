// src/ui/screens/onboarding/shop_registration_screen.dart
// Screen for registering the shop during the onboarding process.
import 'package:andalus_smart_pos/src/data/models/business.dart';
import 'package:andalus_smart_pos/src/widgets/common/app_button.dart';
import 'package:andalus_smart_pos/src/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/onboarding_provider.dart';
import 'package:andalus_smart_pos/src/data/models/shop_registration.dart';

class ShopRegistrationScreen extends ConsumerStatefulWidget {
  const ShopRegistrationScreen({super.key});

  @override
  ConsumerState<ShopRegistrationScreen> createState() =>
      _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState
    extends ConsumerState<ShopRegistrationScreen> {
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final shop = ShopRegistration(
        shopName: _shopNameController.text.trim(),
        shopCategory: _selectedCategory ?? 'retail',
        phoneNumber: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        businessAddress: _addressController.text.trim(),
      );

      ref.read(onboardingProvider.notifier).updateShopInfo(shop);
      return true;
    }
    return false;
  }

  void _proceedToNextStep() {
    if (_validateForm()) {
      ref.read(onboardingProvider.notifier).nextStep();
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ${AppLocalizations.of(context).translate('isRequired')}';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).translate('phoneRequired');
    }
    if (!RegExp(r'^\+251[0-9]{9}$').hasMatch(value.trim())) {
      return AppLocalizations.of(context).translate('validEthiopianPhone');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('shopRegistration')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Progress indicator
              _buildProgressIndicator(0, loc),
              const SizedBox(height: 32),
              Text(
                loc.translate('setupYourShop'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('enterShopDetails'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _shopNameController,
                        label: loc.translate('shopName'),
                        validator: (value) =>
                            _validateRequired(value, loc.translate('shopName')),
                      ),
                      const SizedBox(height: 16),
                      // Shop Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: loc.translate('shopCategory'),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items: BusinessType.allTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type.id,
                            child: Text(loc.locale.languageCode == 'am'
                                ? type.nameAm
                                : type.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return loc.translate('shopCategoryRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        label: loc.translate('phoneNumber'),
                        prefixText: '+251 ',
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _cityController,
                              label: loc.translate('city'),
                              validator: (value) => _validateRequired(
                                  value, loc.translate('city')),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AppTextField(
                              controller: _countryController,
                              label: loc.translate('country'),
                              readOnly: true,
                              enabled:
                                  false, // This makes it look disabled but without the initialValue conflict
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _addressController,
                        label: loc.translate('businessAddress'),
                        maxLines: 2,
                        validator: (value) => _validateRequired(
                            value, loc.translate('businessAddress')),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              AppButton.primary(
                onPressed: _proceedToNextStep,
                child: Text(loc.translate('continue')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep, AppLocalizations loc) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStep(1, '🏪', loc.translate('shop'), currentStep >= 0),
            _buildStep(2, '👤', loc.translate('owner'), currentStep >= 1),
            _buildStep(3, '📦', loc.translate('plan'), currentStep >= 2),
            _buildStep(4, '🔐', loc.translate('verify'), currentStep >= 3),
            _buildStep(5, '💳', loc.translate('payment'), currentStep >= 4),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${currentStep + 1}/5 ${loc.translate('steps')}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildStep(int stepNumber, String emoji, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
        ),
      ],
    );
  }
}
