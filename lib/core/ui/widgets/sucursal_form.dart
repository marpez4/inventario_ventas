import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sucursal.dart';
import '../../providers/sucursal_provider.dart';

class SucursalForm extends StatefulWidget {
  final Sucursal? sucursal;

  const SucursalForm({super.key, this.sucursal});

  @override
  State<SucursalForm> createState() => _SucursalFormState();
}

class _SucursalFormState extends State<SucursalForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  String? _ubicacion;

  @override
  void initState() {
    super.initState();
    _nombre = widget.sucursal?.nombre ?? '';
    _ubicacion = widget.sucursal?.ubicacion ?? '';
  }

  void _guardar() async {
    if (_formKey.currentState?.validate() != true) return;

    _formKey.currentState?.save();

    final nuevaSucursal = Sucursal(
      id: widget.sucursal?.id,
      nombre: _nombre,
      ubicacion: _ubicacion,
    );

    final provider = context.read<SucursalProvider>();

    if (widget.sucursal == null) {
      await provider.agregarSucursal(nuevaSucursal);
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sucursal agregada exitosamente!')),
    );
    } else {
      await provider.actualizarSucursal(nuevaSucursal);
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sucursal actualizada exitosamente!')),
    );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
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
              initialValue: _ubicacion,
              decoration:
                  const InputDecoration(labelText: 'Ubicación (opcional)'),
              onSaved: (value) => _ubicacion = value,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _guardar,
                child: Text(widget.sucursal == null ? 'Guardar' : 'Actualizar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
