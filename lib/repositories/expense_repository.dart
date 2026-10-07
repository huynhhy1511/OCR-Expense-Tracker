import '../models/expense.dart';
import '../database/expense_dao.dart';

class ExpenseRepository {
  final ExpenseDao _expenseDao = ExpenseDao();

  Future<int> insertExpense(Expense expense) => _expenseDao.insertExpense(expense);
  
  Future<List<Expense>> getAllExpenses() => _expenseDao.getAllExpenses();
  
  Future<int> updateExpense(Expense expense) => _expenseDao.updateExpense(expense);
  
  Future<int> deleteExpense(int id) => _expenseDao.deleteExpense(id);
  
  Future<Expense?> getExpenseById(int id) => _expenseDao.getExpenseById(id);

  Future<Map<String, int>> getCategoryTotals() async {
    final expenses = await getAllExpenses();
    final Map<String, int> totals = {};
    for (var expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Future<Map<int, int>> getWeeklyTotals() async {
    final expenses = await getAllExpenses();
    final Map<int, int> weeklyTotals = {
      1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0
    };
    
    // Calculate total for the last 7 days including today
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    
    for (var expense in expenses) {
      final date = expense.transactionDate;
      final startOfDate = DateTime(date.year, date.month, date.day);
      final difference = startOfToday.difference(startOfDate).inDays;
      
      if (difference >= 0 && difference < 7) {
        // Monday = 1, Sunday = 7
        int weekday = date.weekday;
        weeklyTotals[weekday] = (weeklyTotals[weekday] ?? 0) + expense.amount;
      }
    }
    return weeklyTotals;
  }
}
