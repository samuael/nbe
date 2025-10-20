import 'package:nbe/libs.dart';

class StringDataProvider {
  static const String tableName = "strings";

  static const String _idCol = "id";
  static const String _payload = "payload";
  static const String _lastUpdated = "lastUpdated";

  final NBEDatabase wrapper;
  StringDataProvider(this.wrapper) : super();

  static String createOrReplaceTableString() {
    return """CREATE TABLE IF NOT EXISTS $tableName(
        $_idCol ${SQLLiteTypes.intType} PRIMARY KEY,
        $_payload ${SQLLiteTypes.stringType} NOT NULL,
        $_lastUpdated ${SQLLiteTypes.intType} NOT NULL DEFAULT (strftime('%s', 'now'))
      )""";
  }

  static String insertNBESettlementDuration() {
    return """INSERT into $tableName($_idCol, $_payload) values(222, '30')""";
  }

  Future<int> insertStringPayload(StringPayload payload) async {
    final db = await wrapper.database;
    return db.insert(tableName, {
      _idCol: payload.id,
      _payload: payload.payload,
    });
  }

  Future<StringPayload?> getStringPayloadByID(int id) async {
    final db = await wrapper.database;
    final result = await db.query(
      tableName,
      where: "$_idCol=$id",
    );
    if (result.isEmpty) {
      return null;
    }
    return StringPayload.fromJson(result.first);
  }
}
