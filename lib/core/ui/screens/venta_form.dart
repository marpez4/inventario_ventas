import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventario_ventas/core/ui/screens/historial_ventas_screen.dart';
import 'package:provider/provider.dart';

import '../../models/venta.dart';
import '../../models/detalle_venta.dart';
import '../../models/productos.dart';
import '../../models/sucursal.dart';
import '../../models/cliente.dart';
import '../../services/venta_service.dart';
import '../../providers/producto_provider.dart';
import '../../providers/sucursal_provider.dart';
import '../../providers/cliente_provider.dart';

class VentaForm extends StatefulWidget {
  const VentaForm({super.key});

  @override
  State<VentaForm> createState() => _VentaFormState();
}

class _VentaFormState extends State<VentaForm> {
  final _formKey = GlobalKey<FormState>();
  int? _sucursalId;
  int? _clienteId;
  String? _metodoPago;
  final Map<int, int> _cantidades = {}; // idProducto : cantidad
  final _ventaService = VentaService();

  @override
  void initState() {
    super.initState();
    context.read<ProductoProvider>().cargarProductos();
    context.read<SucursalProvider>().cargarSucursales();
    context.read<ClienteProvider>().cargarClientes();
  }

  double _calcularTotal(List<Producto> productos) {
    double total = 0;
    for (final producto in productos) {
      final cantidad = _cantidades[producto.id] ?? 0;
      total += cantidad * producto.precio;
    }
    return total;
  }

  void _registrarVenta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cantidades.values.every((c) => c == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un producto')),
      );
      return;
    }

    final productos = context.read<ProductoProvider>().productos;
    final fecha = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final total = _calcularTotal(productos);

    final venta = Venta(
      fecha: fecha,
      idCliente: _clienteId,
      idSucursal: _sucursalId!,
      metodoPago: _metodoPago!,
      total: total,
    );

    final detalles = productos
        .where((p) => (_cantidades[p.id] ?? 0) > 0)
        .map((p) => DetalleVenta(
              idVenta: 0,
              idProducto: p.id!,
              cantidad: _cantidades[p.id]!,
              precioUnitario: p.precio,
            ))
        .toList();

    // Simulación de pago visual
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Procesando pago...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Método: $_metodoPago'),
            const SizedBox(height: 8),
            Text('Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    // Simular retraso de pago
    await Future.delayed(const Duration(seconds: 10));

    // Cerrar diálogo
    if (context.mounted) Navigator.pop(context);

    // Guardar venta
    await _ventaService.registrarVenta(venta, detalles);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistorialVentasScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta registrada con éxito!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sucursales = context.watch<SucursalProvider>().sucursales;
    final clientes = context.watch<ClienteProvider>().clientes;
    final listaProductos = context.watch<ProductoProvider>().productos;
    final productos =
        listaProductos.where((p) => p.idSucursal == _sucursalId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar venta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _sucursalId,
                decoration: const InputDecoration(labelText: 'Sucursal'),
                items: sucursales
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.nombre),
                        ))
                    .toList(),
                validator: (v) => v == null ? 'Seleccione una sucursal' : null,
                onChanged: (v) => setState(() => _sucursalId = v),
              ),
              DropdownButtonFormField<int>(
                value: _clienteId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Venta sin cliente')),
                  ...clientes.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.nombre),
                      ))
                ],
                onChanged: (v) => setState(() => _clienteId = v),
              ),
              const SizedBox(height: 16),
              const Text('Productos:', style: TextStyle(fontSize: 16)),
              if (_sucursalId != null)
                ...productos.where((p) => p.idSucursal == _sucursalId).map((p) {
                  final stock = p.stock;
                  final cantidad = _cantidades[p.id] ?? 0;
                  final disponible = stock - cantidad;

                  return Column(
                    children: [
                      ListTile(
                        title: Text(p.nombre),
                        subtitle: Text(
                            'Precio: \$${p.precio.toStringAsFixed(2)} • Stock: $stock'),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: cantidad > 0
                                    ? () {
                                        setState(() {
                                          _cantidades[p.id!] = cantidad - 1;
                                        });
                                      }
                                    : null,
                              ),
                              Text('$cantidad'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: disponible > 0
                                    ? () {
                                        setState(() {
                                          _cantidades[p.id!] = cantidad + 1;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider()
                    ],
                  );
                }).toList()
              else
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Seleccione una sucursal para ver productos'),
                ),
              DropdownButtonFormField<String>(
                value: _metodoPago,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: const [
                  DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(
                      value: 'Tarjeta', child: Text('Tarjeta de Crédito')),
                  DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                ],
                validator: (v) =>
                    v == null ? 'Seleccione un método de pago' : null,
                onChanged: (v) => setState(() => _metodoPago = v),
              ),
              const SizedBox(height: 16),
              Text(
                'Total: \$${_calcularTotal(productos).toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _registrarVenta,
                child: const Text('Registrar venta'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
