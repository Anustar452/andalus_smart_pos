// lib/src/utils/print_service.dart
// Service for managing Bluetooth printer connections and printing receipts using ESC/POS commands.
// Supports scanning for printers, connecting, and printing formatted receipts.
import 'package:andalus_smart_pos/src/data/models/sale.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../localization/app_localizations.dart';
import '../utils/formatters.dart';

class PrintService {
  static BluetoothDevice? _connectedDevice;
  static BluetoothCharacteristic? _printCharacteristic;
  final printServiceProvider = Provider<PrintService>((ref) {
    return PrintService();
  });

  // Scan for Bluetooth printers
  static Stream<List<BluetoothDevice>> scanForPrinters() {
    return FlutterBluePlus.scanResults.map((results) => results
        .where((r) => _isPotentialPrinter(r.device))
        .map((r) => r.device)
        .toList());
  }

  static bool _isPotentialPrinter(BluetoothDevice device) {
    // Thermal printers often have these in their name
    final printerNames = [
      'printer',
      'print',
      'pos',
      'thermal',
      'bt',
      'bluetooth'
    ];
    return printerNames
        .any((name) => device.localName.toLowerCase().contains(name));
  }

  static Future<void> startScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  static Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // Connect to a printer
  static Future<bool> connectToPrinter(BluetoothDevice device) async {
    try {
      await device.connect();
      final services = await device.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          // Look for the characteristic that supports writing (printing)
          if (characteristic.properties.write) {
            _printCharacteristic = characteristic;
            _connectedDevice = device;
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  // Disconnect from printer
  static Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _printCharacteristic = null;
    }
  }

  // Main print function
  static Future<bool> printReceipt({
    required BuildContext context,
    required String shopName,
    required String shopNameAm,
    required String address,
    required String phone,
    required String tinNumber,
    required String receiptNumber,
    required DateTime dateTime,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required String paymentMethod,
    String? telebirrRef,
    required Sale sale,
    required Map<String, String> businessInfo,
  }) async {
    if (_printCharacteristic == null) {
      _showError(context, 'No printer connected');
      return false;
    }

    try {
      // Generate ESC/POS commands
      final bytes = await _generateReceiptBytes(
        context: context,
        shopName: shopName,
        shopNameAm: shopNameAm,
        address: address,
        phone: phone,
        tinNumber: tinNumber,
        receiptNumber: receiptNumber,
        dateTime: dateTime,
        items: items,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        paymentMethod: paymentMethod,
        telebirrRef: telebirrRef,
      );

      // Send to printer
      await _printCharacteristic!.write(bytes, withoutResponse: true);

      _showSuccess(context, 'Receipt printed successfully');
      return true;
    } catch (e) {
      _showError(context, 'Printing failed: $e');
      return false;
    }
  }

  static Future<List<int>> _generateReceiptBytes({
    required BuildContext context,
    required String shopName,
    required String shopNameAm,
    required String address,
    required String phone,
    required String tinNumber,
    required String receiptNumber,
    required DateTime dateTime,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required String paymentMethod,
    String? telebirrRef,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(shopName,
        styles: const PosStyles(
            align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.text(shopNameAm,
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(address,
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Tel: ${AppFormatters.formatPhoneNumber(phone)}',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('TIN: ${AppFormatters.formatTIN(tinNumber)}',
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.hr();

    // Receipt info
    bytes += generator.text('Receipt: $receiptNumber');
    bytes += generator.text('Date: ${_formatDate(dateTime)}');
    bytes += generator.text('Time: ${_formatTime(dateTime)}');

    bytes += generator.hr();

    // Items header
    bytes += generator.row([
      PosColumn(text: 'Item', width: 8, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Qty', width: 2, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Price', width: 4, styles: const PosStyles(bold: true)),
      PosColumn(text: 'Total', width: 6, styles: const PosStyles(bold: true)),
    ]);

    bytes += generator.hr();

    // Items
    for (final item in items) {
      final name = (item['name'] as String).length > 16
          ? '${(item['name'] as String).substring(0, 16)}.'
          : item['name'] as String;

      bytes += generator.row([
        PosColumn(text: name, width: 8),
        PosColumn(text: '${item['quantity']}', width: 2),
        PosColumn(
            text: '${(item['price'] as double).toStringAsFixed(2)}', width: 4),
        PosColumn(
            text: '${(item['total'] as double).toStringAsFixed(2)}', width: 6),
      ]);
    }

    bytes += generator.hr();

    // Totals
    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: 10),
      PosColumn(text: 'ETB ${subtotal.toStringAsFixed(2)}', width: 10),
    ]);

    if (tax > 0) {
      bytes += generator.row([
        PosColumn(text: 'Tax:', width: 10),
        PosColumn(text: 'ETB ${tax.toStringAsFixed(2)}', width: 10),
      ]);
    }

    if (discount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Discount:', width: 10),
        PosColumn(text: '-ETB ${discount.toStringAsFixed(2)}', width: 10),
      ]);
    }

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'TOTAL:', width: 10, styles: const PosStyles(bold: true)),
      PosColumn(
          text: 'ETB ${total.toStringAsFixed(2)}',
          width: 10,
          styles: const PosStyles(bold: true)),
    ]);

    bytes += generator.hr();

    // Payment info
    bytes += generator.text(
        'Payment: ${_getPaymentMethodName(paymentMethod, AppLocalizations.of(context))}');

    if (telebirrRef != null) {
      bytes += generator.text('Ref: $telebirrRef');
    }

    bytes += generator.text('');
    bytes += generator.text('Thank you for your business!',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('እናመሰግናለን!',
        styles: const PosStyles(align: PosAlign.center));

    bytes += generator.text('');
    bytes += generator.text('');

    // Cut paper
    bytes += generator.cut();

    return bytes;
  }

  static String _getPaymentMethodName(
      String method, AppLocalizations localizations) {
    switch (method.toLowerCase()) {
      case 'cash':
        return localizations.cash;
      case 'telebirr':
        return localizations.telebirr;
      case 'card':
        return localizations.card;
      case 'credit':
        return localizations.credit;
      case 'bank_transfer':
        return localizations.bankTransfer;
      default:
        return method;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Get connection status
  static bool get isConnected => _connectedDevice != null;

  static String get connectedDeviceName =>
      _connectedDevice?.localName ?? 'No printer connected';
}
