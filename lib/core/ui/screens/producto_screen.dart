import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/productos.dart';
import '../../providers/producto_provider.dart';
import '../../providers/sucursal_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/producto_form.dart';
import '../widgets/custom_app_bar.dart';

class ProductoScreen extends StatefulWidget {
  const ProductoScreen({super.key});

  @override
  State<ProductoScreen> createState() => _ProductoScreenState();
}

class _ProductoScreenState extends State<ProductoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductoProvider>().cargarProductos();
    context.read<SucursalProvider>().cargarSucursales();
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductoProvider>().productos;
    final sucursales = context.watch<SucursalProvider>().sucursales;

    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Productos'),
      body: sucursales.isEmpty
          ? const Center(child: Text('No hay sucursales disponibles'))
          : ListView(
              children: sucursales.map((sucursal) {
                final productosSucursal = productos
                    .where((p) => p.idSucursal == sucursal.id)
                    .toList();

                return ExpansionTile(
                  title: Text(
                    sucursal.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text('Total de productos: ${productosSucursal.length}'),
                  children: productosSucursal.map((producto) {
                    return ListTile(
                      title: Text(producto.nombre),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (producto.descripcion?.isNotEmpty ?? false)
                            Text(producto.descripcion!),
                          Text(
                              'Precio: \$${producto.precio.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) =>
                                    ProductoForm(producto: producto),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Eliminar producto'),
                                  content: const Text(
                                      '¿Deseas eliminar este producto?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && producto.id != null) {
                                await context
                                    .read<ProductoProvider>()
                                    .eliminarProducto(producto.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Producto eliminado')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const ProductoForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
