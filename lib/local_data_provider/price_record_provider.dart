import 'package:nbe/libs.dart';
import 'package:sqflite/sqflite.dart';

class PriceRecordProvider {
  static const String tableName = "price_records";
  static const String _idCol = "id";
  static const String _dateCol = "date";
  static const String _priceBirrCol = "price_birr";
  static const String _priceUSDCol = "price_usd";

  final NBEDatabase wrapper;

  PriceRecordProvider(this.wrapper);

  static String createOrReplaceTableString() {
    return """CREATE TABLE IF NOT EXISTS $tableName(
        $_idCol ${SQLLiteTypes.stringType} PRIMARY KEY,
        $_priceBirrCol ${SQLLiteTypes.stringType} NOT NULL,
        $_priceUSDCol ${SQLLiteTypes.stringType} NOT NULL,
        $_dateCol ${SQLLiteTypes.intType} UNIQUE NOT NULL
      )""";
  }

  Future<int> insertOrUpdatePriceRecord(PriceRecord detail) async {
    final db = await wrapper.database;
    return db.insert(
      tableName,
      detail.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PriceRecord?> getPriceRecordByDate(String date) async {
    final db = await wrapper.database;
    final result = await db.query(tableName, where: "$_dateCol=$date");
    if (result.isEmpty) {
      return null;
    }
    return PriceRecord.fromJson(result[0]);
  }

  Future<List<PriceRecord?>> getPriceRecords() async {
    final db = await wrapper.database;
    final result =
        await db.rawQuery("SELECT * FROM $tableName ORDER BY $_dateCol DESC");
    if (result.isEmpty) {
      return [];
    }
    return result.map<PriceRecord>((e) {
      return PriceRecord.fromJson(e);
    }).toList();
  }

  Future<bool> deletePriceRecordsByID(List<String> recordsDates) async {
    final db = await wrapper.database;
    final placeholders = List.filled(recordsDates.length, '?').join(', ');
    final result = await db.delete(
      tableName,
      where: "$_dateCol IN ($placeholders)",
      whereArgs: recordsDates,
    );
    if (result == 0) {
      // throw Exception("price record by id $id not found");
      return false;
    }
    // }
    return true;
  }
}
