import 'package:nbe/libs.dart';
import 'package:sqflite/sqflite.dart';

@immutable
class NBEDatabase {
  static const String _databaseName = "nbe.db";
  static const int _databaseVersion = 1;

  static NBEDatabase? instance;
  final List<String> createTableStrings;

  const NBEDatabase._init(this.createTableStrings);

  factory NBEDatabase.constructor(List<String> createTableStrings) {
    instance ??= NBEDatabase._init(createTableStrings);
    return instance!;
  }

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    String path = await getDatabasesPath();
    _database = await openDatabase(
      "$path/$_databaseName",
      version: _databaseVersion,
      onCreate: onCreate,
      // onConfigure: onCreate,
    );
    return _database!;
  }

  Future onCreate(
    Database database,
    int version,
  ) async {
    for (int i = 0; i < createTableStrings.length; i++) {
      database.execute(createTableStrings[i]);
    }
  }
}
