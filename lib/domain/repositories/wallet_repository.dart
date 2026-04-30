import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletEntity>> getAllWallets();
  Future<int> insertWallet(WalletEntity wallet);
  Future<int> updateWallet(WalletEntity wallet);
  Future<int> deleteWallet(int id);
}
