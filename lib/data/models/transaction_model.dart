import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    super.id,
    required super.amount,
    required super.type,
    required super.categoryId,
    required super.date,
    required super.note,
    required super.walletId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'wallet_id': walletId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['category_id'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      walletId: map['wallet_id'],
    );
  }
}
