import 'package:andalus_smart_pos/src/ui/screens/auth/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _showOTPField = false;
  bool _isResendingOTP = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendOTP(_phoneController.text);
      setState(() {
        _showOTPField = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).verifyOTPAndLogin(
            _phoneController.text,
            _otpController.text,
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title
                const Icon(
                  Icons.point_of_sale,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Andalus Smart POS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // Login Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Phone Input
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixText: '+251 ',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          enabled: !_showOTPField && !authState.isLoading,
                        ),
                        const SizedBox(height: 20),

                        // OTP Input
                        if (_showOTPField) ...[
                          TextFormField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                              labelText: 'OTP Code',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : _showOTPField
                                    ? _verifyOTP
                                    : _sendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _showOTPField
                                  ? Colors.green.shade600
                                  : Colors.blue.shade700,
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _showOTPField
                                        ? 'Verify & Login'
                                        : 'Send OTP',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ), // Add this after the login button in the build method
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationScreen()),
                            );
                          },
                          child: const Text(
                              'Don\'t have an account? Register your business'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
