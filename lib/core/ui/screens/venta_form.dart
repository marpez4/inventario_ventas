import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'historial_ventas_screen.dart';

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
  final Map<int, Producto> _productosSeleccionados = {};
  final _ventaService = VentaService();

  @override
  void initState() {
    super.initState();
    context.read<ProductoProvider>().cargarProductos();
    context.read<SucursalProvider>().cargarSucursales();
    context.read<ClienteProvider>().cargarClientes();
  }

  double _calcularTotal() {
    double total = 0;
    _productosSeleccionados.forEach((id, producto) {
      final cantidad = _cantidades[id] ?? 0;
      total += cantidad * producto.precio;
    });
    return total;
  }

  void _agregarProductoDesdeModal(List<Producto> productosSucursal) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: productosSucursal.map((p) {
          final agotado = p.stock <= 0;

          return ListTile(
            enabled: !agotado,
            title: Text(
              p.nombre,
              style: TextStyle(
                color: agotado ? Colors.grey : null,
                fontStyle: agotado ? FontStyle.italic : null,
              ),
            ),
            subtitle: Text(
              agotado
                  ? 'Producto agotado'
                  : 'Stock: ${p.stock} - \$${p.precio.toStringAsFixed(2)}',
              style: TextStyle(
                color: agotado ? Colors.red : null,
              ),
            ),
            onTap: agotado
                ? null
                : () {
                    setState(() {
                      _productosSeleccionados[p.id!] = p;
                      _cantidades[p.id!] = (_cantidades[p.id] ?? 0) + 1;
                    });
                    Navigator.pop(context);
                  },
          );
        }).toList(),
      ),
    );
  }

  void _registrarVenta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cantidades.values.every((c) => c == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un producto')),
      );
      return;
    }

    final fecha = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final total = _calcularTotal();

    final venta = Venta(
      fecha: fecha,
      idCliente: _clienteId,
      idSucursal: _sucursalId!,
      metodoPago: _metodoPago!,
      total: total,
    );

    final detalles = _productosSeleccionados.entries
        .where((e) => (_cantidades[e.key] ?? 0) > 0)
        .map((entry) => DetalleVenta(
              idVenta: 0,
              idProducto: entry.key,
              cantidad: _cantidades[entry.key]!,
              precioUnitario: entry.value.precio,
            ))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Procesando pago...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Método: $_metodoPago'),
            Text('Total: \$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) Navigator.pop(context);

    await _ventaService.registrarVenta(venta, detalles);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistorialVentasScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta registrada con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<ProductoProvider>().productos;
    final sucursales = context.watch<SucursalProvider>().sucursales;
    final clientes = context.watch<ClienteProvider>().clientes;

    final productosSucursal =
        productos.where((p) => p.idSucursal == _sucursalId).toList();

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
                onChanged: (v) => setState(() {
                  _sucursalId = v;
                  _productosSeleccionados.clear();
                  _cantidades.clear();
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _clienteId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: clientes
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nombre),
                        ))
                    .toList(),
                validator: (v) => v == null ? 'Seleccione un cliente' : null,
                onChanged: (v) => setState(() => _clienteId = v),
              ),
              const SizedBox(height: 12),
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
                    v == null ? 'Seleccione método de pago' : null,
                onChanged: (v) => setState(() => _metodoPago = v),
              ),
              const SizedBox(height: 20),
              if (_sucursalId != null)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () =>
                      _agregarProductoDesdeModal(productosSucursal),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar producto'),
                ),
              const SizedBox(height: 24),
              const Text('Productos seleccionados:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              if (_productosSeleccionados.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Aún no hay productos agregados.'),
                ),
              ..._productosSeleccionados.entries.map((entry) {
                final producto = entry.value;
                final cantidad = _cantidades[entry.key] ?? 0;
                final stockDisponible = producto.stock - cantidad;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text(
                      'Precio: \$${producto.precio.toStringAsFixed(2)}\nStock disponible: ${producto.stock}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: cantidad > 0
                              ? () {
                                  setState(() {
                                    _cantidades[entry.key] = cantidad - 1;
                                    if (_cantidades[entry.key]! == 0) {
                                      _productosSeleccionados.remove(entry.key);
                                      _cantidades.remove(entry.key);
                                    }
                                  });
                                }
                              : null,
                        ),
                        Text('$cantidad'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: stockDisponible > 0
                              ? () {
                                  setState(() {
                                    _cantidades[entry.key] = cantidad + 1;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Total: \$${_calcularTotal().toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                ),
                onPressed: _registrarVenta,
                child: const Text('Registrar venta',
                    style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
