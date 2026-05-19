import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../screens/history_screen.dart';
import '../screens/category_management_screen.dart';
import '../screens/wallet_management_screen.dart';

class MainDrawer extends StatelessWidget {
  final TransactionProvider transactionProvider;

  const MainDrawer({super.key, required this.transactionProvider});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF6366F1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Money Flow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Personal Finance Monitor',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Transaction History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Manage Categories'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Manage Wallets'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WalletManagementScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export CSV'),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              try {
                final path = await transactionProvider.exportToCsv();
                if (!context.mounted) return;

                if (Platform.isWindows ||
                    Platform.isMacOS ||
                    Platform.isLinux) {
                  final String? outputFile = await FilePicker.saveFile(
                    dialogTitle: 'Save Backup CSV',
                    fileName: 'money_flow_backup.csv',
                    type: FileType.custom,
                    allowedExtensions: ['csv'],
                  );
                  if (outputFile != null) {
                    final file = File(path);
                    await file.copy(outputFile);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Backup saved successfully!'),
                        ),
                      );
                    }
                  }
                } else {
                  // Mobile
                  final box = context.findRenderObject() as RenderBox?;
                  final sharePositionOrigin = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : null;
                  await SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(path)],
                      subject: 'Money Flow Backup',
                      sharePositionOrigin: sharePositionOrigin,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Import CSV'),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              try {
                final result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['csv'],
                );

                if (result != null && result.files.single.path != null) {
                  final path = result.files.single.path!;
                  final file = File(path);
                  final csvString = await file.readAsString();
                  final fields = const CsvToListConverter().convert(csvString);

                  if (fields.isEmpty || fields[0].length < 10) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid backup CSV format!'),
                        ),
                      );
                    }
                    return;
                  }

                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    await transactionProvider.importCsvData(fields);

                    if (context.mounted) {
                      await context.read<WalletProvider>().loadWallets();
                    }

                    if (context.mounted) {
                      Navigator.pop(context); // Pop progress dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Successfully imported ${fields.length - 1} transactions!',
                          ),
                        ),
                      );
                    }
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
