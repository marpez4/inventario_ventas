import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/productos.dart';
import '../../providers/producto_provider.dart';
import '../../providers/sucursal_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_app_bar.dart';

class ReporteInventarioScreen extends StatelessWidget {
  const ReporteInventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductoProvider>().productos;
    final sucursales = context.watch<SucursalProvider>().sucursales;

    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Reporte de Inventario'),
      body: sucursales.isEmpty
          ? const Center(child: Text('No hay sucursales disponibles'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: sucursales.map((sucursal) {
                final productosSucursal = productos
                    .where((p) => p.idSucursal == sucursal.id)
                    .toList();

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      sucursal.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Productos: ${productosSucursal.length}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    children: productosSucursal.map((p) {
                      final stockBajo = p.stock <= 5;
                      return ListTile(
                        title: Text(p.nombre),
                        subtitle: Text(p.descripcion ?? 'Sin descripción'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Stock',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: stockBajo ? Colors.red : Colors.grey),
                            ),
                            Text(
                              '${p.stock}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: stockBajo ? Colors.red : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
