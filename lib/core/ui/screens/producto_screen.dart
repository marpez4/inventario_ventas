import 'package:flutter/material.dart';
import 'package:inventario_ventas/core/providers/auth.provider.dart';
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

  // Modal para agregar stock al prodcucto, solo los usuarios con rol admin puede verlo
  void _mostrarDialogoAgregarStock(Producto producto) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Agregar stock a "${producto.nombre}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock actual: ${producto.stock}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad a agregar',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final cantidad = int.tryParse(controller.text) ?? 0;
              if (cantidad > 0) {
                final actualizado = Producto(
                  id: producto.id,
                  nombre: producto.nombre,
                  descripcion: producto.descripcion,
                  precio: producto.precio,
                  stock: producto.stock + cantidad,
                  idSucursal: producto.idSucursal,
                );
                await context
                    .read<ProductoProvider>()
                    .actualizarProducto(actualizado);
                if (context.mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Se agregaron $cantidad unidades al stock')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese una cantidad válida')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductoProvider>().productos;
    final sucursales = context.watch<SucursalProvider>().sucursales;
    final auth = context.watch<AuthProvider>();

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
                          Text(
                            'Stock: ${producto.stock}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: producto.stock <= 5
                                  ? Colors.red
                                  : Colors.black,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (auth.esAdmin)
                            IconButton(
                              icon: const Icon(Icons.add_box),
                              tooltip: 'Agregar stock',
                              onPressed: () =>
                                  _mostrarDialogoAgregarStock(producto),
                            ),
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
                                      content: Text(
                                          'Producto eliminado exitosamente!')),
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
