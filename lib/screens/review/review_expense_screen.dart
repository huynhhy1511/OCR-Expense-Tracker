import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/date_utils.dart';

class ReviewExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final String? imagePath;
  final String? parsedMerchant;
  final int? parsedAmount;
  final DateTime? parsedDate;
  final String? ocrText;

  const ReviewExpenseScreen({
    super.key,
    this.expense,
    this.imagePath,
    this.parsedMerchant,
    this.parsedAmount,
    this.parsedDate,
    this.ocrText,
  });

  @override
  State<ReviewExpenseScreen> createState() => _ReviewExpenseScreenState();
}

class _ReviewExpenseScreenState extends State<ReviewExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController(
      text: widget.expense?.merchant ?? widget.parsedMerchant ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? widget.parsedAmount?.toString() ?? '',
    );
    _selectedDate = widget.expense?.transactionDate ?? widget.parsedDate ?? DateTime.now();
    _selectedCategory = widget.expense?.category ?? Constants.categories.first;
  }
  
  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      
      final expense = Expense(
        id: widget.expense?.id,
        merchant: _merchantController.text.trim(),
        amount: amount,
        transactionDate: _selectedDate,
        category: _selectedCategory,
        receiptImagePath: widget.expense?.receiptImagePath ?? widget.imagePath,
        ocrText: widget.expense?.ocrText ?? widget.ocrText,
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
      );

      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      if (widget.expense == null) {
        provider.addExpense(expense);
      } else {
        provider.updateExpense(expense);
      }
      
      // Go back to Dashboard (pop until first route)
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    final imagePath = widget.expense?.receiptImagePath ?? widget.imagePath;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Review Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imagePath != null) ...[
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(
                    File(imagePath),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Merchant',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: Validators.requiredString,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (VND)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.requiredAmount,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(AppDateUtils.formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: Constants.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _saveExpense,
                icon: const Icon(Icons.save),
                label: const Text('Save Expense'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
