import 'package:flutter/material.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletProvider with ChangeNotifier {
  final WalletRepository repository;

  List<WalletEntity> _wallets = [];
  bool _isLoading = false;
  int? _selectedWalletId;

  WalletProvider(this.repository);

  List<WalletEntity> get wallets => _wallets;
  bool get isLoading => _isLoading;
  int? get selectedWalletId => _selectedWalletId;

  WalletEntity? get selectedWallet {
    if (_selectedWalletId == null || _wallets.isEmpty) return null;
    try {
      return _wallets.firstWhere((w) => w.id == _selectedWalletId);
    } catch (_) {
      return _wallets.first;
    }
  }

  void selectWallet(int walletId) {
    _selectedWalletId = walletId;
    notifyListeners();
  }

  Future<void> loadWallets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wallets = await repository.getAllWallets();
      if (_wallets.isNotEmpty &&
          (_selectedWalletId == null ||
              !_wallets.any((w) => w.id == _selectedWalletId))) {
        _selectedWalletId = _wallets.first.id;
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWallet(WalletEntity wallet) async {
    await repository.insertWallet(wallet);
    await loadWallets();
  }

  Future<void> updateWallet(WalletEntity wallet) async {
    await repository.updateWallet(wallet);
    await loadWallets();
  }

  Future<void> deleteWallet(int id) async {
    await repository.deleteWallet(id);
    if (_selectedWalletId == id) {
      _selectedWalletId = null;
    }
    await loadWallets();
  }
}
