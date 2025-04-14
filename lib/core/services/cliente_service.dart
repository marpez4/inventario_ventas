import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/cliente.dart';

class ClienteService {
  final dbHelper = DatabaseHelper();

  Future<int> insertCliente(Cliente cliente) async {
    final db = await dbHelper.database;
    return await db.insert('cliente', cliente.toMap());
  }

  Future<List<Cliente>> getClientes() async {
    final db = await dbHelper.database;
    final maps = await db.query('cliente');
    return maps.map((map) => Cliente.fromMap(map)).toList();
  }

  Future<int> updateCliente(Cliente cliente) async {
    final db = await dbHelper.database;
    return await db.update(
      'cliente',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> deleteCliente(int id) async {
    final db = await dbHelper.database;
    return await db.delete('cliente', where: 'id = ?', whereArgs: [id]);
  }
}
