import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task1/models/task.dart'; // Adjust the import based on your models

class SQLiteHelper {
  static const _databaseName = "task_database.db";
  static const _databaseVersion = 1;
  static const table = 'tasks';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnPriority = 'priority';
  static const columnEndDate = 'endDate';
  static const columnStatus = 'status';

  // Singleton pattern for database
  SQLiteHelper._privateConstructor();
  static final SQLiteHelper instance = SQLiteHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnPriority TEXT,
        $columnEndDate TEXT,
        $columnStatus TEXT
      )
    ''');
  }

  // Export all tasks to SQLite
  Future<void> exportTasks(List<Task> tasks) async {
    final db = await database;

    // Begin transaction for bulk insert
    Batch batch = db.batch();

    for (var task in tasks) {
      batch.insert(table, {
        columnTitle: task.title,
        columnDescription: task.description,
        columnPriority: task.priority,
        columnEndDate: task.endDate.toIso8601String(),
        columnStatus: task.status,
      });
    }

    // Execute the batch
    await batch.commit();
  }

  // Import tasks from SQLite
  Future<List<Task>> importTasks() async {
    final db = await database;

    // Get all tasks from the table
    List<Map<String, dynamic>> result = await db.query(table);

    // Convert the result to a list of Task objects
    return result.map((taskMap) {
      return Task(
        id: taskMap[columnId],
        title: taskMap[columnTitle],
        description: taskMap[columnDescription],
        priority: taskMap[columnPriority],
        endDate: DateTime.parse(taskMap[columnEndDate]),
        status: taskMap[columnStatus],
        lastUpdated: DateTime
            .now(), // or use the appropriate value from taskMap if available
      );
    }).toList();
  }
}
