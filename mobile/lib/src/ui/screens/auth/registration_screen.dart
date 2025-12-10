// import 'package:andalus_smart_pos/src/data/models/user.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:andalus_smart_pos/src/providers/registration_provider.dart';
// import 'package:andalus_smart_pos/src/data/models/registration.dart';
// import 'package:andalus_smart_pos/src/data/models/subscription.dart';
// import 'package:andalus_smart_pos/src/ui/screens/auth/phone_login_screen.dart';

// class RegistrationScreen extends ConsumerStatefulWidget {
//   const RegistrationScreen({super.key});

//   @override
//   ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
//   final _businessNameController = TextEditingController();
//   final _businessNameAmController = TextEditingController();
//   final _businessPhoneController = TextEditingController();
//   final _businessEmailController = TextEditingController();
//   final _businessAddressController = TextEditingController();
//   final _tinNumberController = TextEditingController();
//   final _ownerNameController = TextEditingController();
//   final _ownerPhoneController = TextEditingController();
//   final _ownerEmailController = TextEditingController();

//   final _userNameController = TextEditingController();
//   final _userPhoneController = TextEditingController();
//   final _userEmailController = TextEditingController();
//   final _userPasswordController = TextEditingController();
//   final _userConfirmPasswordController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();
//   final _step1FormKey = GlobalKey<FormState>();
//   final _step2FormKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _businessNameController.dispose();
//     _businessNameAmController.dispose();
//     _businessPhoneController.dispose();
//     _businessEmailController.dispose();
//     _businessAddressController.dispose();
//     _tinNumberController.dispose();
//     _ownerNameController.dispose();
//     _ownerPhoneController.dispose();
//     _ownerEmailController.dispose();

//     _userNameController.dispose();
//     _userPhoneController.dispose();
//     _userEmailController.dispose();
//     _userPasswordController.dispose();
//     _userConfirmPasswordController.dispose();
//     super.dispose();
//   }

//   bool _validateBusinessStep() {
//     if (_step1FormKey.currentState?.validate() ?? false) {
//       final business = BusinessRegistration(
//         businessName: _businessNameController.text,
//         businessNameAm: _businessNameAmController.text,
//         businessType: 'Retail',
//         phone: _businessPhoneController.text,
//         email: _businessEmailController.text.isEmpty
//             ? null
//             : _businessEmailController.text,
//         address: _businessAddressController.text,
//         city: 'Addis Ababa',
//         region: 'Addis Ababa',
//         tinNumber: _tinNumberController.text,
//         ownerName: _ownerNameController.text,
//         ownerPhone: _ownerPhoneController.text,
//         ownerEmail: _ownerEmailController.text.isEmpty
//             ? null
//             : _ownerEmailController.text,
//       );

//       ref.read(registrationProvider.notifier).updateBusinessInfo(business);
//       return true;
//     }
//     return false;
//   }

//   bool _validateUserStep() {
//     if (_step2FormKey.currentState?.validate() ?? false) {
//       if (_userPasswordController.text != _userConfirmPasswordController.text) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Passwords do not match')),
//         );
//         return false;
//       }

//       final user = UserRegistration(
//         name: _userNameController.text,
//         phone: _userPhoneController.text,
//         email: _userEmailController.text.isEmpty
//             ? null
//             : _userEmailController.text,
//         password: _userPasswordController.text,
//         role: UserRole.owner,
//       );

//       ref.read(registrationProvider.notifier).updateUserInfo(user);
//       return true;
//     }
//     return false;
//   }

//   void _selectPlan(SubscriptionPlan plan, BillingCycle billingCycle) {
//     ref.read(registrationProvider.notifier).selectPlan(plan, billingCycle);
//     ref.read(registrationProvider.notifier).nextStep();
//   }

//   Future<void> _completeRegistration() async {
//     await ref.read(registrationProvider.notifier).completeRegistration();
//     final state = ref.read(registrationProvider);

//     if (state.isSuccess) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Registration successful! Please login.')),
//       );

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
//         (route) => false,
//       );
//     } else if (state.error != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(state.error!)),
//       );
//     }
//   }

//   String? _validateRequired(String? value, String fieldName) {
//     if (value == null || value.isEmpty) {
//       return '$fieldName is required';
//     }
//     return null;
//   }

//   String? _validatePhone(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Phone number is required';
//     }
//     if (!RegExp(r'^\+251[0-9]{9}$').hasMatch(value)) {
//       return 'Please enter a valid Ethiopian phone number (+251...)';
//     }
//     return null;
//   }

//   String? _validateEmail(String? value) {
//     if (value != null && value.isNotEmpty) {
//       if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//         return 'Please enter a valid email address';
//       }
//     }
//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters long';
//     }
//     return null;
//   }

