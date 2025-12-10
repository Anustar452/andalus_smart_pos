// lib/src/ui/screens/auth/phone_login_screen.dart
import 'package:andalus_smart_pos/src/widgets/common/app_button.dart';
import 'package:andalus_smart_pos/src/widgets/common/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';
import 'package:andalus_smart_pos/src/ui/screens/onboarding/onboarding_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/main_navigation.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordFocusNode = FocusNode();

  bool _isLoggingIn = false;
  String? _loginError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loginWithPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    try {
      await ref.read(authProvider.notifier).loginWithPassword(
            _phoneController.text.trim(),
            _passwordController.text,
          );

      // Success handling is done in the auth state listener
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
        _loginError = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).translate('passwordRequired');
    }
    if (value.length < 6) {
      return AppLocalizations.of(context).translate('passwordMinLength');
    }
    return null;
  }

  void _navigateToOnboarding() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    // Handle successful login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Welcome Section
                _buildWelcomeSection(theme, loc),
                const SizedBox(height: 40),

                // Login Card
                _buildLoginCard(theme, loc),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, AppLocalizations loc) {
    return Column(
      children: [
        // App Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.onPrimary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.point_of_sale_rounded,
            size: 50,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 24),

        // App Name
        Text(
          'Andalus Smart POS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          loc.translate('loginToYourAccount'),
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onPrimary.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(ThemeData theme, AppLocalizations loc) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Text(
                loc.translate('welcomeBack'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('enterCredentialsToContinue'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
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
                enabled: !_isLoggingIn,
                validator: _validatePhone,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  // Move focus to password field when phone field is submitted
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
              ),
              const SizedBox(height: 20),

              // Password Input - FIXED: using onSubmitted instead of onFieldSubmitted
              AppTextField(
                controller: _passwordController,
                label: loc.translate('password'),
                prefixIcon: Icon(
                  Icons.lock_rounded,
                  color: theme.colorScheme.primary,
                ),
                obscureText: true,
                enabled: !_isLoggingIn,
                validator: _validatePassword,
                textInputAction: TextInputAction.done,
                focusNode: _passwordFocusNode,
                onSubmitted: (_) =>
                    _loginWithPassword(), // FIXED: Changed to onSubmitted
              ),
              const SizedBox(height: 8),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoggingIn
                      ? null
                      : () {
                          // TODO: Implement forgot password
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.translate('featureComingSoon')),
                            ),
                          );
                        },
                  child: Text(
                    loc.translate('forgotPassword'),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (_loginError != null) ...[
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
                          _loginError!,
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

              // Login Button
              AppButton.primary(
                onPressed: _isLoggingIn ? null : _loginWithPassword,
                isLoading: _isLoggingIn,
                child: Text(
                  loc.translate('login'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      loc.translate('or'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Register Button
              AppButton.outlined(
                onPressed: _isLoggingIn ? null : _navigateToOnboarding,
                child: Text(
                  loc.translate('createNewBusiness'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
