import 'package:flutter/material.dart';
import 'package:inventario_ventas/core/providers/auth.provider.dart';
import 'package:inventario_ventas/core/ui/screens/cliente_screen.dart';
import 'package:inventario_ventas/core/ui/screens/historial_ventas_screen.dart';
import 'package:inventario_ventas/core/ui/screens/reporte_inventario_screen.dart';
import 'package:inventario_ventas/core/ui/screens/usuario.screen.dart';
import 'package:inventario_ventas/core/ui/screens/venta_form.dart';
import 'package:inventario_ventas/core/ui/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'sucursal_screen.dart';
import 'producto_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final accesos = <Map<String, dynamic>>[
      {
        'label': 'Clientes',
        'icon': Icons.people,
        'screen': const ClienteScreen(),
      },
      {
        'label': 'Ventas',
        'icon': Icons.point_of_sale,
        'screen': const VentaForm(),
      },
      {
        'label': 'Historial de Ventas',
        'icon': Icons.receipt_long,
        'screen': const HistorialVentasScreen(),
      },
      {
        'label': 'Reporte de Inventario',
        'icon': Icons.inventory_2,
        'screen': const ReporteInventarioScreen(),
      },
    ];

    if (auth.esAdmin) {
      accesos.insertAll(0, [
        {
          'label': 'Sucursales',
          'icon': Icons.store,
          'screen': const SucursalScreen(),
        },
        {
          'label': 'Productos',
          'icon': Icons.inventory,
          'screen': const ProductoScreen(),
        },
        {
          'label': 'Usuarios',
          'icon': Icons.lock_person,
          'screen': const UsuarioScreen(),
        },
      ]);
    }

    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Inicio'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: accesos.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 8), // Menos espacio entre Cards
          itemBuilder: (context, index) {
            final acceso = accesos[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.zero, // Eliminar margen propio del Card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8), // Más compacto
                leading: Icon(acceso['icon'],
                    size: 28, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  acceso['label'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => acceso['screen']),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