//   String? _validateTIN(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'TIN number is required';
//     }
//     if (value.length < 9) {
//       return 'TIN number must be at least 9 characters';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(registrationProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Register Business'),
//         leading: state.currentStep > 0
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () =>
//                     ref.read(registrationProvider.notifier).previousStep(),
//               )
//             : null,
//       ),
//       body: Form(
//         key: _formKey,
//         child: Stepper(
//           currentStep: state.currentStep,
//           onStepContinue: () {
//             switch (state.currentStep) {
//               case 0:
//                 if (_validateBusinessStep()) {
//                   ref.read(registrationProvider.notifier).nextStep();
//                 }
//                 break;
//               case 1:
//                 if (_validateUserStep()) {
//                   ref.read(registrationProvider.notifier).nextStep();
//                 }
//                 break;
//               case 2:
//                 // Plan selection is handled in the step itself
//                 break;
//               case 3:
//                 _completeRegistration();
//                 break;
//             }
//           },
//           onStepCancel: state.currentStep > 0
//               ? () => ref.read(registrationProvider.notifier).previousStep()
//               : null,
//           controlsBuilder: (context, details) {
//             return Padding(
//               padding: const EdgeInsets.only(top: 16),
//               child: Row(
//                 children: [
//                   if (details.onStepContinue != null)
//                     ElevatedButton(
//                       onPressed: details.onStepContinue,
//                       child: state.currentStep == 3
//                           ? state.isLoading
//                               ? const SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(),
//                                 )
//                               : const Text('Complete Registration')
//                           : const Text('Continue'),
//                     ),
//                   const SizedBox(width: 8),
//                   if (details.onStepCancel != null)
//                     TextButton(
//                       onPressed: details.onStepCancel,
//                       child: const Text('Back'),
//                     ),
//                 ],
//               ),
//             );
//           },
//           steps: [
//             // Step 1: Business Information
//             Step(
//               title: const Text('Business Information'),
//               content: _buildBusinessStep(),
//               isActive: state.currentStep >= 0,
//             ),
//             // Step 2: User Account
//             Step(
//               title: const Text('Admin Account'),
//               content: _buildUserStep(),
//               isActive: state.currentStep >= 1,
//             ),
//             // Step 3: Subscription Plan
//             Step(
//               title: const Text('Subscription Plan'),
//               content: _buildPlanStep(),
//               isActive: state.currentStep >= 2,
//             ),
//             // Step 4: Review & Complete
//             Step(
//               title: const Text('Complete Registration'),
//               content: _buildReviewStep(state),
//               isActive: state.currentStep >= 3,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBusinessStep() {
//     return Form(
//       key: _step1FormKey,
//       child: Column(
//         children: [
//           TextFormField(
//             controller: _businessNameController,
//             decoration: const InputDecoration(
//               labelText: 'Business Name (English)',
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) => _validateRequired(value, 'Business name'),
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _businessNameAmController,
//             decoration: const InputDecoration(
//               labelText: 'Business Name (Amharic)',
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) =>
//                 _validateRequired(value, 'Business name in Amharic'),
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _businessPhoneController,
//             decoration: const InputDecoration(
//               labelText: 'Business Phone',
//               prefixText: '+251 ',
//               border: OutlineInputBorder(),
//             ),
//             keyboardType: TextInputType.phone,
//             validator: _validatePhone,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _businessEmailController,
//             decoration: const InputDecoration(
//               labelText: 'Business Email (Optional)',
//               border: OutlineInputBorder(),
//             ),
//             keyboardType: TextInputType.emailAddress,
//             validator: _validateEmail,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _businessAddressController,
//             decoration: const InputDecoration(
//               labelText: 'Business Address',
//               border: OutlineInputBorder(),
//             ),
//             maxLines: 2,
//             validator: (value) => _validateRequired(value, 'Business address'),
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _tinNumberController,
//             decoration: const InputDecoration(
//               labelText: 'TIN Number',
//               border: OutlineInputBorder(),
//             ),
//             validator: _validateTIN,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _ownerNameController,
//             decoration: const InputDecoration(
//               labelText: 'Owner Name',
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) => _validateRequired(value, 'Owner name'),
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _ownerPhoneController,
//             decoration: const InputDecoration(
//               labelText: 'Owner Phone',
//               prefixText: '+251 ',
//               border: OutlineInputBorder(),
//             ),
//             keyboardType: TextInputType.phone,
//             validator: _validatePhone,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _ownerEmailController,
//             decoration: const InputDecoration(
//               labelText: 'Owner Email (Optional)',
//               border: OutlineInputBorder(),
//             ),
//             keyboardType: TextInputType.emailAddress,
//             validator: _validateEmail,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserStep() {
//     return Form(
//       key: _step2FormKey,
//       child: Column(
//         children: [
//           TextFormField(
//             controller: _userNameController,
//             decoration: const InputDecoration(
//               labelText: 'Your Name',
//               border: OutlineInputBorder(),
//             ),
//             validator: (value) => _validateRequired(value, 'Your name'),
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _userPhoneController,
//             decoration: const InputDecoration(
//               labelText: 'Your Phone',
//               prefixText: '+251 ',
//               border: OutlineInputBorder(),
//             ),
//             keyboardType: TextInputType.phone,
//             validator: _validatePhone,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _userEmailController,
//             decoration: const InputDecoration(
//               labelText: 'Your Email (Optional)',
//               border: OutlineInputBorder(),
//             ),
//             keyboardType: TextInputType.emailAddress,
//             validator: _validateEmail,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _userPasswordController,
//             decoration: const InputDecoration(
//               labelText: 'Password',
//               border: OutlineInputBorder(),
//             ),
//             obscureText: true,
//             validator: _validatePassword,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: _userConfirmPasswordController,
//             decoration: const InputDecoration(
//               labelText: 'Confirm Password',
//               border: OutlineInputBorder(),
//             ),
//             obscureText: true,
//             validator: (value) {
//               if (value != _userPasswordController.text) {
//                 return 'Passwords do not match';
//               }
//               return null;
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlanStep() {
//     return Column(
//       children: [
//         const Text(
//           'Choose your subscription plan',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Start with 14 days free trial. No credit card required.',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.grey),
//         ),
//         const SizedBox(height: 24),
//         ...SubscriptionPlan.all.map((plan) => _buildPlanCard(plan)),
//       ],
//     );
//   }

//   Widget _buildPlanCard(SubscriptionPlan plan) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   plan.name,
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: plan.id == 'basic'
//                         ? Colors.blue.shade100
//                         : plan.id == 'professional'
//                             ? Colors.green.shade100
//                             : Colors.purple.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     plan.id == 'basic'
//                         ? 'Popular'
//                         : plan.id == 'professional'
//                             ? 'Recommended'
//                             : 'Premium',
//                     style: TextStyle(
//                       color: plan.id == 'basic'
//                           ? Colors.blue.shade800
//                           : plan.id == 'professional'
//                               ? Colors.green.shade800
//                               : Colors.purple.shade800,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(plan.description),
//             const SizedBox(height: 16),
//             // Billing Options
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildBillingOption(plan, BillingCycle.monthly),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildBillingOption(plan, BillingCycle.yearly),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...plan.features.map((feature) => Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle,
//                           color: Colors.green.shade600, size: 16),
//                       const SizedBox(width: 8),
//                       Expanded(child: Text(feature)),
//                     ],
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBillingOption(SubscriptionPlan plan, BillingCycle cycle) {
//     final isYearly = cycle == BillingCycle.yearly;
//     return Card(
//       color: Colors.grey.shade50,
//       child: InkWell(
//         onTap: () => _selectPlan(plan, cycle),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               Text(
//                 cycle.displayName,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 plan.getFormattedPrice(cycle),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                 ),
//               ),
//               if (isYearly) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   plan.savingsInfo,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.green.shade700,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReviewStep(RegistrationState state) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (state.error != null) ...[
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.red.shade50,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(state.error!),
//           ),
//           const SizedBox(height: 16),
//         ],
//         const Text(
//           'Review Your Registration',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         if (state.business != null) ...[
//           _buildReviewItem('Business Name', state.business!.businessName),
//           _buildReviewItem('Business Phone', state.business!.phone),
//           _buildReviewItem('TIN Number', state.business!.tinNumber),
//           _buildReviewItem('Address', state.business!.address),
//         ],
//         if (state.user != null) ...[
//           _buildReviewItem('Admin Name', state.user!.name),
//           _buildReviewItem('Admin Phone', state.user!.phone),
//         ],
//         if (state.selectedPlan != null && state.billingCycle != null) ...[
//           _buildReviewItem('Plan',
//               '${state.selectedPlan!.name} (${state.billingCycle!.displayName})'),
//           _buildReviewItem('Amount',
//               state.selectedPlan!.getFormattedPrice(state.billingCycle!)),
//         ],
//         const SizedBox(height: 16),
//         const Text(
//           'You will get 14 days free trial to test all features. After trial period, you need to make payment to continue using the service.',
//           style: TextStyle(color: Colors.grey),
//         ),
//       ],
//     );
//   }

//   Widget _buildReviewItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
// }
