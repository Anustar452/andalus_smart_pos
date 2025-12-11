// lib/src/services/receipt_service.dart
// Service for generating and printing sales receipt PDFs.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/sale.dart';
import '../data/models/sale_item.dart';
import '../localization/app_localizations.dart';

class ReceiptService {
  static const double _receiptWidth = 80.0; // mm
  static const double _mmToPoint = 2.83465; // 1mm = 2.83465 points

  Future<pw.Document> generateReceiptPDF({
    required Sale sale,
    required List<SaleItem> items,
    required Map<String, dynamic> businessInfo,
    required AppLocalizations localizations,
    bool includeAmharic = true,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          _receiptWidth * _mmToPoint,
          double.infinity,
          marginAll: 4 * _mmToPoint,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // === HEADER ===
              _buildHeader(businessInfo, includeAmharic),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // === SALE INFO ===
              _buildSaleInfo(sale, localizations),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 8),

              // === ITEMS TABLE ===
              _buildItemsTable(items, localizations),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 8),

              // === TOTALS ===
              _buildTotals(sale, localizations),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // === PAYMENT INFO ===
              _buildPaymentInfo(sale, localizations),

              pw.SizedBox(height: 12),

              // === FOOTER ===
              _buildFooter(businessInfo, includeAmharic, localizations),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(
      Map<String, dynamic> businessInfo, bool includeAmharic) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          businessInfo['shopName'] ?? 'Andalus Smart POS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        if (includeAmharic && businessInfo['shopNameAm'] != null)
          pw.Text(
            businessInfo['shopNameAm']!,
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        pw.SizedBox(height: 4),
        if (businessInfo['address'] != null)
          pw.Text(
            businessInfo['address']!,
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        if (businessInfo['phone'] != null)
          pw.Text(
            'Tel: ${businessInfo['phone']!}',
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        if (businessInfo['tinNumber'] != null)
          pw.Text(
            'TIN: ${businessInfo['tinNumber']!}',
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
      ],
    );
  }

  pw.Widget _buildSaleInfo(Sale sale, AppLocalizations localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${localizations.receipt}:',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              sale.saleId,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${localizations.time}:',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              sale.formattedDateTime,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        if (sale.customerName != null && sale.customerName!.isNotEmpty)
          pw.Column(
            children: [
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${localizations.translate("customer")}:',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    sale.customerName!,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        if (sale.userName != null && sale.userName!.isNotEmpty)
          pw.Column(
            children: [
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${localizations.translate("cashier")}:',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    sale.userName!,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildItemsTable(
      List<SaleItem> items, AppLocalizations localizations) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      border: pw.TableBorder(
        verticalInside: const pw.BorderSide(width: 0),
        horizontalInside: const pw.BorderSide(width: 0),
      ),
      children: [
        // Header row
        pw.TableRow(
          children: [
            pw.Text(
              localizations.item,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              localizations.qty,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              localizations.translate('price'),
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.right,
            ),
            pw.Text(
              localizations.total,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.right,
            ),
          ],
        ),

        pw.TableRow(
          children: [
            pw.Divider(thickness: 0.5),
            pw.Divider(thickness: 0.5),
            pw.Divider(thickness: 0.5),
            pw.Divider(thickness: 0.5),
          ],
        ),

        // Item rows
        ...items
            .map((item) => pw.TableRow(
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          _truncateText(item.productName, 18),
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                        if (item.productNameAm != null &&
                            item.productNameAm!.isNotEmpty)
                          pw.Text(
                            _truncateText(item.productNameAm!, 18),
                            style: pw.TextStyle(
                                fontSize: 7, color: PdfColors.grey600),
                          ),
                      ],
                    ),
                    pw.Text(
                      item.quantity.toString(),
                      style: const pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'ETB ${item.unitPrice.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.right,
                    ),
                    pw.Text(
                      'ETB ${item.totalPrice.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.right,
                    ),
                  ],
                ))
            .toList(),
      ],
    );
  }

  pw.Widget _buildTotals(Sale sale, AppLocalizations localizations) {
    return pw.Column(
      children: [
        // Use pw.Row instead of TableRow
        _buildTotalRowWidget(
          '${localizations.subtotal}:',
          'ETB ${sale.subtotal.toStringAsFixed(2)}',
        ),
        if (sale.taxAmount > 0)
          _buildTotalRowWidget(
            '${localizations.tax}:',
            'ETB ${sale.taxAmount.toStringAsFixed(2)}',
          ),
        if (sale.discountAmount > 0)
          _buildTotalRowWidget(
            '${localizations.discount}:',
            '-ETB ${sale.discountAmount.toStringAsFixed(2)}',
          ),
        pw.SizedBox(height: 4),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 4),
        _buildTotalRowWidget(
          '${localizations.total}:',
          'ETB ${sale.finalAmount.toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    );
  }

  pw.Widget _buildTotalRowWidget(String label, String value,
      {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentInfo(Sale sale, AppLocalizations localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${localizations.paymentMethod}:',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              _getPaymentMethodDisplay(sale.paymentMethod, localizations),
              style: pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        if (sale.paymentReference != null && sale.paymentReference!.isNotEmpty)
          pw.Column(
            children: [
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${localizations.telebirrReference}:',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    sale.paymentReference!,
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildFooter(Map<String, dynamic> businessInfo, bool includeAmharic,
      AppLocalizations localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          localizations.thankYou,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
        if (includeAmharic)
          pw.Text(
            'እናመሰግናለን!',
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        pw.SizedBox(height: 8),
        if (businessInfo['receiptFooter'] != null)
          pw.Text(
            businessInfo['receiptFooter']!,
            style: const pw.TextStyle(fontSize: 7),
            textAlign: pw.TextAlign.center,
          ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Powered by Andalus Smart POS',
          style: pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  String _getPaymentMethodDisplay(
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

  // === FILE MANAGEMENT ===
  Future<File> saveReceiptToFile({
    required Sale sale,
    required pw.Document pdf,
    String? customPath,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${directory.path}/receipts');

    if (!receiptsDir.existsSync()) {
      await receiptsDir.create(recursive: true);
    }

    final fileName =
        'receipt_${sale.saleId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = customPath ?? '${receiptsDir.path}/$fileName';
    final file = File(filePath);

    final pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes);

    return file;
  }

  Future<List<File>> getSavedReceipts() async {
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${directory.path}/receipts');

    if (!receiptsDir.existsSync()) {
      return [];
    }

    final files = receiptsDir.listSync();
    return files
        .where((file) => file is File && file.path.endsWith('.pdf'))
        .map((file) => file as File)
        .toList();
  }

  Future<void> deleteOldReceipts({int daysToKeep = 30}) async {
    final directory = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${directory.path}/receipts');

    if (!receiptsDir.existsSync()) {
      return;
    }

    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final files = receiptsDir.listSync();

    for (final file in files) {
      if (file is File) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
        }
      }
    }
  }

  // === PRINTING ===
  Future<void> printReceipt({
    required Sale sale,
    required List<SaleItem> items,
    required Map<String, dynamic> businessInfo,
    required AppLocalizations localizations,
  }) async {
    try {
      final pdf = await generateReceiptPDF(
        sale: sale,
        items: items,
        businessInfo: businessInfo,
        localizations: localizations,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      // Save copy for records
      await saveReceiptToFile(sale: sale, pdf: pdf);
    } catch (e) {
      print('PDF printing error: $e');
      rethrow;
    }
  }
}

// Provider
final receiptServiceProvider = Provider<ReceiptService>((ref) {
  return ReceiptService();
});
