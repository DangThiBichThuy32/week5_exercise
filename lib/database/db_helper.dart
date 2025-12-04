import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  DatabaseHelper._init();

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  /// Getter to access database (lazy open)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initialize DB with path + create tables
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        // Enable foreign keys (future-friendly)
        await db.execute("PRAGMA foreign_keys = ON");
      },
    );
  }

  /// Create tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  /// READ all notes ordered by last update
  Future<List<Note>> readAll() async {
    try {
      final db = await database;
      final result = await db.query(
        'notes',
        orderBy: 'updatedAt DESC',
      );
      return result.map((e) => Note.fromMap(e)).toList();
    } catch (e) {
      print("❌ Error reading notes: $e");
      return [];
    }
  }

  /// CREATE note
  Future<int> create(Note note) async {
    final db = await database;
    return await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// UPDATE note
  Future<int> update(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// DELETE note
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// OPTIONAL: Delete all notes (for debugging)
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('notes');
  }

  /// Close database safely
  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
