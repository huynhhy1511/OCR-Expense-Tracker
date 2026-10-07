class Expense {
  final int? id;
  final String merchant;
  final int amount; // in VND
  final DateTime transactionDate;
  final String category;
  final String? receiptImagePath;
  final String? ocrText;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.merchant,
    required this.amount,
    required this.transactionDate,
    required this.category,
    this.receiptImagePath,
    this.ocrText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'transaction_date': transactionDate.toIso8601String(),
      'category': category,
      'receipt_image_path': receiptImagePath,
      'ocr_text': ocrText,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      merchant: map['merchant'] as String,
      amount: map['amount'] as int,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      category: map['category'] as String,
      receiptImagePath: map['receipt_image_path'] as String?,
      ocrText: map['ocr_text'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Expense copyWith({
    int? id,
    String? merchant,
    int? amount,
    DateTime? transactionDate,
    String? category,
    String? receiptImagePath,
    String? ocrText,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      category: category ?? this.category,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      ocrText: ocrText ?? this.ocrText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
