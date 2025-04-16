import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'inventario_ventas4.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE sucursal(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    ubicacion TEXT
    );
    ''');

    await db.execute('''
    CREATE TABLE producto (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    descripcion TEXT,
    precio REAL NOT NULL,
    stock INTEGER NOT NULL,
    id_sucursal INTEGER NOT NULL,
    FOREIGN KEY (id_sucursal) REFERENCES sucursal (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE cliente (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    correo TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE usuario (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    correo TEXT NOT NULL,
    contrasena TEXT NOT NULL,
    rol TEXT NOT NULL
    )
    ''');

    // Insertamos usuarios por defecto
    await db.insert('usuario', {
      'nombre': 'Admin Principal',
      'correo': 'admin@iv.com',
      'contrasena': 'admin123',
      'rol': 'admin',
    });

    await db.insert('usuario', {
      'nombre': 'Vendedor',
      'correo': 'vendedor@iv.com',
      'contrasena': 'vendedor123',
      'rol': 'vendedor',
    });
  }
}
