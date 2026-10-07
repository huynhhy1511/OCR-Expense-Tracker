import 'package:flutter/material.dart';
import '../../services/ocr_service.dart';
import '../../services/receipt_parser.dart';
import '../../services/storage_service.dart';
import '../review/review_expense_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final _ocrService = OcrService();
  final _parser = ReceiptParser();
  final _storageService = StorageService();

  String _status = 'Processing receipt...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _processReceipt();
  }

  Future<void> _processReceipt() async {
    try {
      setState(() => _status = 'Extracting text...');
      final rawText = await _ocrService.processImage(widget.imagePath);

      if (rawText.isEmpty) {
        throw Exception('No text found');
      }

      setState(() => _status = 'Parsing data...');
      final parsedReceipt = _parser.parse(rawText);

      setState(() => _status = 'Saving image...');
      final savedImagePath = await _storageService.saveReceiptImage(widget.imagePath);

      if (!mounted) return;

      // Navigate to Review Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewExpenseScreen(
            imagePath: savedImagePath,
            parsedMerchant: parsedReceipt.merchant,
            parsedAmount: parsedReceipt.amount,
            parsedDate: parsedReceipt.date,
            ocrText: rawText,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Processing error: $e');
      if (!mounted) return;
      setState(() {
        _status = 'Unable to read receipt\nError: $e\nPlease try another photo';
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_hasError) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
            ] else ...[
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 24),
            ],
            Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_hasError) ...[
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
              TextButton(
                onPressed: () {
                  // Fallback to manual entry
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewExpenseScreen(
                        imagePath: widget.imagePath,
                      ),
                    ),
                  );
                },
                child: const Text('Enter Manually'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
