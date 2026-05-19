import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({super.id, required super.name, required super.balance});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'balance': balance};
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
    );
  }
}
