import 'package:flutter/material.dart';
import 'package:inventario_ventas/core/ui/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  const CustomAppBar({super.key, required this.titulo});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final usuario = auth.usuarioActual;

    return AppBar(
      title: Text(titulo),
      actions: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Usuario',
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(usuario?.nombre ?? 'Usuario desconocido',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rol: ${usuario?.rol ?? 'N/A'}'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: const [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Cerrar sesión'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 1) {
              auth.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }
}
