import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository repository;

  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;

  // Filtering state
  DateTime? _startDate;
  DateTime? _endDate;
  int? _filterCategoryId;

  TransactionProvider(this.repository);

  List<TransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;

  void setFilters({DateTime? start, DateTime? end, int? categoryId}) {
    _startDate = start;
    _endDate = end;
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  List<TransactionEntity> get filteredTransactions {
    return _transactions.where((t) {
      bool matchDate = true;
      if (_startDate != null && t.date.isBefore(_startDate!)) matchDate = false;
      if (_endDate != null && t.date.isAfter(_endDate!)) matchDate = false;
      
      bool matchCategory = true;
      if (_filterCategoryId != null && t.categoryId != _filterCategoryId) matchCategory = false;
      
      return matchDate && matchCategory;
    }).toList();
  }

  double get totalIncome => filteredTransactions
      .where((t) => t.type == 'INCOME')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => filteredTransactions
      .where((t) => t.type == 'EXPENSE')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await repository.getAllTransactions();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    await repository.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionEntity transaction) async {
    await repository.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await repository.deleteTransaction(id);
    await loadTransactions();
  }

  Future<String> exportToCsv() async {
    List<List<dynamic>> rows = [];
    rows.add(["ID", "Date", "Amount", "Type", "Note", "Category ID"]);

    for (var t in _transactions) {
      rows.add([
        t.id,
        t.date.toIso8601String(),
        t.amount,
        t.type,
        t.note,
        t.categoryId,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);
    
    return file.path;
  }
}
