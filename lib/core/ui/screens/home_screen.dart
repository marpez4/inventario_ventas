import 'package:flutter/material.dart';
import 'sucursal_screen.dart';
import 'producto_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Inventario & Ventas'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Sucursales'),
            subtitle: const Text('Gestionar sucursales de la empresa'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SucursalScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Productos'),
            subtitle: const Text('Gestionar productos de la empresa'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
