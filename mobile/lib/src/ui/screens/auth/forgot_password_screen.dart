// lib/src/ui/screens/auth/forgot_password_screen.dart
import 'package:andalus_smart_pos/src/widgets/common/app_button.dart';
import 'package:andalus_smart_pos/src/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isResendingOTP = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual OTP sending logic
      // await ref.read(authProvider.notifier).sendPasswordResetOTP(_phoneController.text.trim());

      setState(() {
        _currentStep = 1;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('otpSentSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResendingOTP = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual OTP resend logic

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('otpResentSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isResendingOTP = false);
    }
  }

  Future<void> _verifyOTPAndResetPassword() async {
    if (!_step2FormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('passwordsDoNotMatch')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual password reset logic
      // await ref.read(authProvider.notifier).resetPassword(
      //   _phoneController.text.trim(),
      //   _otpController.text.trim(),
      //   _newPasswordController.text,
      // );

      setState(() {
        _currentStep = 2;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate('passwordResetSuccessfully')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
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

  String? _validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).translate('otpRequired');
    }
    if (value.trim().length != 6) {
      return AppLocalizations.of(context).translate('otpMustBe6Digits');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).translate('passwordRequired');
    }
    if (value.length < 6) {
      return AppLocalizations.of(context).translate('passwordMinLength');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('forgotPassword')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToLogin,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildStepContent(theme, loc),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme, AppLocalizations loc) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(theme, loc);
      case 1:
        return _buildStep2(theme, loc);
      case 2:
        return _buildSuccessStep(theme, loc);
      default:
        return _buildStep1(theme, loc);
    }
  }

  Widget _buildStep1(ThemeData theme, AppLocalizations loc) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Icon(
            Icons.lock_reset_rounded,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            loc.translate('resetYourPassword'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('enterPhoneToResetPassword'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Phone Input
          AppTextField(
            controller: _phoneController,
            label: loc.translate('phoneNumber'),
            prefixText: '+251 ',
            prefixIcon: Icon(
              Icons.phone_rounded,
              color: theme.colorScheme.primary,
            ),
            keyboardType: TextInputType.phone,
            enabled: !_isLoading,
            validator: _validatePhone,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),

          // Error Message
          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.onErrorContainer,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          const Spacer(),

          // Send OTP Button
          AppButton.primary(
            onPressed: _isLoading ? null : _sendOTP,
            isLoading: _isLoading,
            child: Text(loc.translate('sendOTP')),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme, AppLocalizations loc) {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Icon(
            Icons.verified_user_rounded,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            loc.translate('verifyAndReset'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('enterOTPAndNewPassword'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // OTP Input
          AppTextField(
            controller: _otpController,
            label: loc.translate('enterOTPCode'),
            prefixIcon: Icon(
              Icons.sms_rounded,
              color: theme.colorScheme.primary,
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !_isLoading,
            validator: _validateOTP,
          ),
          const SizedBox(height: 16),

          // New Password
          AppTextField(
            controller: _newPasswordController,
            label: loc.translate('newPassword'),
            prefixIcon: Icon(
              Icons.lock_rounded,
              color: theme.colorScheme.primary,
            ),
            obscureText: true,
            enabled: !_isLoading,
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),

          // Confirm Password
          AppTextField(
            controller: _confirmPasswordController,
            label: loc.translate('confirmNewPassword'),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: theme.colorScheme.primary,
            ),
            obscureText: true,
            enabled: !_isLoading,
            validator: (value) {
              if (value != _newPasswordController.text) {
                return loc.translate('passwordsDoNotMatch');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Resend OTP
          Center(
            child: TextButton(
              onPressed: _isResendingOTP ? null : _resendOTP,
              child: _isResendingOTP
                  ? Text(loc.translate('resendingOTP'))
                  : Text(loc.translate('resendOTP')),
            ),
          ),

          const Spacer(),

          // Reset Password Button
          AppButton.primary(
            onPressed: _isLoading ? null : _verifyOTPAndResetPassword,
            isLoading: _isLoading,
            child: Text(loc.translate('resetPassword')),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(ThemeData theme, AppLocalizations loc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 100,
          color: Colors.green,
        ),
        const SizedBox(height: 32),
        Text(
          loc.translate('passwordResetSuccessfully'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          loc.translate('youCanNowLoginWithNewPassword'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        AppButton.primary(
          onPressed: _navigateToLogin,
          child: Text(loc.translate('backToLogin')),
        ),
      ],
    );
  }
}
