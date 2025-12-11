// src/ui/screens/onboarding/onboarding_otp_verification_screen.dart
// Screen for OTP verification during the onboarding process.
import 'dart:async';

import 'package:andalus_smart_pos/src/widgets/common/app_button.dart';
import 'package:andalus_smart_pos/src/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/onboarding_provider.dart';

class OnboardingOTPVerificationScreen extends ConsumerStatefulWidget {
  const OnboardingOTPVerificationScreen({super.key});

  @override
  ConsumerState<OnboardingOTPVerificationScreen> createState() =>
      _OnboardingOTPVerificationScreenState();
}

class _OnboardingOTPVerificationScreenState
    extends ConsumerState<OnboardingOTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isResending = false;
  bool _isVerifying = false; // Add this flag
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _otpSent = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOTP();
    });
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String? get _phone {
    final state = ref.read(onboardingProvider);
    return state.owner?.phone;
  }

  String? get _businessName {
    final state = ref.read(onboardingProvider);
    return state.shop?.shopName;
  }

  Future<void> _sendOTP() async {
    final phone = _phone;
    if (phone == null) {
      _showError('Phone number not set. Please complete owner registration.');
      return;
    }

    try {
      setState(() => _isResending = true);

      await ref.read(onboardingProvider.notifier).sendRegistrationOTP(phone);

      _startCooldownTimer();
      setState(() => _otpSent = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('otpSentSuccessfully'),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _startCooldownTimer() {
    setState(() => _resendCooldown = 60);

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading || _isVerifying) return; // Prevent multiple calls

    setState(() {
      _isLoading = true;
      _isVerifying = true;
    });

    try {
      final success =
          await ref.read(onboardingProvider.notifier).verifyRegistrationOTP(
                _otpController.text.trim(),
              );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('otpVerifiedSuccessfully'),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Wait a bit for the state to update and navigation to happen
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if we're still on the same screen (navigation didn't happen)
        final currentState = ref.read(onboardingProvider);
        if (currentState.currentStep == 3 && mounted) {
          // Still on OTP screen - show manual continue option
          _showManualContinueOption();
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVerifying = false;
        });
      }
    }
  }

  void _showManualContinueOption() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verification Successful'),
        content: const Text(
            'OTP verified successfully! Please continue to payment.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Manually trigger next step
              ref.read(onboardingProvider.notifier).nextStep();
            },
            child: const Text('Continue to Payment'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String? _validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).translate('otpRequired');
    }
    if (value.trim().length != 6) {
      return AppLocalizations.of(context).translate('otpMustBe6Digits');
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return AppLocalizations.of(context).translate('otpMustBeNumbers');
    }
    return null;
  }

  String _formatPhone(String phone) {
    if (phone.startsWith('+251')) {
      return '+251 ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    final phone = _phone;
    final businessName = _businessName;

    if (phone == null) {
      return _buildErrorScreen('Please complete owner registration first.');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('verifyPhone')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading
              ? null
              : () => ref.read(onboardingProvider.notifier).previousStep(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(theme, loc, phone, businessName),
                const SizedBox(height: 32),

                // OTP Input Section
                _buildOTPInputSection(theme, loc),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(theme, loc),

                // Spacer to prevent overflow
                const Expanded(child: SizedBox()),

                // Demo Hint (Remove in production)
                if (_otpSent) _buildDemoHint(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, AppLocalizations loc,
      String phone, String? businessName) {
    return Column(
      children: [
        Icon(
          Icons.verified_user_rounded,
          size: 80,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          loc.translate('verifyYourPhone'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          loc.translate('otpSentToPhone',
              params: {'phone': _formatPhone(phone)}),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        if (businessName != null) ...[
          const SizedBox(height: 8),
          Text(
            loc.translate('forBusiness', params: {'business': businessName}),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildOTPInputSection(ThemeData theme, AppLocalizations loc) {
    return Column(
      children: [
        AppTextField(
          controller: _otpController,
          label: loc.translate('enterOTPCode'),
          hintText: '123456',
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: _validateOTP,
          focusNode: _focusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _verifyOTP(),
          onChanged: (value) {
            if (value.length == 6 && !_isLoading) {
              _focusNode.unfocus();
              // Use a flag to prevent multiple calls
              if (!_isVerifying) {
                _isVerifying = true;
                // Add a small delay to ensure the field is updated
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    _verifyOTP().then((_) {
                      _isVerifying = false;
                    });
                  }
                });
              }
            }
          },
        ),
        const SizedBox(height: 8),
        Text(
          loc.translate('enter6DigitCode'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, AppLocalizations loc) {
    return Column(
      children: [
        AppButton.primary(
          onPressed: _isLoading ? null : _verifyOTP,
          isLoading: _isLoading,
          child: Text(
            loc.translate('verifyAndContinue'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.translate('didNotReceiveCode'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            if (_resendCooldown > 0)
              Text(
                '(${_resendCooldown}s)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              TextButton(
                onPressed: (_isResending || _isLoading) ? null : _sendOTP,
                child: _isResending
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Text(
                        loc.translate('resendOTP'),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDemoHint(ThemeData theme) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Demo Mode',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Use "123456" for instant verification\n• OTPs expire after 10 minutes\n• Remove this hint in production',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Registration Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(onboardingProvider.notifier).previousStep();
              },
              child: const Text('Go Back to Owner Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
