import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/wallet_entity.dart';
import '../providers/wallet_provider.dart';

class WalletManagementScreen extends StatelessWidget {
  const WalletManagementScreen({super.key});

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Wallet Name',
                  hintText: 'e.g. Bank Account, Cash, Savings',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Initial Balance',
                  prefixText: 'Rp ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final balanceText = balanceController.text.trim();
                final balance = double.tryParse(balanceText) ?? 0.0;

                if (name.isNotEmpty) {
                  final wallet = WalletEntity(name: name, balance: balance);
                  context.read<WalletProvider>().addWallet(wallet);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Wallets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: walletProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : walletProvider.wallets.isEmpty
          ? const Center(child: Text('No wallets found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: walletProvider.wallets.length,
              itemBuilder: (context, index) {
                final wallet = walletProvider.wallets[index];
                final isSelected = walletProvider.selectedWalletId == wallet.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? const Color(0xFF6366F1)
                          : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                    title: Text(
                      wallet.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Rp ${wallet.balance.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isSelected)
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle_outline_rounded,
                            ),
                            onPressed: () {
                              if (wallet.id != null) {
                                walletProvider.selectWallet(wallet.id!);
                              }
                            },
                          ),
                        if (wallet.id !=
                            1) // Prevent deleting the default wallet
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Wallet'),
                                  content: const Text(
                                    'Are you sure you want to delete this wallet? This will fail if there are transactions associated with it.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (wallet.id != null) {
                                          walletProvider.deleteWallet(
                                            wallet.id!,
                                          );
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWalletDialog(context),
        label: const Text('Add Wallet'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
    );
  }
}
