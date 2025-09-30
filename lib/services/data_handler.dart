import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataHandler {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nbe.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            todays_rate REAL,
            weight REAL,
            specific_gravity REAL,
            total_amount REAL,
            is_completed INTEGER)''');
      },
    );
  }

  Future<void> addTransactionToDb(Transaction transaction) async {
    final db = await database;
    db.insert('Transactions', {
      'date': transaction.date.toIso8601String(),
      'todays_rate': transaction.todayRate,
      'weight': transaction.weight,
      'specific_gravity': transaction.specificGravity,
      'total_amount': transaction.totalAmount,
      'is_completed': transaction.isCompleted ? 1 : 0,
    });
  }

  Future<List<Transaction>> loadAllTransactions() async {
    final db = await database;
    final transactionData = await db.query('Transactions');
    final List<Transaction> transactions = [];

    for (var tran in transactionData) {
      final transaction = Transaction(
        date: DateTime.parse(tran['date'] as String),
        specificGravity: tran['specific_gravity'] as double,
        todayRate: tran['todays_rate'] as double,
        totalAmount: tran['total_amount'] as double,
        weight: tran['weight'] as double,
        isCompleted: tran['is_completed'] as int == 1,
      );
      transactions.add(transaction);
    }
    return transactions;
  }
}

class Transaction {
  final DateTime date;
  final double todayRate;
  final double weight;
  final double specificGravity;
  final double totalAmount;
  final bool isCompleted;

  const Transaction({
    required this.date,
    required this.specificGravity,
    required this.todayRate,
    required this.totalAmount,
    required this.weight,
    required this.isCompleted,
  });
}
