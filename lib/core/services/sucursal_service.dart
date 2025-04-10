import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/sucursal.dart';

class SucursalService {
  final dbHelper = DatabaseHelper();

  Future<int> insertSucursal(Sucursal sucursal) async {
    final db = await dbHelper.database;
    return await db.insert('sucursal', sucursal.toMap());
  }

  Future<List<Sucursal>> getSucursales() async {
    final db = await dbHelper.database;
    final maps = await db.query('sucursal');
    return maps.map((map) => Sucursal.fromMap(map)).toList();
  }

  Future<int> updateSucursal(Sucursal sucursal) async {
    final db = await dbHelper.database;
    return await db.update(
      'sucursal',
      sucursal.toMap(),
      where: 'id = ?',
      whereArgs: [sucursal.id],
    );
  }

  Future<int> deleteSucursal(int id) async {
    final db = await dbHelper.database;
    return await db.delete('sucursal', where: 'id = ?', whereArgs: [id]);
  }
}
