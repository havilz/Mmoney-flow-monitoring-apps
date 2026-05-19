import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptData {
  final double amount;
  final String type;

  ReceiptData({required this.amount, required this.type});
}

class ReceiptScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ReceiptData?> scanReceipt(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      double extractedAmount = _extractAmount(recognizedText.text);
      String guessedType = _guessType(recognizedText.text);

      return ReceiptData(amount: extractedAmount, type: guessedType);
    } catch (e) {
      print('Error scanning receipt: $e');
      return null;
    } finally {
      // It's good practice to close the recognizer if not used, but here we might reuse it.
      // We'll leave it open, or we can close it if this is a singleton.
      // Let's create a new one each time or keep it. I'll keep it simple.
    }
  }

  void dispose() {
    _textRecognizer.close();
  }

  double _extractAmount(String text) {
    // Look for lines containing "Total" and a number, or just find the largest number on the receipt.
    // Receipts in Indonesia often use formats like: 15.000, 15,000, 15.000,00

    // First, let's collect all numbers that look like currency amounts.
    final RegExp amountRegex = RegExp(
      r'\b\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{1,2})?\b',
    );

    List<double> foundAmounts = [];

    for (String line in text.split('\n')) {
      final matches = amountRegex.allMatches(line);
      for (final match in matches) {
        String numStr = match.group(0)!;
        // Clean up string for parsing:
        // If it contains both . and , usually the last one is decimal separator.
        // In Indonesian, . is thousands, , is decimal.
        // Let's remove all . and replace , with .
        if (numStr.contains('.') && numStr.contains(',')) {
          numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
        } else if (numStr.contains(',')) {
          // Could be 15,000 (US format) or 15,00 (ID format).
          // If followed by 3 digits, probably thousands separator.
          // Let's just remove all non-digits except the last separator if it's a decimal.
          // To be safe and simple for IDR: usually just remove all dots and commas.
          numStr = numStr.replaceAll(RegExp(r'[.,]'), '');
        } else {
          numStr = numStr.replaceAll('.', '');
        }

        double? val = double.tryParse(numStr);
        if (val != null) {
          // If we see 'Total' in the same line, this might be a strong candidate.
          if (line.toLowerCase().contains('total')) {
            // We give preference to totals, maybe just return it immediately if it's reasonable
            // But sometimes subtotal is there.
          }
          foundAmounts.add(val);
        }
      }
    }

    if (foundAmounts.isEmpty) return 0.0;

    // Usually the largest amount on a receipt is the Total.
    // But we should filter out huge numbers that might be phone numbers or dates.
    // Assuming max realistic receipt is less than 1 billion.
    foundAmounts.removeWhere((amount) => amount > 1000000000);

    if (foundAmounts.isEmpty) return 0.0;

    double maxAmount = foundAmounts.reduce(
      (curr, next) => curr > next ? curr : next,
    );
    return maxAmount;
  }

  String _guessType(String text) {
    String lowerText = text.toLowerCase();

    // Check for common income keywords
    if (lowerText.contains('refund') ||
        lowerText.contains('deposit') ||
        lowerText.contains('income') ||
        lowerText.contains('topup') ||
        lowerText.contains('top up') ||
        lowerText.contains('kembali')) {
      // Note: "Kembali" usually means change from a cash transaction (expense),
      // but refund/deposit implies income. Let's stick to mostly expense for receipts.
      // If it says refund, it's income.
      if (lowerText.contains('refund') || lowerText.contains('deposit')) {
        return 'INCOME';
      }
    }

    // Default to EXPENSE as 99% of scanned receipts are expenses
    return 'EXPENSE';
  }
}
