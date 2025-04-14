import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/productos.dart';

class ProductoService {
  final dbHelper = DatabaseHelper();

  Future<int> insertProducto(Producto producto) async {
    final db = await dbHelper.database;
    return await db.insert('producto', producto.toMap());
  }

  Future<List<Producto>> getProductos() async {
    final db = await dbHelper.database;
    final maps = await db.query('producto');
    return maps.map((map) => Producto.fromMap(map)).toList();
  }

  Future<int> updateProducto(Producto producto) async {
    final db = await dbHelper.database;
    return await db.update(
      'producto',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<int> deleteProducto(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'producto',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}