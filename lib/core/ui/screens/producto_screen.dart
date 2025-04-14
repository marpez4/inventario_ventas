import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/productos.dart';
import '../../providers/producto_provider.dart';
import '../widgets/producto_form.dart';

class ProductoScreen extends StatefulWidget {
  const ProductoScreen({Key? key}) : super(key: key);

  @override
  State<ProductoScreen> createState() => _ProductoScreenState();
}

class _ProductoScreenState extends State<ProductoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductoProvider>().cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.productos.isEmpty
              ? const Center(child: Text('No hay productos registrados'))
              : ListView.builder(
                  itemCount: provider.productos.length,
                  itemBuilder: (context, index) {
                    final producto = provider.productos[index];
                    return ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text(
                          'Precio: \$${producto.precio.toStringAsFixed(2)} - Stock: ${producto.stock}'),
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
                                      '¿Estás seguro de eliminar este producto?'),
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
                                provider.eliminarProducto(producto.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Producto eliminado!')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
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
