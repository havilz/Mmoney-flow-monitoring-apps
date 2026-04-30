import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAllTransactions();
  Future<int> insertTransaction(TransactionEntity transaction);
  Future<int> updateTransaction(TransactionEntity transaction);
  Future<int> deleteTransaction(int id);
  Future<List<TransactionEntity>> getTransactionsByCategory(int categoryId);
}
