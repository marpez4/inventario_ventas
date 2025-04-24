import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/venta.dart';
import '../models/detalle_venta.dart';

class VentaService {
  final dbHelper = DatabaseHelper();

  Future<int> registrarVenta(Venta venta, List<DetalleVenta> detalles) async {
    final db = await dbHelper.database;
    int idVenta = 0;

    await db.transaction((txn) async {
      idVenta = await txn.insert('venta', venta.toMap());

      for (final detalle in detalles) {
        await txn.insert('detalle_venta', detalle.copyWith(idVenta: idVenta).toMap());

        // Descontar stock del producto
        await txn.rawUpdate(
          'UPDATE producto SET stock = stock - ? WHERE id = ?',
          [detalle.cantidad, detalle.idProducto],
        );
      }
    });

    return idVenta;
  }

  Future<List<Venta>> getVentas() async {
    final db = await dbHelper.database;
    final result = await db.query('venta', orderBy: 'fecha DESC');
    return result.map((map) => Venta.fromMap(map)).toList();
  }

  Future<List<DetalleVenta>> getDetallesPorVenta(int idVenta) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'detalle_venta',
      where: 'id_venta = ?',
      whereArgs: [idVenta],
    );
    return result.map((map) => DetalleVenta.fromMap(map)).toList();
  }
}
