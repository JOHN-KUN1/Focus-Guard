import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/locked_app.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_lock.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isDone INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE locked_apps (
        packageName TEXT PRIMARY KEY,
        appName TEXT NOT NULL
      )
    ''');
  }

  // --- Task Operations ---

  Future<Task> createTask(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<List<Task>> getTasksForDate(String dateStr) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'createdAt = ?',
      whereArgs: [dateStr],
      orderBy: 'id ASC',
    );
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countIncompleteTasks(String dateStr) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM tasks WHERE createdAt = ? AND isDone = 0',
      [dateStr],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // --- Locked App Operations ---

  Future<void> addLockedApp(LockedApp app) async {
    final db = await instance.database;
    await db.insert(
      'locked_apps',
      app.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LockedApp>> getLockedApps() async {
    final db = await instance.database;
    final result = await db.query('locked_apps');
    return result.map((json) => LockedApp.fromMap(json)).toList();
  }

  Future<int> removeLockedApp(String packageName) async {
    final db = await instance.database;
    return await db.delete(
      'locked_apps',
      where: 'packageName = ?',
      whereArgs: [packageName],
    );
  }
}
