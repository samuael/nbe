import 'package:nbe/libs.dart';
import 'package:sqflite/sqflite.dart';

class SettingLocalProvider {
  static const String tableName = "setting";
  static const String _idCol = "id";
  static const String _taxPerGramCol = "taxPerGram";
  static const String _bankFeePercentageCol = "bankFeePercentage";
  static const String _bonusByNBEInPercentage = "bonusByNBEInPercentage";
  static const String _holdPercentageCol = "holdPercentage";
  static const String _createdAtCol = "createdAt";

  final NBEDatabase wrapper;
  SettingLocalProvider(this.wrapper) : super();

  static String createOrReplaceTableString() {
    return """CREATE TABLE IF NOT EXISTS $tableName(
        $_idCol ${SQLLiteTypes.stringType} PRIMARY KEY,
        $_taxPerGramCol ${SQLLiteTypes.doubleType} DEFAULT 0.0,
        $_bankFeePercentageCol ${SQLLiteTypes.doubleType} NOT NULL,
        $_bonusByNBEInPercentage ${SQLLiteTypes.doubleType} NOT NULL,
        $_holdPercentageCol ${SQLLiteTypes.doubleType} default 0.0 NOT NULL,
        $_createdAtCol ${SQLLiteTypes.intType} NOT NULL
      )""";
  }

  static String insertDefaultSetting(Setting setting) {
    return """ INSERT INTO $tableName($_idCol,$_taxPerGramCol,$_bankFeePercentageCol,$_holdPercentageCol,$_bonusByNBEInPercentage,$_createdAtCol)
      values(${setting.id}, ${setting.taxPerGram}, ${setting.bankFeePercentage}, ${setting.holdPercentage}, ${setting.bonusByNBEInPercentage}, ${setting.createdAt})
    """;
  }

  Future<int> insertSetting(Setting setting) async {
    final db = await wrapper.database;
    return db.insert(
      tableName,
      setting.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Setting?> getSettingByID(String id) async {
    final db = await wrapper.database;
    final result =
        await db.query(tableName); //, where: "$_idCol=?", whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    return Setting.fromJson(result[0]);
  }

  Future<Setting?> getSettingByDetail(Setting setting) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      where:
          "$_taxPerGramCol=${setting.taxPerGram} and $_bankFeePercentageCol=${setting.bankFeePercentage} and $_holdPercentageCol=${setting.holdPercentage} and $_bonusByNBEInPercentage=${setting.bonusByNBEInPercentage}",
    );
    if (result.isEmpty) {
      return null;
    }
    return Setting.fromJson(result[0]);
  }

  Future<bool> checkIfSettingExists(int id) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      where: "$_idCol= ?",
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<Setting>> getRecentSettings() async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      orderBy: _createdAtCol,
    );
    return result.map((el) {
      return Setting.fromJson(
        el,
      );
    }).toList();
  }

  Future<List<Setting>> getAllSettings() async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      orderBy: _createdAtCol,
    );
    return result.map((el) {
      return Setting.fromJson(
        el,
      );
    }).toList();
  }
}
