import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/localization/app_localizations.dart';
import 'dashboard_screen.dart';
import 'pos_screen.dart';
import 'sales_history_screen.dart';
import 'customer_management_screen.dart';
import 'product_management_screen.dart';
import 'category_management_screen.dart';
import 'package:andalus_smart_pos/src/ui/screens/account_settings_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final List<Widget> screens = [
      const DashboardScreen(),
      const PosScreen(),
      const SalesHistoryScreen(),
      const CustomerManagementScreen(),
      const ProductManagementScreen(),
      const CategoryManagementScreen(),
      const AccountSettingsScreen(), // Use the combined screen
    ];

    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard_outlined),
        activeIcon: const Icon(Icons.dashboard),
        label: localizations.dashboard,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.point_of_sale_outlined),
        activeIcon: const Icon(Icons.point_of_sale),
        label: localizations.pointOfSale,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.receipt_long_outlined),
        activeIcon: const Icon(Icons.receipt_long),
        label: localizations.salesHistory,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.people_outline),
        activeIcon: const Icon(Icons.people),
        label: localizations.customers,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.inventory_2_outlined),
        activeIcon: const Icon(Icons.inventory_2),
        label: localizations.products,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.category_outlined),
        activeIcon: const Icon(Icons.category),
        label: localizations.categories,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings_outlined),
        activeIcon: const Icon(Icons.settings),
        label: localizations.settings, // Now this shows both account & settings
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          items: navItems,
        ),
      ),
    );
  }
}
