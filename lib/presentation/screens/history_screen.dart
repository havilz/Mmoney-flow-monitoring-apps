import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/transaction_list_tile.dart';
import 'add_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterSheet(context, categoryProvider, transactionProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategoryId = null);
                    transactionProvider.setFilters(categoryId: null);
                  },
                ),
                const SizedBox(width: 8),
                ...categoryProvider.categories.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c.name),
                      selected: _selectedCategoryId == c.id,
                      onSelected: (selected) {
                        setState(() => _selectedCategoryId = selected ? c.id : null);
                        transactionProvider.setFilters(categoryId: _selectedCategoryId);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          
          Expanded(
            child: transactionProvider.filteredTransactions.isEmpty
                ? const Center(child: Text('No transactions match your filters'))
                : ListView.builder(
                    itemCount: transactionProvider.filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final t = transactionProvider.filteredTransactions[index];
                      return TransactionListTile(
                        transaction: t,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTransactionScreen(transaction: t),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, CategoryProvider cp, TransactionProvider tp) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.today),
                title: const Text('All Time'),
                onTap: () {
                  tp.setFilters(start: null, end: null);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_day),
                title: const Text('This Month'),
                onTap: () {
                  final now = DateTime.now();
                  tp.setFilters(
                    start: DateTime(now.year, now.month, 1),
                    end: DateTime(now.year, now.month + 1, 0),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
