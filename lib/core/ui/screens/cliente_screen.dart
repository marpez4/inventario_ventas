import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';
import '../widgets/cliente_form.dart';

class ClienteScreen extends StatefulWidget {
  const ClienteScreen({super.key});

  @override
  State<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends State<ClienteScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClienteProvider>().cargarClientes();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.clientes.isEmpty
              ? const Center(child: Text('No hay clientes registrados'))
              : ListView.builder(
                  itemCount: provider.clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = provider.clientes[index];
                    return ListTile(
                      title: Text(cliente.nombre),
                      subtitle: Text(cliente.correo),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => ClienteForm(cliente: cliente),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Eliminar cliente'),
                                  content: const Text(
                                      '¿Deseas eliminar este cliente?'),
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
                              if (confirm == true) {
                                provider.eliminarCliente(cliente.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Cliente eliminado!')));
                              }
                            },
                          )
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
            builder: (_) => const ClienteForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
