import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:students/classes/class_event.dart';

class ClassEventDatabaseHelper {
  static final ClassEventDatabaseHelper _instance = ClassEventDatabaseHelper._internal();
  factory ClassEventDatabaseHelper() => _instance;

  static Database? _database;

  ClassEventDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'class_events_database.db');
    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE class_events(
        id INTEGER PRIMARY KEY,
        day TEXT,
        class_name TEXT,
        start_time TEXT,
        end_time TEXT
      )
    ''');
  }

  Future<List<ClassEvent>> getClassEvents(String day) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('class_events', where: 'day = ?', whereArgs: [day]);
    return List.generate(maps.length, (i) {
      return ClassEvent(
        id: maps[i]['id'],
        day: maps[i]['day'],
        className: maps[i]['class_name'],
        startTime: maps[i]['start_time'],
        endTime: maps[i]['end_time'],
      );
    });
  }

  Future<void> insertClassEvent(ClassEvent classEvent) async {
    final db = await database;
    await db.insert('class_events', classEvent.toMap());
  }

  Future<void> updateClassEvent(ClassEvent classEvent) async {
    final db = await database;
    await db.update(
      'class_events',
      {
        'class_name': classEvent.className,
        'start_time': classEvent.startTime,
        'end_time': classEvent.endTime,
      },
      where: 'id = ?',
      whereArgs: [classEvent.id],
    );
  }


  Future<void> deleteClassEvent(int id) async {
    final db = await database;
    await db.delete(
      'class_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
