import 'package:flutter_test/flutter_test.dart';
import 'package:money_monitoring_app/domain/entities/transaction_entity.dart';
import 'package:money_monitoring_app/domain/entities/wallet_entity.dart';
import 'package:money_monitoring_app/domain/entities/category_entity.dart';
import 'package:money_monitoring_app/domain/repositories/transaction_repository.dart';
import 'package:money_monitoring_app/domain/repositories/wallet_repository.dart';
import 'package:money_monitoring_app/domain/repositories/category_repository.dart';
import 'package:money_monitoring_app/presentation/providers/transaction_provider.dart';
import 'package:money_monitoring_app/presentation/providers/wallet_provider.dart';

// Mock Category Repository
class MockCategoryRepository implements CategoryRepository {
  final List<CategoryEntity> categories = [];

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    return List.from(categories);
  }

  @override
  Future<int> insertCategory(CategoryEntity category) async {
    final newCategory = CategoryEntity(
      id: categories.length + 1,
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
    );
    categories.add(newCategory);
    return newCategory.id!;
  }

  @override
  Future<int> updateCategory(CategoryEntity category) async {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteCategory(int id) async {
    final countBefore = categories.length;
    categories.removeWhere((c) => c.id == id);
    return countBefore - categories.length;
  }
}

// Mock Transaction Repository
class MockTransactionRepository implements TransactionRepository {
  final List<TransactionEntity> transactions = [];

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    return List.from(transactions);
  }

  @override
  Future<int> insertTransaction(TransactionEntity transaction) async {
    final newTx = TransactionEntity(
      id: transactions.length + 1,
      amount: transaction.amount,
      type: transaction.type,
      categoryId: transaction.categoryId,
      date: transaction.date,
      note: transaction.note,
      walletId: transaction.walletId,
    );
    transactions.add(newTx);
    return newTx.id!;
  }

  @override
  Future<int> updateTransaction(TransactionEntity transaction) async {
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteTransaction(int id) async {
    final countBefore = transactions.length;
    transactions.removeWhere((t) => t.id == id);
    return countBefore - transactions.length;
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCategory(
    int categoryId,
  ) async {
    return transactions.where((t) => t.categoryId == categoryId).toList();
  }
}

// Mock Wallet Repository
class MockWalletRepository implements WalletRepository {
  final List<WalletEntity> wallets = [
    WalletEntity(id: 1, name: 'Cash', balance: 0.0),
  ];

  @override
  Future<List<WalletEntity>> getAllWallets() async {
    return List.from(wallets);
  }

  @override
  Future<int> insertWallet(WalletEntity wallet) async {
    final newWallet = WalletEntity(
      id: wallets.length + 1,
      name: wallet.name,
      balance: wallet.balance,
    );
    wallets.add(newWallet);
    return newWallet.id!;
  }

  @override
  Future<int> updateWallet(WalletEntity wallet) async {
    final index = wallets.indexWhere((w) => w.id == wallet.id);
    if (index != -1) {
      wallets[index] = wallet;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteWallet(int id) async {
    final countBefore = wallets.length;
    wallets.removeWhere((w) => w.id == id);
    return countBefore - wallets.length;
  }
}

void main() {
  group('TransactionProvider Tests', () {
    late MockTransactionRepository mockTxRepo;
    late TransactionProvider txProvider;

    setUp(() {
      mockTxRepo = MockTransactionRepository();
      txProvider = TransactionProvider(mockTxRepo);
    });

    test('Initial loading state and empty transactions', () async {
      expect(txProvider.transactions, isEmpty);
      expect(txProvider.isLoading, isFalse);

      await txProvider.loadTransactions();
      expect(txProvider.transactions, isEmpty);
      expect(txProvider.isLoading, isFalse);
    });

    test('Add and retrieve transactions', () async {
      final tx = TransactionEntity(
        amount: 50000,
        type: 'INCOME',
        categoryId: 1,
        date: DateTime.now(),
        note: 'Salary bonus',
        walletId: 1,
      );

      await txProvider.addTransaction(tx);
      expect(txProvider.transactions.length, 1);
      expect(txProvider.transactions.first.note, 'Salary bonus');
      expect(txProvider.transactions.first.amount, 50000);
      expect(txProvider.transactions.first.id, 1);
    });

    test('Delete transaction', () async {
      final tx = TransactionEntity(
        amount: 20000,
        type: 'EXPENSE',
        categoryId: 2,
        date: DateTime.now(),
        note: 'Lunch',
        walletId: 1,
      );

      await txProvider.addTransaction(tx);
      expect(txProvider.transactions.length, 1);

      await txProvider.deleteTransaction(1);
      expect(txProvider.transactions, isEmpty);
    });
  });

  group('WalletProvider Tests', () {
    late MockWalletRepository mockWalletRepo;
    late WalletProvider walletProvider;

    setUp(() {
      mockWalletRepo = MockWalletRepository();
      walletProvider = WalletProvider(mockWalletRepo);
    });

    test('Load wallets and active wallet selection state', () async {
      await walletProvider.loadWallets();
      expect(walletProvider.wallets.length, 1);
      expect(walletProvider.selectedWalletId, 1);
      expect(walletProvider.selectedWallet?.name, 'Cash');
    });

    test('Add new wallet and select it', () async {
      await walletProvider.loadWallets();

      final wallet = WalletEntity(name: 'Savings', balance: 1000000.0);
      await walletProvider.addWallet(wallet);

      expect(walletProvider.wallets.length, 2);
      expect(walletProvider.wallets[1].name, 'Savings');

      // Select new wallet
      walletProvider.selectWallet(2);
      expect(walletProvider.selectedWalletId, 2);
      expect(walletProvider.selectedWallet?.name, 'Savings');
    });
  });
}
