import 'package:flutter_test/flutter_test.dart';
import 'package:miniproject3/services/receipt_parser.dart';

void main() {
  group('ReceiptParser Tests', () {
    final parser = ReceiptParser();

    test('Parses amount correctly with VND', () {
      const text = '''
VINMART
123 NGUYEN VAN LINH
05/10/2026
Milk 30.000
Bread 20.000
TONG CONG 150.000 đ
      ''';
      
      final result = parser.parse(text);
      expect(result.amount, 150000);
      expect(result.merchant, 'VINMART');
      expect(result.date, DateTime(2026, 10, 5));
    });

    test('Parses amount correctly with English keywords', () {
      const text = '''
CIRCLE K
DATE 05-10-2026
TOTAL 45,000 VND
      ''';
      
      final result = parser.parse(text);
      expect(result.amount, 45000);
      expect(result.merchant, 'CIRCLE K');
      expect(result.date, DateTime(2026, 10, 5));
    });
  });
}
