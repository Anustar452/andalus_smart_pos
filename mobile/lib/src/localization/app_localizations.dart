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
      'card': 'Card',
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
      'cash': 'ኬሽ',
      'telebirr': 'ቴሌብር',
      'card': 'ካርድ',
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
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
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
