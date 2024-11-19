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
    String path = join(await getDatabasesPath(), 'repair_requests.db');
    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE repair_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ownerName TEXT,
        phoneNumber TEXT,
        carModel TEXT,
        issueDescription TEXT,
        date TEXT,
        time TEXT,
        status TEXT DEFAULT 'в работе',
        completionTime TEXT DEFAULT NULL,
        completionDate TEXT DEFAULT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE painting_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ownerName TEXT,
        phoneNumber TEXT,
        carModel TEXT,
        color TEXT,
        date TEXT,
        status TEXT DEFAULT 'в работе'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE repair_requests ADD COLUMN completionDate TEXT DEFUALT NULL");
      await db.execute(
        "ALTER TABLE repair_requests ADD COLUMN completionTime TEXT DEFUALT NULL");
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS painting_requests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ownerName TEXT,
          phoneNumber TEXT,
          carModel TEXT,
          color TEXT,
          date TEXT,
          status TEXT DEFAULT 'в работе' 
        )
      ''');
    }
  }

  Future<void> insertRepairRequest(Map<String, dynamic> repairRequest) async {
    final db = await database;
    await db.insert('repair_requests', {
      ...repairRequest,
      'status': repairRequest['stats'] ?? 'в работе',
    });
  }

  Future<List<Map<String, dynamic>>> getRepairRequest() async {
    final db = await database;
    return await db.query('repair_requests');
  }

  Future<void> updateRepairStatus(int id, String newStatus) async {
    final db = await database;
    Map<String, dynamic> updateFields = {'status': newStatus};
    if (newStatus == 'выполнено') {
      final now = DateTime.now();
      final formattedTime = 
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      final formattedDate = 
          "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
      updateFields['completionTime'] = formattedTime;
      updateFields['completionDate'] = formattedDate;   
    }
    await db.update(
      'repair_requests',
      updateFields,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> UpdateRequest(int id, Map<String, dynamic> updatedRequest) async {
    final db = await database;
    await db.update(
      'repair_requests',
      updatedRequest,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertPaintingRequest(Map<String, dynamic> paintingRequest) async {
    final db = await database;
    await db.insert('painting_requests', {
      ...paintingRequest,
      'status': paintingRequest['status'] ?? 'в работе',
    });
  }

  Future<List<Map<String, dynamic>>> getPaintingRequests() async {
    final db = await database;
    return await db.query('painting_requests');
  }

  Future<void> updatePaintingStatus(int id, String newStatus) async {
    final db = await database;
    Map<String, dynamic> updateFields = {'status': newStatus};
    if (newStatus == 'выполнено') {
      final now = DateTime.now();
      final formattedDate = 
          "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}";
        updateFields['completionDate'] = formattedDate;
    }
    await db.update(
      'painting_requests',
      updateFields,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePaintingRequest(int id) async {
    final db = await database;
    await db.delete(
      'painting_requests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePaintingRequest(int id, Map<String, dynamic> updatedRequest) async {
    final db = await database;
    await db.update(
      'painting_requests',
      updatedRequest,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}