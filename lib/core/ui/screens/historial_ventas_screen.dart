import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventario_ventas/core/ui/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../../models/venta.dart';
import '../../models/detalle_venta.dart';
import '../../models/productos.dart';
import '../../services/venta_service.dart';
import '../../providers/sucursal_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/producto_provider.dart';
import '../widgets/custom_app_bar.dart';

class HistorialVentasScreen extends StatefulWidget {
  const HistorialVentasScreen({super.key});

  @override
  State<HistorialVentasScreen> createState() => _HistorialVentasScreenState();
}

class _HistorialVentasScreenState extends State<HistorialVentasScreen> {
  final _ventaService = VentaService();
  List<Venta> _ventas = [];
  final Map<int, List<DetalleVenta>> _detallesPorVenta = {};

  int? _sucursalSeleccionadaId;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    final ventas = await _ventaService.getVentas();
    final Map<int, List<DetalleVenta>> detallesMap = {};

    for (final venta in ventas) {
      final detalles = await _ventaService.getDetallesPorVenta(venta.id!);
      detallesMap[venta.id!] = detalles;
    }

    setState(() {
      _ventas = ventas;
      _detallesPorVenta.clear();
      _detallesPorVenta.addAll(detallesMap);
    });
  }

  Future<void> _seleccionarFecha({required bool esInicio}) async {
    final initialDate = esInicio ? _fechaInicio ?? DateTime.now() : _fechaFin ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  List<Venta> _ventasFiltradas() {
    return _ventas.where((venta) {
      final fechaVenta = DateTime.parse(venta.fecha);

      final coincideSucursal = _sucursalSeleccionadaId == null || venta.idSucursal == _sucursalSeleccionadaId;
      final coincideFechaInicio = _fechaInicio == null || fechaVenta.isAfter(_fechaInicio!.subtract(const Duration(days: 1)));
      final coincideFechaFin = _fechaFin == null || fechaVenta.isBefore(_fechaFin!.add(const Duration(days: 1)));

      return coincideSucursal && coincideFechaInicio && coincideFechaFin;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sucursales = context.watch<SucursalProvider>().sucursales;
    final clientes = context.watch<ClienteProvider>().clientes;
    final productos = context.watch<ProductoProvider>().productos;
    final ventas = _ventasFiltradas();

    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Historial de Ventas'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<int?>(
                  value: _sucursalSeleccionadaId,
                  decoration: const InputDecoration(labelText: 'Filtrar por sucursal'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas las sucursales')),
                    ...sucursales.map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.nombre),
                        ))
                  ],
                  onChanged: (v) => setState(() => _sucursalSeleccionadaId = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(_fechaInicio != null
                            ? 'Desde: ${DateFormat('dd/MM/yyyy').format(_fechaInicio!)}'
                            : 'Desde'),
                        onPressed: () => _seleccionarFecha(esInicio: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(_fechaFin != null
                            ? 'Hasta: ${DateFormat('dd/MM/yyyy').format(_fechaFin!)}'
                            : 'Hasta'),
                        onPressed: () => _seleccionarFecha(esInicio: false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ventas.isEmpty
                ? const Center(child: Text('No hay ventas que coincidan con el filtro'))
                : ListView.builder(
                    itemCount: ventas.length,
                    itemBuilder: (context, index) {
                      final venta = ventas[index];
                      final sucursal = sucursales.firstWhere((s) => s.id == venta.idSucursal);
                      final cliente = clientes.any((c) => c.id == venta.idCliente)
                          ? clientes.firstWhere((c) => c.id == venta.idCliente)
                          : null;
                      final detalles = _detallesPorVenta[venta.id!] ?? [];

                      return ExpansionTile(
                        title: Text(
                          'Venta: \$${venta.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${venta.fecha} | ${sucursal.nombre} | ${cliente?.nombre ?? 'Sin cliente'}',
                        ),
                        children: [
                          ListTile(
                            title: const Text('Método de pago'),
                            subtitle: Text(venta.metodoPago),
                          ),
                          ...detalles.map((detalle) {
                            final producto = productos.firstWhere(
                              (p) => p.id == detalle.idProducto,
                              orElse: () => Producto(
                                id: -1,
                                nombre: 'Producto eliminado',
                                descripcion: '',
                                precio: 0,
                                stock: 0,
                                idSucursal: -1,
                              ),
                            );
                            return ListTile(
                              title: Text(
                                producto.nombre,
                                style: TextStyle(
                                  color: producto.id == -1 ? Colors.red : null,
                                  fontStyle: producto.id == -1 ? FontStyle.italic : null,
                                ),
                              ),
                              subtitle: Text('Cantidad: ${detalle.cantidad}'),
                              trailing: Text(
                                  '\$${(detalle.precioUnitario * detalle.cantidad).toStringAsFixed(2)}'),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
