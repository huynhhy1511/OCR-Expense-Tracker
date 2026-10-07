import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  
  List<Expense> _expenses = [];
  Map<String, int> _categoryTotals = {};
  Map<int, int> _weeklyTotals = {};
  
  List<Expense> get expenses => _expenses;
  Map<String, int> get categoryTotals => _categoryTotals;
  Map<int, int> get weeklyTotals => _weeklyTotals;

  ExpenseProvider() {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    _expenses = await _repository.getAllExpenses();
    _categoryTotals = await _repository.getCategoryTotals();
    _weeklyTotals = await _repository.getWeeklyTotals();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.insertExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await _repository.deleteExpense(id);
    await loadExpenses();
  }
  
  int get totalSpending {
    return _expenses.fold(0, (sum, item) => sum + item.amount);
  }
  
  List<Expense> get recentExpenses {
    return _expenses.take(5).toList();
  }
}
