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
              children: sucursales.map((sucursal) {
                final productosSucursal = productos
                    .where((p) => p.idSucursal == sucursal.id)
                    .toList();

                return ExpansionTile(
                  title: Text(sucursal.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Total de productos: ${productosSucursal.length}'),
                  children: productosSucursal.map((p) {
                    final stockBajo = p.stock <= 5;
                    return ListTile(
                      title: Text(p.nombre),
                      subtitle: Text(p.descripcion ?? ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Stock: ${p.stock}',
                            style: TextStyle(
                              color: stockBajo ? Colors.red : Colors.black,
                              fontWeight: stockBajo
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text('\$${p.precio.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}
