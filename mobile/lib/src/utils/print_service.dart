import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart'
    show LineText, BluetoothDevice;

/// Fallback stub for BluetoothPrint to ensure the symbol is defined during
/// development if the external package doesn't expose it; remove this stub
/// once the package provides BluetoothPrint or if it causes duplicate symbol
/// errors when the real class is available.
class BluetoothPrint {
  BluetoothPrint._();
  static final BluetoothPrint instance = BluetoothPrint._();

  Future<void> startScan({required Duration timeout}) async {}
  List<BluetoothDevice> get scanResults => <BluetoothDevice>[];
  Future<bool> connect(BluetoothDevice device) async => false;
  Future<void> print(List<LineText> data, BluetoothDevice device) async {}
  Future<void> disconnect() async {}
}

class PrintService {
  static final BluetoothPrint _bluetoothPrint = BluetoothPrint.instance;
  static BluetoothDevice? _connectedDevice;

  static Future<bool> initialize() async {
    try {
      await _bluetoothPrint.startScan(timeout: const Duration(seconds: 10));
      return true;
    } catch (e) {
      print('Bluetooth print initialization error: $e');
      return false;
    }
  }

  static Future<List<BluetoothDevice>> getAvailableDevices() async {
    try {
      return _bluetoothPrint.scanResults;
    } catch (e) {
      print('Error getting devices: $e');
      return [];
    }
  }

  static Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      final connected = await _bluetoothPrint.connect(device);
      if (connected) {
        _connectedDevice = device;
      }
      return connected;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  static Future<void> printReceipt({
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
    if (_connectedDevice == null) {
      throw Exception('No printer connected');
    }

    final receiptData = _buildReceiptData(
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

    try {
      await _bluetoothPrint.print(receiptData, _connectedDevice!);
    } catch (e) {
      print('Printing error: $e');
      rethrow;
    }
  }

  static List<LineText> _buildReceiptData({
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
  }) {
    final lines = <LineText>[];

    // Header
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: shopName,
      weight: 1, // Bold
      align: LineText.ALIGN_CENTER,
      size: 24,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: shopNameAm,
      align: LineText.ALIGN_CENTER,
      size: 20,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: address,
      align: LineText.ALIGN_CENTER,
      size: 18,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Tel: $phone',
      align: LineText.ALIGN_CENTER,
      size: 18,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'TIN: $tinNumber',
      align: LineText.ALIGN_CENTER,
      size: 18,
      linefeed: 1,
    ));

    // Separator
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '=' * 32,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    // Receipt info
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Receipt: $receiptNumber',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Date: ${_formatDate(dateTime)}',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Time: ${_formatTime(dateTime)}',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // Items header
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '-' * 32,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Item           Qty  Price  Total',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '-' * 32,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    // Items
    for (final item in items) {
      final name = item['name'] as String;
      final quantity = item['quantity'] as int;
      final price = item['price'] as double;
      final itemTotal = item['total'] as double;

      final truncatedName =
          name.length > 12 ? '${name.substring(0, 12)}.' : name.padRight(13);
      final qtyStr = quantity.toString().padLeft(3);
      final priceStr = price.toStringAsFixed(2).padLeft(6);
      final totalStr = itemTotal.toStringAsFixed(2).padLeft(7);

      lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '$truncatedName $qtyStr $priceStr $totalStr',
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }

    // Totals
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '-' * 32,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Subtotal:${' ' * 15}ETB ${subtotal.toStringAsFixed(2)}',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    if (tax > 0) {
      lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Tax:${' ' * 19}ETB ${tax.toStringAsFixed(2)}',
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }

    if (discount > 0) {
      lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Discount:${' ' * 14}ETB ${discount.toStringAsFixed(2)}',
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'TOTAL:${' ' * 15}ETB ${total.toStringAsFixed(2)}',
      weight: 1, // Bold
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // Payment info
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Payment: $paymentMethod',
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    if (telebirrRef != null) {
      lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Telebirr Ref: $telebirrRef',
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }

    // Footer
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '=' * 32,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'Thank you for your business!',
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: 'እናመሰግናለን!',
      align: LineText.ALIGN_CENTER,
      linefeed: 2,
    ));

    // Cut paper
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '',
      align: LineText.ALIGN_LEFT,
      linefeed: 0,
    ));

    return lines;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _bluetoothPrint.disconnect();
      _connectedDevice = null;
    }
  }

  static bool get isConnected => _connectedDevice != null;
}
