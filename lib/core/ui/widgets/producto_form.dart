import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/productos.dart';
import '../../providers/producto_provider.dart';
import '../../providers/sucursal_provider.dart';
import '../../models/sucursal.dart';

class ProductoForm extends StatefulWidget {
  final Producto? producto;
  const ProductoForm({Key? key, this.producto}) : super(key: key);

  @override
  State<ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  String? _descripcion;
  late String _precioStr;
  late String _stockStr;
  int? _sucursalSeleccionadaId;

  @override
  void initState() {
    super.initState();
    _nombre = widget.producto?.nombre ?? '';
    _descripcion = widget.producto?.descripcion;
    _precioStr = widget.producto?.precio.toString() ?? '';
    _stockStr = widget.producto?.stock.toString() ?? '';
    _sucursalSeleccionadaId = widget.producto?.idSucursal;

    final sucursalProvider = context.read<SucursalProvider>();
    if (sucursalProvider.sucursales.isEmpty) {
      sucursalProvider.cargarSucursales();
    }
  }

  void _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState?.save();

    if (_sucursalSeleccionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una sucursal.')),
      );
      return;
    }

    final precio = double.tryParse(_precioStr) ?? 0.0;
    final stock = int.tryParse(_stockStr) ?? 0;

    final nuevoProducto = Producto(
      id: widget.producto?.id,
      nombre: _nombre,
      descripcion: _descripcion,
      precio: precio,
      stock: stock,
      idSucursal: _sucursalSeleccionadaId!,
    );

    final provider = context.read<ProductoProvider>();
    if (widget.producto == null) {
      await provider.agregarProducto(nuevoProducto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado exitosamente!')),
      );
    } else {
      await provider.actualizarProducto(nuevoProducto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado exitosamente!')),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final sucursalProvider = context.watch<SucursalProvider>();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            TextFormField(
              initialValue: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo requerido' : null,
              onSaved: (value) => _nombre = value!,
            ),
            TextFormField(
              initialValue: _descripcion,
              decoration:
                  const InputDecoration(labelText: 'Descripción (opcional)'),
              onSaved: (value) => _descripcion = value,
            ),
            TextFormField(
              initialValue: _precioStr,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo requerido' : null,
              onSaved: (value) => _precioStr = value!,
            ),
            TextFormField(
              initialValue: _stockStr,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo requerido' : null,
              onSaved: (value) => _stockStr = value!,
            ),
            DropdownButtonFormField<int>(
              value: _sucursalSeleccionadaId,
              items: sucursalProvider.sucursales
                  .map((Sucursal sucursal) {
                    return DropdownMenuItem<int>(
                      value: sucursal.id!,
                      child: Text(sucursal.nombre),
                    );
                  })
                  .toList()
                  .cast<DropdownMenuItem<int>>(),
              decoration: const InputDecoration(labelText: 'Sucursal'),
              validator: (value) =>
                  value == null ? 'Seleccione una sucursal' : null,
              onChanged: (value) {
                setState(() {
                  _sucursalSeleccionadaId = value;
                });
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _guardar,
                child: Text(widget.producto == null ? 'Guardar' : 'Actualizar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
