class ParsedReceipt {
  final String? merchant;
  final int? amount;
  final DateTime? date;

  ParsedReceipt({this.merchant, this.amount, this.date});
}

class ReceiptParser {
  ParsedReceipt parse(String text) {
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    String? merchant = _parseMerchant(lines);
    int? amount = _parseAmount(lines);
    DateTime? date = _parseDate(lines);

    return ParsedReceipt(
      merchant: merchant,
      amount: amount,
      date: date,
    );
  }

  String? _parseMerchant(List<String> lines) {
    if (lines.isEmpty) return null;
    
    // Heuristic: First line that is not a number, date, or common metadata
    for (var line in lines) {
      if (line.contains(RegExp(r'\d{3,}'))) continue; // phone or ID
      if (line.toLowerCase().contains(RegExp(r'ngày|date|time|giờ'))) continue;
      if (line.toLowerCase().contains(RegExp(r'tax|mst|hotline|tel|đc|add'))) continue;
      if (line.length > 3 && line.length < 30) {
        return line;
      }
    }
    return lines.first; // Fallback
  }

  int? _parseAmount(List<String> lines) {
    final keywords = ['total', 'tổng', 'thành tiền', 'grand total', 'payment', 'amount'];
    
    for (var i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();
      if (keywords.any((kw) => lineLower.contains(kw))) {
        // Look in this line
        int? amount = _extractMoney(lines[i]);
        if (amount != null && amount > 1000) return amount; // Reasonable amount
        
        // Look in next line
        if (i + 1 < lines.length) {
          amount = _extractMoney(lines[i + 1]);
          if (amount != null && amount > 1000) return amount;
        }
      }
    }
    
    // Fallback: largest number that is not likely a date or phone
    int maxAmount = 0;
    final dateRegex = RegExp(r'\d{1,2}[-/.]\d{1,2}[-/.]\d{4}');
    for (var line in lines) {
      if (dateRegex.hasMatch(line)) continue; // skip date lines
      if (line.replaceAll(RegExp(r'\D'), '').length >= 10) continue; // skip phone
      
      final amount = _extractMoney(line);
      if (amount != null && amount > maxAmount && amount < 100000000) {
        maxAmount = amount;
      }
    }
    return maxAmount > 0 ? maxAmount : null;
  }
  
  int? _extractMoney(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^\d.,]'), '');
    if (cleaned.isEmpty) return null;
    
    // Normalize format like 150.000 or 150,000 -> 150000
    // If it has multiple separators, take all numbers
    final numbersOnly = cleaned.replaceAll(RegExp(r'[,.]'), '');
    return int.tryParse(numbersOnly);
  }

  DateTime? _parseDate(List<String> lines) {
    final dateRegex = RegExp(r'(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})');
    
    for (var line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        try {
          int day = int.parse(match.group(1)!);
          int month = int.parse(match.group(2)!);
          int year = int.parse(match.group(3)!);
          
          if (day > 31 || month > 12 || year > 2100 || year < 2000) continue;
          
          return DateTime(year, month, day);
        } catch (e) {
          continue;
        }
      }
    }
    return null;
  }
}
