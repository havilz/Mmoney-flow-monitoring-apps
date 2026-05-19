import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('money_monitoring.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Wallets Table
    await db.execute('''
      CREATE TABLE wallets (
        id $idType,
        name $textType,
        balance $realType
      )
    ''');

    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        icon $textType,
        color $textType,
        type $textType
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        amount $realType,
        type $textType,
        category_id $integerType,
        date $textType,
        note $textType,
        wallet_id $integerType,
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (wallet_id) REFERENCES wallets (id)
      )
    ''');

    // Initial Data: Default Categories
    await _insertDefaultCategories(db);
  }

  Future _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'name': 'Food',
        'icon': 'fastfood',
        'color': '0xFFFF5722',
        'type': 'EXPENSE',
      },
      {
        'name': 'Transport',
        'icon': 'directions_car',
        'color': '0xFF2196F3',
        'type': 'EXPENSE',
      },
      {
        'name': 'Salary',
        'icon': 'attach_money',
        'color': '0xFF4CAF50',
        'type': 'INCOME',
      },
      {
        'name': 'Shopping',
        'icon': 'shopping_bag',
        'color': '0xFF9C27B0',
        'type': 'EXPENSE',
      },
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
