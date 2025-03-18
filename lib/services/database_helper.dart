// services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'video_likes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE likes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_id TEXT UNIQUE,
            created_at TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertLike(String videoId) async {
    final db = await database;
    
    return await db.insert(
      'likes',
      {
        'video_id': videoId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteLike(String videoId) async {
    final db = await database;
    
    return await db.delete(
      'likes',
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
  }

  Future<List<Map<String, dynamic>>> getLikes() async {
    final db = await database;
    
    return await db.query('likes');
  }
}
