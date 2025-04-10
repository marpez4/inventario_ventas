import 'package:flutter/material.dart';
import 'package:inventario_ventas/core/providers/sucursal_provider.dart';
import 'package:inventario_ventas/core/ui/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (_) => SucursalProvider()),
      ],
      child: const MyApp(),
       )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Inventario y Ventas',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo
      ),
      home: const HomeScreen(),
    );
  }

}
