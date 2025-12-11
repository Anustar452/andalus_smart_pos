// src/ui/screens/auth/otp_verification_screen.dart
// Screen for OTP verification during registration or login.
import 'dart:async';

import 'package:andalus_smart_pos/src/widgets/common/app_button.dart';
import 'package:andalus_smart_pos/src/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';

class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final VerificationType type;
  final String? businessName;

  const OTPVerificationScreen({
    super.key,
    required this.phone,
    required this.type,
    this.businessName,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _sendOTP();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (widget.phone.isEmpty) {
      _showError('Phone number not set');
      return;
    }

    try {
      setState(() => _isResending = true);

      // Use the generic sendOTP method from your AuthService
      await ref.read(authProvider.notifier).sendOTP(widget.phone);

      // Start cooldown timer (60 seconds)
      _startCooldownTimer();

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
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Use the appropriate method based on verification type
      if (widget.type == VerificationType.registration) {
        // For registration, you'll need to handle this differently
        // This would typically be called from your registration flow
        _showError(
            'Registration OTP verification should be handled in registration flow');
      } else {
        // For login, use the existing loginWithOTP method
        await ref.read(authProvider.notifier).verifyOTPAndLogin(
              widget.phone,
              _otpController.text.trim(),
            );
      }

      // Success handling is done via auth state listener
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.type == VerificationType.registration
                  ? AppLocalizations.of(context)
                      .translate('registrationSuccessful')
                  : AppLocalizations.of(context).translate('loginSuccessful'),
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
        setState(() => _isLoading = false);
      }
    }
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('verifyPhone')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                _buildHeaderSection(theme, loc),
                const SizedBox(height: 32),

                // OTP Input Section
                _buildOTPInputSection(theme, loc),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(theme, loc),

                // Spacer to prevent overflow
                const Expanded(child: SizedBox()),

                // Demo Hint (Remove in production)
                _buildDemoHint(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, AppLocalizations loc) {
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
              params: {'phone': _formatPhone(widget.phone)}),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.businessName != null) ...[
          const SizedBox(height: 8),
          Text(
            loc.translate('forBusiness',
                params: {'business': widget.businessName!}),
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
            if (value.length == 6) {
              _focusNode.unfocus();
              // Auto-submit when 6 digits are entered
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _verifyOTP();
              });
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
}

enum VerificationType {
  registration,
  login,
}
