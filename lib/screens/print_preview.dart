import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nbe/libs.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PrintPreviewScreen extends StatelessWidget {
  final List<Transaction> transactions;
  const PrintPreviewScreen({required this.transactions, super.key});

  String getMonthYear(DateTime date) {
    return DateFormat.yMMMM().format(date);
  }

  Future<bool> _requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Storage permission is required to save PDF.')),
          );
          status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Again Storage permission is required to save PDF.')),
            );
          }
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _saveAsPdf(BuildContext context, String title,
      List<Transaction> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Date', 'Karat', 'Weight (g)', 'Total Amount'],
                data: transactions
                    .map((tx) => [
                          DateFormat('dd MMM yyyy').format(tx.date),
                          '${tx.karat}K',
                          tx.weight.toStringAsFixed(2),
                          currencyFormatter(tx.totalAmount),
                        ])
                    .toList(),
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );

    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF',
        fileName: '${title.replaceAll(RegExp(r"[^\w\s-]"), "_")}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final bytes = await pdf.save();
        final file = File(result);
        await file.writeAsBytes(bytes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved to $result')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Print Preview')),
        body: const Center(child: Text('No transactions to display')),
      );
    }

    final firstDate = transactions.first.date;
    final title = getMonthYear(firstDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Preview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(tx.date)),
                      Text('${tx.karat}K'),
                      Text('${tx.weight.toStringAsFixed(2)}g'),
                      Text(currencyFormatter(tx.totalAmount)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            FancyWideButton('Print', () async {
              // await _requestStoragePermission(context);
              if (context.mounted) {
                await _saveAsPdf(context, title, transactions);
              }
            })
          ],
        ),
      ),
    );
  }
}
