import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../data/datasources/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository repository;

  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;

  // Filtering state
  DateTime? _startDate;
  DateTime? _endDate;
  int? _filterCategoryId;
  int? _selectedWalletId;

  TransactionProvider(this.repository);

  int? get selectedWalletId => _selectedWalletId;

  void setSelectedWalletId(int? walletId) {
    if (_selectedWalletId != walletId) {
      _selectedWalletId = walletId;
      notifyListeners();
    }
  }

  List<TransactionEntity> get transactions {
    if (_selectedWalletId == null) return _transactions;
    return _transactions.where((t) => t.walletId == _selectedWalletId).toList();
  }

  bool get isLoading => _isLoading;

  void setFilters({DateTime? start, DateTime? end, int? categoryId}) {
    _startDate = start;
    _endDate = end;
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  List<TransactionEntity> get filteredTransactions {
    return transactions.where((t) {
      bool matchDate = true;
      if (_startDate != null && t.date.isBefore(_startDate!)) matchDate = false;
      if (_endDate != null && t.date.isAfter(_endDate!)) matchDate = false;

      bool matchCategory = true;
      if (_filterCategoryId != null && t.categoryId != _filterCategoryId) {
        matchCategory = false;
      }

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
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.date, 
        t.amount, 
        t.type, 
        t.note, 
        c.name AS category_name, 
        c.icon AS category_icon, 
        c.color AS category_color, 
        c.type AS category_type,
        w.name AS wallet_name,
        w.balance AS wallet_initial_balance
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      JOIN wallets w ON t.wallet_id = w.id
      ORDER BY t.date DESC
    ''');

    List<List<dynamic>> rows = [];
    rows.add([
      "Date",
      "Amount",
      "Type",
      "Note",
      "Category Name",
      "Category Icon",
      "Category Color",
      "Category Type",
      "Wallet Name",
      "Wallet Initial Balance",
    ]);

    for (var map in maps) {
      rows.add([
        map['date'],
        map['amount'],
        map['type'],
        map['note'],
        map['category_name'],
        map['category_icon'],
        map['category_color'],
        map['category_type'],
        map['wallet_name'],
        map['wallet_initial_balance'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/money_flow_backup.csv');
    await file.writeAsString(csvData);

    return file.path;
  }

  Future<void> importCsvData(List<List<dynamic>> fields) async {
    final db = await DatabaseHelper.instance.database;

    await db.transaction((txn) async {
      final Map<String, int> walletIds = {};
      final Map<String, int> categoryIds = {};

      final List<Map<String, dynamic>> existingWallets = await txn.query(
        'wallets',
      );
      for (var w in existingWallets) {
        walletIds[w['name'].toString().toLowerCase()] = w['id'] as int;
      }

      final List<Map<String, dynamic>> existingCategories = await txn.query(
        'categories',
      );
      for (var c in existingCategories) {
        categoryIds[c['name'].toString().toLowerCase()] = c['id'] as int;
      }

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 10) continue;

        final dateStr = row[0].toString();
        final amount = double.tryParse(row[1].toString()) ?? 0.0;
        final type = row[2].toString();
        final note = row[3].toString();
        final categoryName = row[4].toString();
        final categoryIcon = row[5].toString();
        final categoryColor = row[6].toString();
        final categoryType = row[7].toString();
        final walletName = row[8].toString();
        final walletInitialBalance = double.tryParse(row[9].toString()) ?? 0.0;

        final walletKey = walletName.toLowerCase();
        int walletId;
        if (walletIds.containsKey(walletKey)) {
          walletId = walletIds[walletKey]!;
        } else {
          walletId = await txn.insert('wallets', {
            'name': walletName,
            'balance': walletInitialBalance,
          });
          walletIds[walletKey] = walletId;
        }

        final categoryKey = categoryName.toLowerCase();
        int categoryId;
        if (categoryIds.containsKey(categoryKey)) {
          categoryId = categoryIds[categoryKey]!;
        } else {
          categoryId = await txn.insert('categories', {
            'name': categoryName,
            'icon': categoryIcon,
            'color': categoryColor,
            'type': categoryType,
          });
          categoryIds[categoryKey] = categoryId;
        }

        await txn.insert('transactions', {
          'amount': amount,
          'type': type,
          'category_id': categoryId,
          'date': dateStr,
          'note': note,
          'wallet_id': walletId,
        });
      }
    });

    await loadTransactions();
  }
}
