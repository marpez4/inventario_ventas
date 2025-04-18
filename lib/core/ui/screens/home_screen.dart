import 'package:flutter/material.dart';
import 'package:inventario_ventas/core/providers/auth.provider.dart';
import 'package:inventario_ventas/core/ui/screens/cliente_screen.dart';
import 'package:inventario_ventas/core/ui/screens/usuario.screen.dart';
import 'package:inventario_ventas/core/ui/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'sucursal_screen.dart';
import 'producto_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Sistema Inventario & Ventas'),
      body: ListView(
        children: [
          if(auth.esAdmin)
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Sucursales'),
            subtitle: const Text('Gestionar sucursales'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SucursalScreen()),
              );
            },
          ),
          if(auth.esAdmin)
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Productos'),
            subtitle: const Text('Gestionar productos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductoScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            subtitle: const Text('Gestionar clientes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClienteScreen()),
              );
            },
          ),
          if(auth.esAdmin)
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Usuarios'),
            subtitle: const Text('Gestionar usuarios del sistema'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsuarioScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
