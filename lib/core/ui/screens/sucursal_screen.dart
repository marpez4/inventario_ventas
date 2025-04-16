import 'package:flutter/material.dart';
import 'package:inventario_ventas/core/ui/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/sucursal_provider.dart';
import '../widgets/sucursal_form.dart';

class SucursalScreen extends StatefulWidget {
  const SucursalScreen({super.key});

  @override
  State<SucursalScreen> createState() => _SucursalScreenState();
}

class _SucursalScreenState extends State<SucursalScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SucursalProvider>().cargarSucursales();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SucursalProvider>();

    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Sucursal'),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.sucursales.length,
              itemBuilder: (context, index) {
                final sucursal = provider.sucursales[index];
                return ListTile(
                  title: Text(sucursal.nombre),
                  subtitle:
                      Text(sucursal.ubicacion ?? 'Sin ubicación registrada'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => SucursalForm(sucursal: sucursal),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Eliminar sucursal'),
                              content: const Text(
                                  '¿Estás seguro de eliminar esta sucursal?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            provider.eliminarSucursal(sucursal.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Sucursal eliminada!')),
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
            builder: (_) => const SucursalForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
