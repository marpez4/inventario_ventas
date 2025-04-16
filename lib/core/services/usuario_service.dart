import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/usuario.dart';

class UsuarioService {
  final dbHelper = DatabaseHelper();

  Future<int> insertUsuario(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.insert('usuario', usuario.toMap());
  }

  Future<List<Usuario>> getUsuarios() async {
    final db = await dbHelper.database;
    final maps = await db.query('usuario');
    return maps.map((map) => Usuario.fromMap(map)).toList();
  }

  Future<int> updateUsuario(Usuario usuario) async {
    final db = await dbHelper.database;
    return await db.update(
      'usuario',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> deleteUsuario(int id) async {
    final db = await dbHelper.database;
    return await db.delete('usuario', where: 'id = ?', whereArgs: [id]);
  }

  Future<Usuario?> login(String correo, String contrasena) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'usuario',
      where: 'correo = ? AND contrasena = ?',
      whereArgs: [correo, contrasena],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    } else {
      return null;
    }
  }
}
