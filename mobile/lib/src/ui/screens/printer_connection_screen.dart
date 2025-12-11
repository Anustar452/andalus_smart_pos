// lib/src/ui/screens/printer_connection_screen.dart
// Screen for connecting to and managing Bluetooth printers.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../utils/print_service.dart';
import '../../localization/app_localizations.dart';

class PrinterConnectionScreen extends ConsumerStatefulWidget {
  const PrinterConnectionScreen({super.key});

  @override
  ConsumerState<PrinterConnectionScreen> createState() =>
      _PrinterConnectionScreenState();
}

class _PrinterConnectionScreenState
    extends ConsumerState<PrinterConnectionScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
    });
    PrintService.startScan();
  }

  void _stopScan() {
    setState(() {
      _isScanning = false;
    });
    PrintService.stopScan();
  }

  Future<void> _connectToPrinter(BluetoothDevice device) async {
    final success = await PrintService.connectToPrinter(device);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.localName}'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to ${device.localName}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnectPrinter() async {
    await PrintService.disconnect();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('printerSettings')),
        actions: [
          if (_isScanning)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopScan,
              tooltip: 'Stop Scan',
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
              tooltip: 'Scan for Printers',
            ),
        ],
      ),
      body: Column(
        children: [
          // Connection Status
          ListTile(
            leading: Icon(
              PrintService.isConnected ? Icons.print : Icons.print_disabled,
              color: PrintService.isConnected ? Colors.green : Colors.red,
            ),
            title: Text(PrintService.isConnected
                ? 'Connected to ${PrintService.connectedDeviceName}'
                : 'No printer connected'),
            trailing: PrintService.isConnected
                ? IconButton(
                    icon: const Icon(Icons.link_off),
                    onPressed: _disconnectPrinter,
                    tooltip: 'Disconnect',
                  )
                : null,
          ),
          const Divider(),

          // Available Printers
          Expanded(
            child: StreamBuilder<List<BluetoothDevice>>(
              stream: PrintService.scanForPrinters(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning
                              ? 'Searching for printers...'
                              : 'No printers found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                final printers = snapshot.data!;
                return ListView.builder(
                  itemCount: printers.length,
                  itemBuilder: (context, index) {
                    final device = printers[index];
                    return ListTile(
                      leading: const Icon(Icons.print),
                      title: Text(device.localName.isEmpty
                          ? 'Unknown Device'
                          : device.localName),
                      subtitle: Text(device.remoteId.toString()),
                      trailing: IconButton(
                        icon: const Icon(Icons.link),
                        onPressed: () => _connectToPrinter(device),
                        tooltip: 'Connect',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    PrintService.stopScan();
    super.dispose();
  }
}
