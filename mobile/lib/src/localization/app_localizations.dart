//src/localization/app_localizations.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations == null) {
      throw FlutterError(
          'AppLocalizations.of() called with a context that does not contain AppLocalizations.\n'
          'No AppLocalizations ancestor could be found starting from the context that was passed to AppLocalizations.of(). '
          'This usually happens when the context provided is from the same StatefulWidget as that whose build '
          'function actually creates the AppLocalizations widget.\n'
          'The context used was: $context');
    }
    return localizations;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Andalus Smart POS',
      'dashboard': 'Dashboard',
      'pointOfSale': 'Point of Sale',
      'salesHistory': 'Sales History',
      'customers': 'Customers',
      'products': 'Products',
      'categories': 'Categories',
      'settings': 'Settings',
      'todayRevenue': 'Today\'s Revenue',
      'todayOrders': 'Today\'s Orders',
      'outstandingCredit': 'Outstanding Credit',
      'overdue': 'Overdue',
      'totalRevenue': 'Total Revenue',
      'totalOrders': 'Total Orders',
      'averageOrderValue': 'Average Order Value',
      'salesPerformance': 'Sales Performance',
      'creditOverview': 'Credit Overview',
      'recentSales': 'Recent Sales',
      'searchProducts': 'Search products...',
      'shoppingCart': 'Shopping Cart',
      'clearAll': 'Clear All',
      'totalAmount': 'Total Amount',
      'completeSale': 'Complete Sale',
      'selectPaymentMethod': 'Select Payment Method',
      'cash': 'Cash',
      'telebirr': 'Telebirr',
      // 'card': 'Card',
      'bankTransfer': 'Bank Transfer',
      'credit': 'Credit',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'businessInformation': 'Business Information',
      'shopNameEnglish': 'Shop Name (English)',
      'shopNameAmharic': 'Shop Name (Amharic)',
      'address': 'Address',
      'phone': 'Phone',
      'tinNumber': 'TIN Number',
      'appearanceLanguage': 'Appearance & Language',
      'themeMode': 'Theme Mode',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'systemDefault': 'System Default',
      'english': 'English',
      'amharic': 'Amharic',
      'posSettings': 'POS Settings',
      'autoPrintReceipts': 'Auto Print Receipts',
      'enableCustomerSelection': 'Enable Customer Selection',
      'defaultPaymentMethod': 'Default Payment Method',
      'creditSettings': 'Credit Settings',
      'enableCreditSystem': 'Enable Credit System',
      'defaultCreditLimit': 'Default Credit Limit (ETB)',
      'defaultPaymentTerms': 'Default Payment Terms (Days)',
      'syncSettings': 'Sync Settings',
      'enableDataSync': 'Enable Data Sync',
      'syncInterval': 'Sync Interval (minutes)',
      'advancedSettings': 'Advanced Settings',
      'enableTax': 'Enable Tax',
      'taxRate': 'Tax Rate (%)',
      'enableDiscounts': 'Enable Discounts',
      'lowStockNotifications': 'Low Stock Notifications',
      'lowStockThreshold': 'Low Stock Threshold',
      'dangerZone': 'Danger Zone',
      'resetToDefaults': 'Reset to Default Settings',
      'noSalesToday': 'No sales today',
      'noProductsFound': 'No products found',
      'yourCartEmpty': 'Your cart is empty',
      'addProductsGetStarted': 'Add products to get started',
      'saleCompleted': 'Sale completed successfully!',
      'errorLoadingData': 'Error loading data',
      'settingsSaved': 'Settings saved successfully!',
      'settingsReset': 'Settings reset to defaults!',
      'account': 'Account',
      'accountSettings': 'Account Settings',
      'security': 'Security',
      'changePassword': 'Change Password',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmNewPassword': 'Confirm New Password',
      'Are you sure you want to logout?': 'Are you sure you want to logout?',
      'weeklySales': 'Weekly Sales',
      'orders': 'orders',
      'refresh': 'Refresh',
      'performanceOverview': 'Performance Overview',
      'customersWithBalance': 'Customers with Balance',
      'overdueAmount': 'Overdue Amount',
      'databaseNeedsUpdate':
          'Database schema needs update. Please try refreshing.',
      'tryAgain': 'Try Again',
      'up': 'Up',
      'down': 'Down',
      'sale': 'Sale',
      'today': 'Today',
      'completeFirstSale': 'Complete your first sale to see it here!',
      'stockAlert': 'Stock Alert',
      'quickActions': 'Quick Actions',
      'newSale': 'New Sale',
      'addProduct': 'Add Product',
      'addCustomer': 'Add Customer',
      'reports': 'Reports',
      'salesAnalytics': 'Sales Analytics',
      'chartsComingSoon': 'Charts Coming Soon',
      'installFlChart': 'Install fl_chart for beautiful analytics',
      'allProductsWellStocked': 'All products are well stocked',
      'moreProducts': '+{count} more products',
      'left': 'left',
      'calendarSettings': 'Calendar Settings',
      'calendarType': 'Calendar Type',
      'calendarDescription':
          'Choose between Gregorian and Ethiopian calendar systems',
      'fontSize': 'Font Size',
      'small': 'Small',
      'large': 'Large',
      'items sold': 'items sold',
      'with balance': 'with balance',
      'outstanding': 'Outstanding',
      'thisMonth': 'This Month', // ... existing translations
      'productsReport': 'Products Report',
      'customersReport': 'Customers Report',
      'financialReport': 'Financial Report',
      'selectDateRange': 'Select Date Range',
      'basicPlanFeatures': 'Basic Plan: Basic reports available',
      'professionalPlanFeatures':
          'Professional Plan: Advanced analytics available',
      'enterprisePlanFeatures': 'Enterprise Plan: Complete analytics available',
      'plan': 'Plan',
      'basicReportsDescription': 'Basic sales reports and analytics',
      'professionalReportsDescription':
          'Advanced product and customer analytics',
      'enterpriseReportsDescription':
          'Complete financial and predictive analytics',
      'upgradeForAdvancedReports': 'Upgrade for advanced reports',
      'upgrade': 'Upgrade',
      'professionalPlanRequired': 'Professional Plan Required',
      'enterprisePlanRequired': 'Enterprise Plan Required',
      'productsReportAvailableInPlan':
          'Products Report is available in the {plan} plan',
      'customersReportAvailableInPlan':
          'Customers Report is available in the {plan} plan',
      'financialReportAvailableInPlan':
          'Financial Report is available in the {plan} plan',
      'upgradeYourPlan': 'Upgrade Your Plan',
      'upgradeForAdvancedAnalytics':
          'Upgrade to access advanced analytics and reporting features.',
      'viewPlans': 'View Plans',
      'salesByPaymentMethod': 'Sales by Payment Method',
      'revenueByDay': 'Revenue by Day',
      'dailySalesTrend': 'Daily Sales Trend',
      'topSellingHours': 'Top Selling Hours',
      'customerRetention': 'Customer Retention',
      'salesVelocity': 'Sales Velocity',
      'profitMarginAnalysis': 'Profit Margin Analysis',
      'inventoryTurnover': 'Inventory Turnover',
      'abcAnalysis': 'ABC Analysis',
      'stockOptimization': 'Stock Optimization',
      'productsOverview': 'Products Overview',
      'totalProducts': 'Total Products',
      'lowStock': 'Low Stock',
      'outOfStock': 'Out of Stock',
      'topSellingProducts': 'Top Selling Products',
      'sold': 'sold',
      'customersOverview': 'Customers Overview',
      'topCustomers': 'Top Customers',
      'customerAcquisition': 'Customer Acquisition',
      'averageCustomerValue': 'Average Customer Value',
      'customerLifetimeValue': 'Customer Lifetime Value',
      'churnRiskAnalysis': 'Churn Risk Analysis',
      'financialOverview': 'Financial Overview',
      'revenueTrend': 'Revenue Trend',
      'profitMarginTrend': 'Profit Margin Trend',
      'cashFlowAnalysis': 'Cash Flow Analysis',
      'financialRatios': 'Financial Ratios',
      'breakEvenAnalysis': 'Break-Even Analysis',
      'advancedAnalyticsFeature':
          'Advanced analytics feature available in higher plans',
      'yesterday': 'Yesterday',
      'thisWeek': 'This Week',
      'lastWeek': 'Last Week',
      'lastMonth': 'Last Month',
      'last3Months': 'Last 3 Months',
      'last6Months': 'Last 6 Months',
      'thisYear': 'This Year',
      'lastYear': 'Last Year',
      'subscriptionPlans': 'Subscription Plans',
      'choosePerfectPlan': 'Choose the perfect plan for your business',
      'startWithFreeTrial':
          'Start with 14 days free trial. No credit card required.',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'save20Percent': 'Save 20%',
      'popular': 'Popular',
      'selected': 'Selected',
      'selectPlan': 'Select Plan',
      'paymentMethod': 'Payment Method',
      'card': 'Credit/Debit Card',
      'orderSummary': 'Order Summary',
      'price': 'Price',
      'tax': 'Tax',
      'total': 'Total',
      'subscribeNow': 'Subscribe Now',
      'salesOverview': 'Sales Overview',
      'item': 'Item',
      'qty': 'Qty',
      'subtotal': 'Subtotal',
      'discount': 'Discount',
      'telebirrReference': 'Telebirr Reference',
      'thankYou': 'Thank you for your business!',
      'receipt': 'Receipt',
      'time': 'Time',
      'scanBarcode': 'Scan barcode',
      'scan': 'Scan',
      'selectCustomer': 'Select Customer',
      'creditAvailable': 'Credit Available',
      'connectedTo': 'Connected to',
      'noPrinterConnected': 'No printer connected',
      'testPrint': 'Test Print Receipt',
      'tryAdjustingSearch': 'Try adjusting your search or add new products',
      'registerBusiness': 'Register Business',
      'adminAccount': 'Admin Account',
      'subscriptionPlan': 'Subscription Plan',
      'reviewRegistration': 'Review & Complete',
      'verifyPhone': 'Verify Phone',
      'businessNameEnglish': 'Business Name (English)',
      'businessNameAmharic': 'Business Name (Amharic)',
      'businessPhone': 'Business Phone',
      'businessEmailOptional': 'Business Email (Optional)',
      'businessAddress': 'Business Address',
      'ownerName': 'Owner Name',
      'ownerPhone': 'Owner Phone',
      'ownerEmailOptional': 'Owner Email (Optional)',
      'yourName': 'Your Name',
      'yourPhone': 'Your Phone',
      'yourEmailOptional': 'Your Email (Optional)',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'chooseSubscriptionPlan': 'Choose your subscription plan',

      'recommended': 'Recommended',
      'premium': 'Premium',
      'standard': 'Standard',
      'reviewYourRegistration': 'Review Your Registration',
      'freeTrialNotice':
          'You will get 14 days free trial to test all features. After trial period, you need to make payment to continue using the service.',
      'verifyYourPhone': 'Verify Your Phone',
      'otpSentTo': 'We sent a 6-digit code to {phone}',
      'enterOTP': 'Enter OTP Code',
      'didNotReceiveOTP': "Didn't receive OTP?",
      'resendOTP': 'Resend OTP',
      'completeRegistration': 'Complete Registration',
      'verifyOTP': 'Verify OTP',
      'continue': 'Continue',
      'back': 'Back',
      'isRequired': 'is required',
      'phoneRequired': 'Phone number is required',
      'validEthiopianPhone':
          'Please enter a valid Ethiopian phone number (+251...)',
      'validEmail': 'Please enter a valid email address',
      'passwordRequired': 'Password is required',
      'passwordMinLength': 'Password must be at least 6 characters long',
      'tinRequired': 'TIN number is required',
      'tinMinLength': 'TIN number must be at least 9 characters',
      'otpRequired': 'OTP code is required',
      'otpLength': 'OTP code must be 6 digits',
      'passwordsDoNotMatch': 'Passwords do not match',
      'registrationSuccessful': 'Registration successful! Please login.',
      'otpSentToPhone': 'We sent a 6-digit verification code to {phone}',
      'enterOTPCode': 'Enter OTP Code',
      'verifyAndContinue': 'Verify & Continue',
      'didNotReceiveCode': "Didn't receive the code?",
      'resendAvailableIn': 'Resend available in {seconds} seconds',
      'forBusiness': 'For {business}',
      'otpMustBe6Digits': 'OTP must be 6 digits',
      'otpMustBeNumbers': 'OTP must contain only numbers',
      'otpResentSuccessfully': 'OTP resent successfully',
      'registrationComplete': 'Registration complete! Welcome to Andalus POS',
      'invalidOrExpiredOTP': 'Invalid or expired OTP code',
      'shopRegistration': 'Shop Registration',
      'ownerAccount': 'Owner Account',
      'payment': 'Payment',
      'setupYourShop': 'Setup Your Shop',
      'enterShopDetails': 'Enter your shop details to get started',
      'shopName': 'Shop Name',
      'shopCategory': 'Shop Category',
      'phoneNumber': 'Phone Number',
      'city': 'City',
      'country': 'Country',
      'shopCategoryRequired': 'Please select a shop category',
      'createOwnerAccount': 'Create Owner Account',
      'setupOwnerDetails': 'Setup your owner account details',
      'fullName': 'Full Name',
      'passwordRequirements': 'Password Requirements',
      'min6Characters': 'At least 6 characters',
      'recommendSpecialChars':
          '8+ characters with special characters recommended',
      'steps': 'Steps',
      'shop': 'Shop',
      'owner': 'Owner',
      'verify': 'Verify',

      // Subscription plans
      'basic': 'Basic',
      'professional': 'Professional',

      'cbeBirr': 'CBE Birr',
      'chapa': 'Chapa',
      'choosePaymentMethod': 'Choose Payment Method',
      'processPayment': 'Process Payment',
      'paymentSuccessful': 'Payment Successful',

      // Success
      'setupStaffAccounts': 'Setup Staff Accounts',
      'addAdminsCashiersManagers':
          'Add admins, cashiers, managers for your shop.',
      'getStarted': 'Get Started',
      'chooseYourPlan': 'Choose Your Plan',
      'billingCycle': 'Billing Cycle',
      'completePayment': 'Complete Payment',
      'paymentMethods': 'Payment Methods',
      'welcomeToAndalusPOS':
          'Welcome to Andalus POS! Your account is now active.',
      'loginToYourAccount': 'Login to your account',
      'loginWithPassword': 'Login with Password',
      'loginWithOTP': 'Login with OTP',
      'login': 'Login',
      'sendingOTP': 'Sending OTP...',
      'createNewBusiness': 'Create New Business',
      'otpSentSuccessfully': 'OTP sent successfully',
      'welcomeBack': 'Welcome Back',
      'enterCredentialsToContinue': 'Enter your credentials to continue',
      'featureComingSoon': 'This feature is coming soon',
      'forgotPassword': 'Forgot Password?',
      'or': 'OR',
      // 'forgotPassword': 'Forgot Password',
      'resetYourPassword': 'Reset Your Password',
      'enterPhoneToResetPassword':
          'Enter your phone number to reset your password',
      'verifyAndReset': 'Verify and Reset',
      'enterOTPAndNewPassword':
          'Enter the OTP sent to your phone and set a new password',
      // 'newPassword': 'New Password',
      // 'confirmNewPassword': 'Confirm New Password',
      'resetPassword': 'Reset Password',
      'passwordResetSuccessfully': 'Password Reset Successfully!',
      'youCanNowLoginWithNewPassword':
          'You can now login with your new password',
      'backToLogin': 'Back to Login',
      'resendingOTP': 'Resending OTP...',
      'otpVerifiedSuccessfully': 'OTP verified successfully!',
      'instantPayment': 'Instant payment',
      'mobileBanking': 'Mobile banking',
      'onlinePayment': 'Online payment',
      'securePayment': 'Secure payment',
    },
    'am': {
      'appTitle': 'አንዳሉስ ማርቲን ፖስ',
      'dashboard': 'ዳሽቦርድ',
      'pointOfSale': 'የሽያጭ ነጥብ',
      'salesHistory': 'የሽያጭ ታሪክ',
      'customers': 'ደንበኞች',
      'products': 'ምርቶች',
      'categories': 'ምድቦች',
      'settings': 'ማስተካከያዎች',
      'todayRevenue': 'የዛሬ ገቢ',
      'todayOrders': 'የዛሬ ትዕዛዞች',
      'outstandingCredit': 'ያልተከፈለ ክሬዲት',
      'overdue': 'በጊዜ ያልተከፈለ',
      'totalRevenue': 'ጠቅላላ ገቢ',
      'totalOrders': 'ጠቅላላ ትዕዛዞች',
      'averageOrderValue': 'አማካኝ የትዕዛዝ ዋጋ',
      'salesPerformance': 'የሽያጭ አፈፃፀም',
      'creditOverview': 'የክሬዲት አጠቃላይ እይታ',
      'recentSales': 'የቅርብ ጊዜ ሽያጮች',
      'searchProducts': 'ምርቶችን ፈልግ...',
      'shoppingCart': 'የግዢ ቋሚ',
      'clearAll': 'ሁሉንም አጥፋ',
      'totalAmount': 'ጠቅላላ መጠን',
      'completeSale': 'ሽያጭ አጠናቅቅ',
      'selectPaymentMethod': 'የክፍያ ዘዴ ይምረጡ',
      'cash': 'ካሽ',
      'telebirr': 'ቴሌብር',
      // 'card': 'ካርድ',
      'bankTransfer': 'በባንክ ማስተላለፊያ',
      'credit': 'ክሬዲት',
      'confirm': 'አረጋግጥ',
      'cancel': 'ሰርዝ',
      'businessInformation': 'የንግድ መረጃ',
      'shopNameEnglish': 'የንግድ ስም (እንግሊዝኛ)',
      'shopNameAmharic': 'የንግድ ስም (አማርኛ)',
      'address': 'አድራሻ',
      'phone': 'ስልክ',
      'tinNumber': 'TIN ቁጥር',
      'appearanceLanguage': 'ገጽታ እና ቋንቋ',
      'themeMode': 'የገጽታ ሁነታ',
      'language': 'ቋንቋ',
      'light': 'ብርሃን',
      'dark': 'ጨለማ',
      'systemDefault': 'የስርአት ነባሪ',
      'english': 'እንግሊዝኛ',
      'amharic': 'አማርኛ',
      'posSettings': 'የሽያጭ ነጥብ ማስተካከያዎች',
      'autoPrintReceipts': 'ራስ-ሰር ደረሰኝ አትም',
      'enableCustomerSelection': 'ደንበኛ ምርጫ አንቃ',
      'defaultPaymentMethod': 'ነባሪ የክፍያ ዘዴ',
      'creditSettings': 'የክሬዲት ማስተካከያዎች',
      'enableCreditSystem': 'የክሬዲት ስርአት አንቃ',
      'defaultCreditLimit': 'ነባሪ የክሬዲት ገደብ (ብር)',
      'defaultPaymentTerms': 'ነባሪ የክፍያ ውሎች (ቀናት)',
      'syncSettings': 'የማመሳሰል ማስተካከያዎች',
      'enableDataSync': 'የውሂብ ማመሳሰል አንቃ',
      'syncInterval': 'የማመሳሰል ክፍተት (ደቂቃ)',
      'advancedSettings': 'የላቀ ማስተካከያዎች',
      'enableTax': 'ታክስ አንቃ',
      'taxRate': 'የታክስ መጠን (%)',
      'enableDiscounts': 'ቅናሾች አንቃ',
      'lowStockNotifications': 'ዝቅተኛ ክምችት ማሳወቂያዎች',
      'lowStockThreshold': 'ዝቅተኛ ክምችት ደረጃ',
      'dangerZone': 'አደጋ ውስጥ ያለ አካባቢ',
      'resetToDefaults': 'ወደ ነባሪ አስተካክል',
      'noSalesToday': 'ዛሬ ሽያጭ የለም',
      'noProductsFound': 'ምንም ምርት አልተገኘም',
      'yourCartEmpty': 'የግዢ ቋሚዎ ባዶ ነው',
      'addProductsGetStarted': 'ለመጀመር ምርቶችን ያክሉ',
      'saleCompleted': 'ሽያጭ በተሳካ ሁኔታ ተጠናቅቋል!',
      'errorLoadingData': 'ውሂብ በማምጣት ላይ ስህተት',
      'settingsSaved': 'ማስተካከያዎች በተሳካ ሁኔታ ተቀምጠዋል!',
      'settingsReset': 'ማስተካከያዎች ወደ ነባሪ ተመልሰዋል!',
      'account': 'መለያ',
      'accountSettings': 'የመለያ ማስተካከያዎች',
      'security': 'ደህንነት',
      'changePassword': 'የይለፍ ቃል ይቀይሩ',
      'currentPassword': 'አሁን ያለው የይለፍ ቃል',
      'newPassword': 'አዲስ የይለፍ ቃል',
      'confirmNewPassword': 'አዲሱን የይለፍ ቃል ያረጋግጡ',
      'Are you sure you want to logout?': 'እርግጠኛ ነህ መውጣት ትፈልጋለህ?',
      'weeklySales': 'የሳምንት ሽያጭ',
      'orders': 'ትዕዛዞች',
      'refresh': 'አድስ',
      'performanceOverview': 'የአፈፃፀም አጠቃላይ እይታ',
      'customersWithBalance': 'ቀሪ ሂሳብ ያላቸው ደንበኞች',
      'overdueAmount': 'በጊዜ ያልተከፈለ መጠን',
      'databaseNeedsUpdate': 'የውሂብ ጎታ ማዘመን ያስፈልጋል። እባክዎ እንደገና ይሞክሩ።',
      'tryAgain': 'እንደገና ሞክር',
      'up': 'መውጣት',
      'down': 'መውረድ',
      'sale': 'ሽያጭ',
      'today': 'ዛሬ',
      'completeFirstSale': 'ለማየት የመጀመሪያ ሽያጭዎን ያጠናቅቁ!',
      'stockAlert': 'የክምችት ማስጠንቀቂያ',
      'quickActions': 'ፈጣን እርምጃዎች',
      'newSale': 'አዲስ ሽያጭ',
      'addProduct': 'ምርት ጨምር',
      'addCustomer': 'ደንበኛ ጨምር',
      'reports': 'ሪፖርቶች',
      'salesAnalytics': 'የሽያጭ ትንታኔ',
      'chartsComingSoon': 'ቻርቶች በቅርብ ይመጣሉ',
      'installFlChart': 'ለሚያምሩ ትንታኔዎች fl_chart ጫን',
      'allProductsWellStocked': 'ሁሉም ምርቶች በደንብ ተቀምጠዋል',
      'moreProducts': '+{count} ተጨማሪ ምርቶች',
      'left': 'ቀርቷል',
      'calendarSettings': 'የቀን መቁጠሪያ ማስተካከያዎች',
      'calendarType': 'የቀን መቁጠሪያ አይነት',
      'calendarDescription':
          'በመተግበሪያው ውስጥ ለቀን ማሳያ ግሪጎርያን እና ኢትዮጵያዊ ቀን መቁጠሪያ ስርዓቶችን ይምረጡ',
      'fontSize': 'የፊደል መጠን',
      'small': 'ትንሽ',
      'large': 'ትልቅ',
      'items sold': 'የተሸጡ እቃዎች',
      'with balance': 'ቀሪ ሒሳብ ያላቸው',
      'outstanding': 'ያልተከፈለ',
      'thisMonth': 'በዚህ ወር',
      'productsReport': 'የምርቶች ሪፖርት',
      'customersReport': 'የደንበኞች ሪፖርት',
      'financialReport': 'የፋይናንስ ሪፖርት',
      'selectDateRange': 'የቀን ክልል ይምረጡ',
      'basicPlanFeatures': 'መሰረታዊ እቅድ: መሰረታዊ ሪፖርቶች ይገኛሉ',
      'professionalPlanFeatures': 'ፕሮፌሽናል እቅድ: የላቀ ትንታኔ ይገኛል',
      'enterprisePlanFeatures': 'ኢንተርፕራይዝ እቅድ: ሙሉ ትንታኔ ይገኛል',
      'plan': 'እቅድ',
      'basicReportsDescription': 'መሰረታዊ የሽያጭ ሪፖርቶች እና ትንታኔ',
      'professionalReportsDescription': 'የላቀ የምርት እና የደንበኞች ትንታኔ',
      'enterpriseReportsDescription': 'ሙሉ የፋይናንስ እና ትንበያ ትንታኔ',
      'upgradeForAdvancedReports': 'ለላቀ ሪፖርቶች አሻሽል',
      'upgrade': 'አሻሽል',
      'professionalPlanRequired': 'ፕሮፌሽናል እቅድ ያስፈልጋል',
      'enterprisePlanRequired': 'ኢንተርፕራይዝ እቅድ ያስፈልጋል',
      'productsReportAvailableInPlan': 'የምርቶች ሪፖርት በ{plan} እቅድ ይገኛል',
      'customersReportAvailableInPlan': 'የደንበኞች ሪፖርት በ{plan} እቅድ ይገኛል',
      'financialReportAvailableInPlan': 'የፋይናንስ ሪፖርት በ{plan} እቅድ ይገኛል',
      'upgradeYourPlan': 'እቅድዎን አሻሽል',
      'upgradeForAdvancedAnalytics': 'የላቀ ትንታኔ እና የሪፖርት ባህሪያትን ለማግኘት አሻሽል።',
      'viewPlans': 'እቅዶችን ይመልከቱ',
      'salesByPaymentMethod': 'በክፍያ ዘዴ ሽያጭ',
      'revenueByDay': 'በቀን ገቢ',
      'dailySalesTrend': 'ዕለታዊ የሽያጭ አዝማሚያ',
      'topSellingHours': 'ከፍተኛ የሽያጭ ሰዓታት',
      'customerRetention': 'የደንበኞች መጠባበቂያ',
      'salesVelocity': 'የሽያጭ ፍጥነት',
      'profitMarginAnalysis': 'የትርፍ ህዳግ ትንታኔ',
      'inventoryTurnover': 'የክምችት ማዞሪያ',
      'abcAnalysis': 'ABC ትንታኔ',
      'stockOptimization': 'የክምችት ማመቻቸት',
      'productsOverview': 'የምርቶች አጠቃላይ እይታ',
      'totalProducts': 'ጠቅላላ ምርቶች',
      'lowStock': 'ዝቅተኛ ክምችት',
      'outOfStock': 'የተጠናቀቀ',
      'topSellingProducts': 'ከፍተኛ የሚሸጡ ምርቶች',
      'sold': 'ተሸጧል',
      'customersOverview': 'የደንበኞች አጠቃላይ እይታ',
      'topCustomers': 'ከፍተኛ ደንበኞች',
      'customerAcquisition': 'የደንበኞች መግዛት',
      'averageCustomerValue': 'አማካኝ የደንበኛ ዋጋ',
      'customerLifetimeValue': 'የደንበኛ የህይወት ዘመን ዋጋ',
      'churnRiskAnalysis': 'የደንበኛ መጥፋት አደጋ ትንታኔ',
      'financialOverview': 'የፋይናንስ አጠቃላይ እይታ',
      'revenueTrend': 'የገቢ አዝማሚያ',
      'profitMarginTrend': 'የትርፍ ህዳግ አዝማሚያ',
      'cashFlowAnalysis': 'የገንዘብ ፍሰት ትንታኔ',
      'financialRatios': 'የፋይናንስ ሬሾዎች',
      'breakEvenAnalysis': 'የትርፍ-የወጪ ትንታኔ',
      'advancedAnalyticsFeature': 'የላቀ ትንታኔ ባህሪ በከፍተኛ እቅዶች ይገኛል',
      'yesterday': 'ትላንት',
      'thisWeek': 'በዚህ ሳምንት',
      'lastWeek': 'ያለፈው ሳምንት',
      'lastMonth': 'ያለፈው ወር',
      'last3Months': 'ያለፉት 3 ወራት',
      'last6Months': 'ያለፉት 6 ወራት',
      'thisYear': 'በዚህ ዓመት',
      'lastYear': 'ያለፈው ዓመት',
      'subscriptionPlans': 'የደንበኝነት እቅዶች',
      'choosePerfectPlan': 'ለንግድዎ ተስማሚ እቅድ ይምረጡ',
      'startWithFreeTrial': 'በ14 ቀናት ነፃ ሙከራ ይጀምሩ። የክሬዲት ካርድ አያስፈልግም።',
      'monthly': 'ወርሃዊ',
      'yearly': 'ዓመታዊ',
      'save20Percent': '20% ይቆጥቡ',
      'popular': 'ተወዳጅ',
      'selected': 'ተመርጧል',
      'selectPlan': 'እቅድ ይምረጡ',
      'paymentMethod': 'የክፍያ ዘዴ',
      'card': 'ክሬዲት/ዲቢት ካርድ',
      'orderSummary': 'የትዕዛዝ ማጠቃለያ',
      // 'plan': 'እቅድ',
      'price': 'ዋጋ',
      'tax': 'ታክስ',
      'total': 'ጠቅላላ',
      'subscribeNow': 'አሁን ይመዝገቡ',
      'salesOverview': 'የሽያጭ አጠቃላይ እይታ',
      'item': 'እቃ',
      'qty': 'ብዛት',
      'subtotal': 'ንዑስ ድምር',
      'discount': 'ቅናሽ',
      'telebirrReference': 'ቴሌብር ማጣቀሻ',
      'thankYou': 'ለንግድዎ እናመሰግናለን!',
      'receipt': 'ደረሰኝ',
      'time': 'ሰዓት',
      'scanBarcode': 'ባርኮድ ይቃኙ',
      'scan': 'ቃኝ',
      'selectCustomer': 'ደንበኛ ይምረጡ',
      'creditAvailable': 'የሚገኝ ክሬዲት',
      'connectedTo': 'ተገናኝቷል',
      'noPrinterConnected': 'ምንም ፕሪንተር አልተገናኘም',
      'testPrint': 'ደረሰኝ አትም',
      'tryAdjustingSearch': 'ፍለጋዎን ያስተካክሉ ወይም አዲስ ምርቶችን ያክሉ',
      'registerBusiness': 'የንግድ ሥራ ምዝገባ',
      'adminAccount': 'የአስተዳዳሪ መለያ',
      'subscriptionPlan': 'የደንበኝነት አቅም',
      'reviewRegistration': 'ግምገማ እና ማጠናቀቅ',
      'verifyPhone': 'ስልክ ማረጋገጫ',
      'businessNameEnglish': 'የንግድ ሥራ ስም (እንግሊዝኛ)',
      'businessNameAmharic': 'የንግድ ሥራ ስም (አማርኛ)',
      'businessPhone': 'የንግድ ሥራ ስልክ',
      'businessEmailOptional': 'የንግድ ሥራ ኢሜይል (አማራጭ)',
      'businessAddress': 'የንግድ ሥራ አድራሻ',
      'ownerName': 'የባለቤት ስም',
      'ownerPhone': 'የባለቤት ስልክ',
      'ownerEmailOptional': 'የባለቤት ኢሜይል (አማራጭ)',
      'yourName': 'ስምዎ',
      'yourPhone': 'ስልክዎ',
      'yourEmailOptional': 'ኢሜይልዎ (አማራጭ)',
      'password': 'የይለፍ ቃል',
      'confirmPassword': 'የይለፍ ቃል አረጋግጥ',
      'chooseSubscriptionPlan': 'የደንበኝነት አቅምዎን ይምረጡ',
      'recommended': 'የሚመከር',
      'premium': 'ፕሪሚየም',
      'standard': 'መደበኛ',
      'reviewYourRegistration': 'ምዝገባዎን ይገምግሙ',
      'freeTrialNotice':
          'ሁሉንም ባህሪያት ለመሞከር 14 ቀናት ነፃ ሙከራ ያገኛሉ። ከሙከራ ጊዜ በኋላ አገልግሎቱን ለመጠቀም ክፍያ ማድረግ ያስፈልግዎታል።',
      'verifyYourPhone': 'ስልክዎን ያረጋግጡ',
      'otpSentTo': '6-አሃዝ ኮድ ወደ {phone} ልከናል',
      'enterOTP': 'OTP ኮድ ያስገቡ',
      'didNotReceiveOTP': 'OTP አልደረሰም?',
      'resendOTP': 'OTP እንደገና ላክ',
      'completeRegistration': 'ምዝገባውን ይጨርሱ',
      'verifyOTP': 'OTP አረጋግጥ',
      'continue': 'ቀጥል',
      'back': 'ተመለስ',
      'isRequired': 'ያስፈልጋል',
      'phoneRequired': 'ስልክ ቁጥር ያስፈልጋል',
      'validEthiopianPhone': 'እባክዎ ትክክለኛ የኢትዮጵያ ስልክ ቁጥር ያስገቡ (+251...)',
      'validEmail': 'እባክዎ ትክክለኛ ኢሜይል አድራሻ ያስገቡ',
      'passwordRequired': 'የይለፍ ቃል ያስፈልጋል',
      'passwordMinLength': 'የይለፍ ቃል ቢያንስ 6 ቁምፊ ርዝመት ሊኖረው ይገባል',
      'tinRequired': 'TIN ቁጥር ያስፈልጋል',
      'tinMinLength': 'TIN ቁጥር ቢያንስ 9 ቁምፊ ርዝመት ሊኖረው ይገባል',
      'otpRequired': 'OTP ኮድ ያስፈልጋል',
      'otpLength': 'OTP ኮድ 6 አሃዝ ሊኖረው ይገባል',
      'passwordsDoNotMatch': 'የይለፍ ቃላት አይመሳሰሉም',
      'registrationSuccessful': 'ምዝገባ በተሳካ ሁኔታ ተጠናቋል! እባክዎ ይግቡ።',
      'otpSentToPhone': '6-አሃዝ ማረጋገጫ ኮድ ወደ {phone} ልከናል',
      'enterOTPCode': 'OTP ኮድ ያስገቡ',
      'verifyAndContinue': 'ያረጋግጡ እና ይቀጥሉ',
      'didNotReceiveCode': 'ኮድ አልደረሰም?',
      'resendAvailableIn': 'እንደገና ለመላክ በ {seconds} ሰከንድ ውስጥ ይገኛል',
      'forBusiness': 'ለ {business}',
      'otpMustBe6Digits': 'OTP 6 አሃዝ መሆን አለበት',
      'otpMustBeNumbers': 'OTP ቁጥሮች ብቻ ሊኖሩት ይገባል',
      'otpResentSuccessfully': 'OTP በተሳካ ሁኔታ እንደገና ተልቷል',
      'registrationComplete': 'ምዝገባ ተጠናቅቋል! ወደ አንዳሉስ POS እንኳን በደህና መጡ',
      'invalidOrExpiredOTP': 'ልክ ያልሆነ ወይም ጊዜው ያለፈ የOTP ኮድ',
      'shopRegistration': 'የሱቅ ምዝገባ',
      'ownerAccount': 'የባለቤት መለያ',
      'payment': 'ክፍያ',
      'setupYourShop': 'ሱቅዎን ያዘጋጁ',
      'enterShopDetails': 'ለመጀመር የሱቅዎን ዝርዝሮች ያስገቡ',
      'shopName': 'የሱቅ ስም',
      'shopCategory': 'የሱቅ ምድብ',
      'phoneNumber': 'ስልክ ቁጥር',
      'city': 'ከተማ',
      'country': 'አገር',
      'shopCategoryRequired': 'እባክዎ የሱቅ ምድብ ይምረጡ',
      'createOwnerAccount': 'የባለቤት መለያ ይፍጠሩ',
      'setupOwnerDetails': 'የባለቤት መለያ ዝርዝሮችዎን ያዘጋጁ',
      'fullName': 'ሙሉ ስም',
      'passwordRequirements': 'የይለፍ ቃል መስፈርቶች',
      'min6Characters': 'ቢያንስ 6 ፊደሎች',
      'recommendSpecialChars': '8+ ፊደሎች ከልዩ ምልክቶች ጋር ይመከራል',
      'steps': 'ደረጃዎች',
      'shop': 'ሱቅ',
      'owner': 'ባለቤት',
      'verify': 'ማረጋገጫ',
      'basic': 'መሰረታዊ',
      'professional': 'ፕሮፌሽናል',
      'cbeBirr': 'CBE ብር',
      'chapa': 'ቻፓ',
      'choosePaymentMethod': 'የክፍያ ዘዴ ይምረጡ',
      'processPayment': 'ክፍያ ያስገቡ',
      'paymentSuccessful': 'ክፍያ ተሳክቷል',
      'setupStaffAccounts': 'የሰራተኞች መለያዎችን ያዘጋጁ',
      'addAdminsCashiersManagers': 'ለሱቅዎ አስተዳዳሪዎች፣ ካሺዎች፣ አስተዳዳሪዎች ያክሉ',
      'getStarted': 'ጀምር',
      'chooseYourPlan': 'እቅድዎን ይምረጡ',
      'billingCycle': 'የክፍያ ዑደት',
      'completePayment': 'ክፍያውን ይጨርሱ',
      'paymentMethods': 'የክፍያ ዘዴዎች',
      'welcomeToAndalusPOS': 'ወደ አንዳሉስ POS እንኳን በደህና መጡ! መለያዎ አሁን ነቅቷል።',
      'loginToYourAccount': 'ወደ መለያዎ ይግቡ',
      'loginWithPassword': 'በይለፍ ቃል ይግቡ',
      'loginWithOTP': 'በOTP ይግቡ',
      'login': 'ግባ',
      'sendingOTP': 'OTP በማስተላለፍ ላይ...',
      'createNewBusiness': 'አዲስ ንግድ ይፍጠሩ',
      'otpSentSuccessfully': 'OTP በተሳካ ሁኔታ ተልቷል',
      'WelcomeBack': 'እንኳን ደግሞ በደህና መጡ!',
      'enterCredentialsToContinue': 'የግባ ዝርዝሮችዎን ያስገቡ',
      'featureComingSoon': 'በቅርብ ይጠብቁን!',
      'forgotPassword': 'የይለፍ ቃልዎን ረስተዋል?',
      'or': 'ወይም',
      // 'forgotPassword': 'Forgot Password',
      'resetYourPassword': 'የይለፍ ቃልዎን ይቀይሩ',
      'enterPhoneToResetPassword': 'የይለፍ ቃል ለመቀየር ስልክ ቁጥርዎን ያስገቡ',
      'verifyAndReset': 'ያረጋግጡ እና ይቀይሩ',
      'enterOTPAndNewPassword':
          'ወደ ስልክዎ የተላከውን OTP ኮድ ያስገቡ እና አዲስ የይለፍ ቃል ያስቀምጡ',
      // 'newPassword': 'New Password',
      // 'confirmNewPassword': 'Confirm New Password',
      'resetPassword': 'የይለፍ ቃል ይቀይሩ',
      'passwordResetSuccessfully': 'የይለፍ ቃልዎ በተሳካ ሁኔታ ተቀይሯል!',
      'youCanNowLoginWithNewPassword': 'አሁን በአዲሱ የይለፍ ቃል መግባት ይችላሉ።',
      'backToLogin': 'ወደ መግቢያዉ ይመለሱ',
      'resendingOTP': 'OTP እንደገና በመላክ ላይ...',
      'otpVerifiedSuccessfully': 'OTP በተሳካ ሁኔታ ተረጋግጧል!',
      'instantPayment': 'አገናኝ ክፍያ',
      'mobileBanking': 'ሞባይል ባንኪንግ',
      'onlinePayment': 'መስመር ላይ ክፍያ',
      'securePayment': 'ደህንነታዊ ክፍያ',
    }
  };

  String translate(String key, {Map<String, String>? params}) {
    String translation = _localizedValues[locale.languageCode]?[key] ?? key;

    if (params != null) {
      params.forEach((paramKey, paramValue) {
        translation = translation.replaceAll('{$paramKey}', paramValue);
      });
    }

    return translation;
  }

  // Convenience methods for common translations
  String get appTitle => translate('appTitle');
  String get dashboard => translate('dashboard');
  String get pointOfSale => translate('pointOfSale');
  String get salesHistory => translate('salesHistory');
  String get customers => translate('customers');
  String get products => translate('products');
  String get categories => translate('categories');
  String get settings => translate('settings');
  String get todayRevenue => translate('todayRevenue');
  String get todayOrders => translate('todayOrders');
  String get searchProducts => translate('searchProducts');
  String get shoppingCart => translate('shoppingCart');
  String get totalAmount => translate('totalAmount');
  String get completeSale => translate('completeSale');
  String get light => translate('light');
  String get dark => translate('dark');
  String get systemDefault => translate('systemDefault');
  String get english => translate('english');
  String get amharic => translate('amharic');
  String get themeMode => translate('themeMode');
  String get language => translate('language');
  String get appearanceLanguage => translate('appearanceLanguage');
  String get businessInformation => translate('businessInformation');
  String get shopNameEnglish => translate('shopNameEnglish');
  String get shopNameAmharic => translate('shopNameAmharic');
  String get address => translate('address');
  String get phone => translate('phone');
  String get tinNumber => translate('tinNumber');
  String get account => translate('account');
  String get accountSettings => translate('accountSettings');
  String get security => translate('security');
  String get changePassword => translate('changePassword');
  String get currentPassword => translate('currentPassword');
  String get newPassword => translate('newPassword');
  String get confirmNewPassword => translate('confirmNewPassword');
  String get weeklySales => translate('weeklySales');
  String get orders => translate('orders');
  String get refresh => translate('refresh');
  String get performanceOverview => translate('performanceOverview');
  String get customersWithBalance => translate('customersWithBalance');
  String get overdueAmount => translate('overdueAmount');
  String get today => translate('today');
  String get completeFirstSale => translate('completeFirstSale');
  String get stockAlert => translate('stockAlert');
  String get quickActions => translate('quickActions');
  String get newSale => translate('newSale');
  String get addProduct => translate('addProduct');
  String get addCustomer => translate('addCustomer');
  String get reports => translate('reports');
  String get salesAnalytics => translate('salesAnalytics');
  String get chartsComingSoon => translate('chartsComingSoon');
  String get installFlChart => translate('installFlChart');
  String get cash => translate('cash');
  String get telebirr => translate('telebirr');
  String get card => translate('card');
  String get credit => translate('credit');
  String get bankTransfer => translate('bankTransfer');
  String get errorLoadingData => translate('errorLoadingData');
  String get settingsSaved => translate('settingsSaved');
  String get settingsReset => translate('settingsReset');
  String get databaseNeedsUpdate => translate('databaseNeedsUpdate');
  String get tryAgain => translate('tryAgain');
  String get up => translate('up');
  String get down => translate('down');
  String get sale => translate('sale');
  String get recentSales => translate('recentSales');
  String get noSalesToday => translate('noSalesToday');
  String get noProductsFound => translate('noProductsFound');
  String get yourCartEmpty => translate('yourCartEmpty');
  String get addProductsGetStarted => translate('addProductsGetStarted');
  String get saleCompleted => translate('saleCompleted');
  String get areYouSureYouWantToLogout =>
      translate('Are you sure you want to logout?');
  String get clearAll => translate('clearAll');
  String get selectPaymentMethod => translate('selectPaymentMethod');
  String get confirm => translate('confirm');
  String get cancel => translate('cancel');
  String get defaultPaymentMethod => translate('defaultPaymentMethod');
  String get posSettings => translate('posSettings');
  String get autoPrintReceipts => translate('autoPrintReceipts');
  String get enableCustomerSelection => translate('enableCustomerSelection');
  String get creditSettings => translate('creditSettings');
  String get enableCreditSystem => translate('enableCreditSystem');
  String get defaultCreditLimit => translate('defaultCreditLimit');
  String get defaultPaymentTerms => translate('defaultPaymentTerms');
  String get syncSettings => translate('syncSettings');
  String get enableDataSync => translate('enableDataSync');
  String get syncInterval => translate('syncInterval');
  String get advancedSettings => translate('advancedSettings');
  String get enableTax => translate('enableTax');
  String get taxRate => translate('taxRate');
  String get enableDiscounts => translate('enableDiscounts');
  String get lowStockNotifications => translate('lowStockNotifications');
  String get lowStockThreshold => translate('lowStockThreshold');
  String get dangerZone => translate('dangerZone');
  String get resetToDefaults => translate('resetToDefaults');
  String get tryAgainText => translate('tryAgain');
  String get todayOrdersText => translate('todayOrders');
  String get noOrdersToday => translate('noOrdersToday');
  String get noOrdersTodayText => translate('noOrdersTodayText');
  String get averageOrderValue => translate('averageOrderValue');
  String get totalRevenue => translate('totalRevenue');
  String get totalOrders => translate('totalOrders');
  String get salesPerformance => translate('salesPerformance');
  String get creditOverview => translate('creditOverview');
  String get outstandingCredit => translate('outstandingCredit');
  String get overdue => translate('overdue');
  String get moreProducts => translate('moreProducts');
  String get allProductsWellStocked => translate('allProductsWellStocked');
  String get left => translate('left');
  String get calendarSettings => translate('calendarSettings');
  String get calendarType => translate('calendarType');
  String get calendarDescription => translate('calendarDescription');
  String get fontSize => translate('fontSize');
  String get small => translate('small');
  String get large => translate('large');
  String get itemsSold => translate('items sold');
  String get withBalance => translate('with balance');
  String get outstanding => translate('outstanding');
  String get thisMonth => translate('thisMonth');
  String get productsReport => translate('productsReport');
  String get customersReport => translate('customersReport');
  String get financialReport => translate('financialReport');
  String get selectDateRange => translate('selectDateRange');
  String get basicPlanFeatures => translate('basicPlanFeatures');
  String get professionalPlanFeatures => translate('professionalPlanFeatures');
  String get enterprisePlanFeatures => translate('enterprisePlanFeatures');
  String get plan => translate('plan');
  String get basicReportsDescription => translate('basicReportsDescription');
  String get professionalReportsDescription =>
      translate('professionalReportsDescription');
  String get enterpriseReportsDescription =>
      translate('enterpriseReportsDescription');
  String get upgradeForAdvancedReports =>
      translate('upgradeForAdvancedReports');
  String get upgrade => translate('upgrade');
  String get professionalPlanRequired => translate('professionalPlanRequired');
  String get enterprisePlanRequired => translate('enterprisePlanRequired');
  String get productsReportAvailableInPlan =>
      translate('productsReportAvailableInPlan');
  String get customersReportAvailableInPlan =>
      translate('customersReportAvailableInPlan');
  String get financialReportAvailableInPlan =>
      translate('financialReportAvailableInPlan');
  String get upgradeYourPlan => translate('upgradeYourPlan');
  String get upgradeForAdvancedAnalytics =>
      translate('upgradeForAdvancedAnalytics');
  String get viewPlans => translate('viewPlans');
  String get salesByPaymentMethod => translate('salesByPaymentMethod');
  String get revenueByDay => translate('revenueByDay');
  String get dailySalesTrend => translate('dailySalesTrend');
  String get topSellingHours => translate('topSellingHours');
  String get customerRetention => translate('customerRetention');
  String get salesVelocity => translate('salesVelocity');
  String get profitMarginAnalysis => translate('profitMarginAnalysis');
  String get inventoryTurnover => translate('inventoryTurnover');
  String get abcAnalysis => translate('abcAnalysis');
  String get stockOptimization => translate('stockOptimization');
  String get productsOverview => translate('productsOverview');
  String get totalProducts => translate('totalProducts');
  String get lowStock => translate('lowStock');
  String get outOfStock => translate('outOfStock');
  String get topSellingProducts => translate('topSellingProducts');
  String get sold => translate('sold');
  String get customersOverview => translate('customersOverview');
  String get topCustomers => translate('topCustomers');
  String get customerAcquisition => translate('customerAcquisition');
  String get averageCustomerValue => translate('averageCustomerValue');
  String get customerLifetimeValue => translate('customerLifetimeValue');
  String get churnRiskAnalysis => translate('churnRiskAnalysis');
  String get financialOverview => translate('financialOverview');
  String get revenueTrend => translate('revenueTrend');
  String get profitMarginTrend => translate('profitMarginTrend');
  String get cashFlowAnalysis => translate('cashFlowAnalysis');
  String get financialRatios => translate('financialRatios');
  String get breakEvenAnalysis => translate('breakEvenAnalysis');
  String get advancedAnalyticsFeature => translate('advancedAnalyticsFeature');
  String get subscriptionPlans => translate('subscriptionPlans');
  String get choosePerfectPlan => translate('choosePerfectPlan');
  String get startWithFreeTrial => translate('startWithFreeTrial');
  String get monthly => translate('monthly');
  String get yearly => translate('yearly');
  String get save20Percent => translate('save20Percent');
  String get popular => translate('popular');
  String get selected => translate('selected');
  String get selectPlan => translate('selectPlan');
  String get paymentMethod => translate('paymentMethod');
  String get orderSummary => translate('orderSummary');
  String get price => translate('price');
  String get tax => translate('tax');
  String get total => translate('total');
  String get subscribeNow => translate('subscribeNow');
  String get salesOverview => translate('salesOverview');
  String get item => translate('item');
  String get qty => translate('qty');
  String get subtotal => translate('subtotal');
  String get discount => translate('discount');
  String get telebirrReference => translate('telebirrReference');
  String get thankYou => translate('thankYou');
  String get receipt => translate('receipt');
  String get time => translate('time');
  String get scanBarcode => translate('scanBarcode');
  String get scan => translate('scan');
  String get selectCustomer => translate('selectCustomer');
  String get creditAvailable => translate('creditAvailable');
  String get connectedTo => translate('connectedTo');
  String get noPrinterConnected => translate('noPrinterConnected');
  String get testPrint => translate('testPrint');
  String get tryAdjustingSearch => translate('tryAdjustingSearch');
  String get yesterday => translate('yesterday');
  String get thisWeek => translate('thisWeek');
  String get lastWeek => translate('lastWeek');
  String get lastMonth => translate('lastMonth');
  String get last3Months => translate('last3Months');
  String get last6Months => translate('last6Months');
  String get thisYear => translate('thisYear');
  String get lastYear => translate('lastYear');
  String get cashInHand => translate('cashInHand');
  String get registerBusiness => translate('registerBusiness');
  String get adminAccount => translate('adminAccount');
  String get subscriptionPlan => translate('subscriptionPlan');
  String get reviewRegistration => translate('reviewRegistration');
  String get verifyPhone => translate('verifyPhone');
  String get businessNameEnglish => translate('businessNameEnglish');
  String get businessNameAmharic => translate('businessNameAmharic');
  String get businessPhone => translate('businessPhone');
  String get businessEmailOptional => translate('businessEmailOptional');
  String get businessAddress => translate('businessAddress');
  String get ownerName => translate('ownerName');
  String get ownerPhone => translate('ownerPhone');
  String get ownerEmailOptional => translate('ownerEmailOptional');
  String get yourName => translate('yourName');
  String get yourPhone => translate('yourPhone');
  String get yourEmailOptional => translate('yourEmailOptional');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get chooseSubscriptionPlan => translate('chooseSubscriptionPlan');
  String get recommended => translate('recommended');
  String get premium => translate('premium');
  String get standard => translate('standard');
  String get reviewYourRegistration => translate('reviewYourRegistration');
  String get freeTrialNotice => translate('freeTrialNotice');
  String get verifyYourPhone => translate('verifyYourPhone');
  String get otpSentTo => translate('otpSentTo');
  String get enterOTP => translate('enterOTP');
  String get didNotReceiveOTP => translate('didNotReceiveOTP');
  String get resendOTP => translate('resendOTP');
  String get completeRegistration => translate('completeRegistration');
  String get verifyOTP => translate('verifyOTP');
  String get back => translate('back');
  String get isRequired => translate('isRequired');
  String get phoneRequired => translate('phoneRequired');
  String get validEthiopianPhone => translate('validEthiopianPhone');
  String get validEmail => translate('validEmail');
  String get passwordRequired => translate('passwordRequired');
  String get passwordMinLength => translate('passwordMinLength');
  String get tinRequired => translate('tinRequired');
  String get tinMinLength => translate('tinMinLength');
  String get otpRequired => translate('otpRequired');
  String get otpLength => translate('otpLength');
  String get passwordsDoNotMatch => translate('passwordsDoNotMatch');
  String get registrationSuccessful => translate('registrationSuccessful');
  String get otpSentToPhone => translate('otpSentToPhone');
  String get enterOTPCode => translate('enterOTPCode');
  String get verifyAndContinue => translate('verifyAndContinue');
  String get didNotReceiveCode => translate('didNotReceiveCode');
  String get resendAvailableIn => translate('resendAvailableIn');
  String get forBusiness => translate('forBusiness');
  String get otpMustBe6Digits => translate('otpMustBe6Digits');
  String get otpMustBeNumbers => translate('otpMustBeNumbers');
  String get otpResentSuccessfully => translate('otpResentSuccessfully');
  String get registrationComplete => translate('registrationComplete');
  String get invalidOrExpiredOTP => translate('invalidOrExpiredOTP');
  // Add these getters to your translation service/class
  String get shopRegistration => translate('shopRegistration');
  String get ownerAccount => translate('ownerAccount');
  String get payment => translate('payment');
  String get setupYourShop => translate('setupYourShop');
  String get enterShopDetails => translate('enterShopDetails');
  String get shopName => translate('shopName');
  String get shopCategory => translate('shopCategory');
  String get phoneNumber => translate('phoneNumber');
  String get city => translate('city');
  String get country => translate('country');
  String get shopCategoryRequired => translate('shopCategoryRequired');
  String get createOwnerAccount => translate('createOwnerAccount');
  String get setupOwnerDetails => translate('setupOwnerDetails');
  String get fullName => translate('fullName');
  String get passwordRequirements => translate('passwordRequirements');
  String get min6Characters => translate('min6Characters');
  String get recommendSpecialChars => translate('recommendSpecialChars');
  String get steps => translate('steps');
  String get shop => translate('shop');
  String get owner => translate('owner');
  String get verify => translate('verify');
  String get basic => translate('basic');
  String get professional => translate('professional');
  String get cbeBirr => translate('cbeBirr');
  String get chapa => translate('chapa');
  String get choosePaymentMethod => translate('choosePaymentMethod');
  String get processPayment => translate('processPayment');
  String get paymentSuccessful => translate('paymentSuccessful');
  String get setupStaffAccounts => translate('setupStaffAccounts');
  String get addAdminsCashiersManagers =>
      translate('addAdminsCashiersManagers');
  String get getStarted => translate('getStarted');
  String get chooseYourPlan => translate('chooseYourPlan');
  String get billingCycle => translate('billingCycle');
  String get completePayment => translate('completePayment');
  String get paymentMethods => translate('paymentMethods');
  String get welcomeToAndalusPOS => translate('welcomeToAndalusPOS');
  String get loginToYourAccount => translate('loginToYourAccount');
  String get loginWithPassword => translate('loginWithPassword');
  String get loginWithOTP => translate('loginWithOTP');
  String get login => translate('login');
  String get sendingOTP => translate('sendingOTP');
  String get createNewBusiness => translate('createNewBusiness');
  String get otpSentSuccessfully => translate('otpSentSuccessfully');
  String get welcomeBack => translate('welcomeBack');
  String get enterCredentialsToContinue =>
      translate('enterCredentialsToContinue');
  String get featureComingSoon => translate('featureComingSoon');
  String get forgotPassword => translate('forgotPassword');
  String get or => translate('or');
  String get resetYourPassword => translate('resetYourPassword');
  String get enterPhoneToResetPassword =>
      translate('enterPhoneToResetPassword');
  String get verifyAndReset => translate('verifyAndReset');
  String get enterOTPAndNewPassword => translate('enterOTPAndNewPassword');
  String get resetPassword => translate('resetPassword');
  String get passwordResetSuccessfully =>
      translate('passwordResetSuccessfully');
  String get youCanNowLoginWithNewPassword =>
      translate('youCanNowLoginWithNewPassword');
  String get backToLogin => translate('backToLogin');
  String get resendingOTP => translate('resendingOTP');
  String get otpVerifiedSuccessfully => translate('otpVerifiedSuccessfully');
  String get instantPayment => translate('instantPayment');
  String get mobileBanking => translate('mobileBanking');
  String get onlinePayment => translate('onlinePayment');
  String get securePayment => translate('securePayment');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
