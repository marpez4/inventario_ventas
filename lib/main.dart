import 'package:flutter/material.dart';
import 'package:inventario_ventas/core/providers/cliente_provider.dart';
import 'package:inventario_ventas/core/providers/sucursal_provider.dart';
import 'package:inventario_ventas/core/providers/producto_provider.dart';
import 'package:inventario_ventas/core/providers/auth.provider.dart';
import 'package:inventario_ventas/core/ui/screens/home_screen.dart';
import 'package:inventario_ventas/core/ui/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SucursalProvider()),
      ChangeNotifierProvider(create: (_) => ProductoProvider()),
      ChangeNotifierProvider(create: (_) => ClienteProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'Inventario y Ventas',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: auth.estaAutenticado ? const HomeScreen() : const LoginScreen(),
    );
  }
}
