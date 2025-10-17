// mobile/lib/src/services/print_service.dart
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrintService {
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;

  Future<List<BluetoothDevice>> getAvailableDevices() async {
    try {
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      return devices
          .where((device) => device.type == BluetoothDeviceType.classic)
          .toList();
    } catch (e) {
      print('Error getting Bluetooth devices: $e');
      return [];
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;
      return true;
    } catch (e) {
      print('Failed to connect to device: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
    _connectedDevice = null;
  }

  Future<bool> printReceipt(Transaction transaction) async {
    if (_connection == null || !_connection!.isConnected) {
      throw Exception('Not connected to printer');
    }

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      // Receipt header
      bytes += generator.text(
        'Andalus Smart POS',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );

      bytes += generator.text(
        'Ethiopia',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.hr();

      // Transaction info
      bytes += generator.row([
        PosColumn(
          text: 'Receipt: ${transaction.transactionNumber}',
          width: 12,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Date: ${transaction.createdAt.toString()}',
          width: 12,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Cashier: ${transaction.user?.name ?? 'System'}',
          width: 12,
          styles: const PosStyles(align: PosAlign.left),
        ),
      ]);

      bytes += generator.hr();

      // Items
      bytes += generator.text(
        'ITEMS',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      for (final item in transaction.items) {
        bytes += generator.row([
          PosColumn(
            text: '${item.product.name}',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '${item.quantity} x ${item.unitPrice}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);

        bytes += generator.row([
          PosColumn(
            text: '${item.totalPrice}',
            width: 12,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]);
      }

      bytes += generator.hr();

      // Totals
      bytes += generator.row([
        PosColumn(
          text: 'Total:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: '${transaction.totalAmount}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Paid:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${transaction.paidAmount}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Change:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${transaction.changeAmount}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.hr();

      // Payment method
      bytes += generator.text(
        'Payment: ${transaction.paymentMethod.toUpperCase()}',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      // Footer
      bytes += generator.text(
        'Thank you for your business!',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.text(
        'Powered by Andalus Smart POS',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.feed(2);
      bytes += generator.cut();

      // Send to printer
      _connection!.output.add(Uint8List.fromList(bytes));
      await _connection!.output.allSent;

      return true;
    } catch (e) {
      print('Printing failed: $e');
      return false;
    }
  }
}

final printServiceProvider = Provider<PrintService>((ref) => PrintService());
