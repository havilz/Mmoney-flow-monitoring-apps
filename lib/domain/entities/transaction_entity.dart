class TransactionEntity {
  final int? id;
  final double amount;
  final String type; // INCOME or EXPENSE
  final int categoryId;
  final DateTime date;
  final String note;
  final int walletId;

  TransactionEntity({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.note,
    required this.walletId,
  });
}
