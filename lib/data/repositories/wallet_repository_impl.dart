import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/database_helper.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final DatabaseHelper dbHelper;

  WalletRepositoryImpl(this.dbHelper);

  @override
  Future<List<WalletEntity>> getAllWallets() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        w.id, 
        w.name, 
        (w.balance + 
         COALESCE((SELECT SUM(amount) FROM transactions WHERE wallet_id = w.id AND type = 'INCOME'), 0) - 
         COALESCE((SELECT SUM(amount) FROM transactions WHERE wallet_id = w.id AND type = 'EXPENSE'), 0)
        ) AS balance
      FROM wallets w
    ''');
    return List.generate(maps.length, (i) => WalletModel.fromMap(maps[i]));
  }

  @override
  Future<int> insertWallet(WalletEntity wallet) async {
    final db = await dbHelper.database;
    final model = WalletModel(name: wallet.name, balance: wallet.balance);
    return await db.insert('wallets', model.toMap());
  }

  @override
  Future<int> updateWallet(WalletEntity wallet) async {
    final db = await dbHelper.database;
    final model = WalletModel(
      id: wallet.id,
      name: wallet.name,
      balance: wallet.balance,
    );
    return await db.update(
      'wallets',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  @override
  Future<int> deleteWallet(int id) async {
    final db = await dbHelper.database;
    return await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }
}
