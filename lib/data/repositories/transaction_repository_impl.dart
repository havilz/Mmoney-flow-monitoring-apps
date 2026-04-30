import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper dbHelper;

  TransactionRepositoryImpl(this.dbHelper);

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  @override
  Future<int> insertTransaction(TransactionEntity transaction) async {
    final db = await dbHelper.database;
    final model = TransactionModel(
      amount: transaction.amount,
      type: transaction.type,
      categoryId: transaction.categoryId,
      date: transaction.date,
      note: transaction.note,
      walletId: transaction.walletId, // Fix model field name if necessary
    );
    // Actually the model I created has walletId, but database has wallet_id.
    // Wait, let me check transaction_model.dart
    return await db.insert('transactions', model.toMap());
  }

  @override
  Future<int> updateTransaction(TransactionEntity transaction) async {
    final db = await dbHelper.database;
    final model = TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      type: transaction.type,
      categoryId: transaction.categoryId,
      date: transaction.date,
      note: transaction.note,
      walletId: transaction.walletId,
    );
    return await db.update(
      'transactions',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCategory(
    int categoryId,
  ) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }
}
