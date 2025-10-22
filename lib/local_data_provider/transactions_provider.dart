import 'package:nbe/libs.dart' show NBEDatabase, SQLLiteTypes, Transaction;
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

class TransactionsLocalProvider {
  static const String tableName = "sell_record";

  static const String _idCol = "id";
  static const String _netCol = "net";
  static const String _gramCol = "gram";
  static const String _dateCol = "date";
  static const String _karatCol = "karat";
  static const String _extraDays = "extraDays";
  static const String _athPrice = "athPrice";
  static const String _initialPrice = "initialPrice";
  static const String _taxValue = "taxValue";
  static const String _bankFeeValue = "bankFeeValue";
  static const String _createdAtCol = "createdAt";
  static const String _settingIDCol = "settingID";
  static const String _specificGravityCol = "specificGravity";
  static const String _isCompleted = "isCompleted";

  final NBEDatabase wrapper;
  TransactionsLocalProvider(this.wrapper) : super();

  static String createOrReplaceTableString() {
    return """CREATE TABLE IF NOT EXISTS $tableName(
        $_idCol ${SQLLiteTypes.stringType} PRIMARY KEY,
        $_gramCol ${SQLLiteTypes.doubleType} NOT NULL,
        $_karatCol  ${SQLLiteTypes.doubleType} NOT NULL,
        $_specificGravityCol ${SQLLiteTypes.doubleType} NOT NULL,
        $_netCol ${SQLLiteTypes.doubleType} default 0.0,
        $_settingIDCol ${SQLLiteTypes.intType} NOT NULL,
        $_extraDays ${SQLLiteTypes.doubleType} NOT NULL,
        $_athPrice ${SQLLiteTypes.doubleType} NOT NULL,
        $_initialPrice ${SQLLiteTypes.doubleType} NOT NULL,
        $_taxValue ${SQLLiteTypes.doubleType} NOT NULL,
        $_bankFeeValue ${SQLLiteTypes.doubleType} NOT NULL,
        $_dateCol ${SQLLiteTypes.stringType} TEXT NOT NULL,
        $_createdAtCol ${SQLLiteTypes.intType} NOT NULL,
        $_isCompleted ${SQLLiteTypes.intType} NOT NULL CHECK(is_completed IN (0,1))
      )""";
  }

  Future<int> insertTransaction(Transaction detail) async {
    final db = await wrapper.database;
    return db.insert(
      tableName,
      detail.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<bool> saveRecord(Transaction rec) async {
    final db = await wrapper.database;
    return await db.update(tableName, rec.toJson()) != 0;
  }

  Future<bool> checkIfTransactionExists(int id) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      where: "$_idCol=$id",
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<Transaction>?> getRecentTransactions(
      int offset, int limit) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      orderBy: _createdAtCol,
      offset: offset,
      limit: limit,
    );
    result.map((el) {
      return Transaction.fromJson(
        el,
      );
    }).toList();
  }

  Future<Transaction?> getTransactionByID(int id) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      where: "$_idCol=$id",
    );
    if (result.isEmpty) {
      return null;
    }
    return Transaction.fromJson(result.first);
  }
}
