import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('xra.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        isLocked INTEGER DEFAULT 0,
        pinHash TEXT,
        biometricEnabled INTEGER DEFAULT 0,
        coverEmoji TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE videos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        filePath TEXT NOT NULL,
        thumbnailPath TEXT,
        duration INTEGER,
        fileSize INTEGER,
        source TEXT,
        playlistId INTEGER,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (playlistId) REFERENCES playlists(id)
      )
    ''');

    // Insert default "All Videos" playlist
    await db.insert('playlists', {
      'name': 'All Videos',
      'isLocked': 0,
      'biometricEnabled': 0,
      'coverEmoji': '🎬',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // ── PLAYLIST CRUD ──
  Future<int> insertPlaylist(Playlist playlist) async {
    final db = await database;
    return await db.insert('playlists', playlist.toMap());
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final maps = await db.query('playlists', orderBy: 'createdAt ASC');
    return maps.map((m) => Playlist.fromMap(m)).toList();
  }

  Future<Playlist?> getPlaylist(int id) async {
    final db = await database;
    final maps = await db.query('playlists', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Playlist.fromMap(maps.first);
  }

  Future<int> updatePlaylist(Playlist playlist) async {
    final db = await database;
    return await db.update(
      'playlists',
      playlist.toMap(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  Future<int> deletePlaylist(int id) async {
    final db = await database;
    await db.update('videos', {'playlistId': null}, where: 'playlistId = ?', whereArgs: [id]);
    return await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  // ── VIDEO CRUD ──
  Future<int> insertVideo(VideoItem video) async {
    final db = await database;
    return await db.insert('videos', video.toMap());
  }

  Future<List<VideoItem>> getAllVideos() async {
    final db = await database;
    final maps = await db.query('videos', orderBy: 'addedAt DESC');
    return maps.map((m) => VideoItem.fromMap(m)).toList();
  }

  Future<List<VideoItem>> getVideosByPlaylist(int playlistId) async {
    final db = await database;
    final maps = await db.query('videos',
        where: 'playlistId = ?', whereArgs: [playlistId], orderBy: 'addedAt DESC');
    return maps.map((m) => VideoItem.fromMap(m)).toList();
  }

  Future<int> updateVideo(VideoItem video) async {
    final db = await database;
    return await db.update('videos', video.toMap(),
        where: 'id = ?', whereArgs: [video.id]);
  }

  Future<int> deleteVideo(int id) async {
    final db = await database;
    return await db.delete('videos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getVideoCount(int playlistId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM videos WHERE playlistId = ?', [playlistId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
