import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final isIncome = transaction.type == 'INCOME';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isIncome 
              ? Colors.green.withValues(alpha: 0.1) 
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isIncome ? Icons.add_rounded : Icons.remove_rounded,
          color: isIncome ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        transaction.note,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        DateFormat('dd MMM yyyy').format(transaction.date),
        style: TextStyle(
          color: isDarkMode ? Colors.white60 : Colors.black54,
          fontSize: 13,
        ),
      ),
      trailing: Text(
        (isIncome ? '+ ' : '- ') + currencyFormat.format(transaction.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
