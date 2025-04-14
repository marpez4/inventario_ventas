import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';

class ClienteForm extends StatefulWidget {
  final Cliente? cliente;
  const ClienteForm({super.key, this.cliente});

  @override
  State<ClienteForm> createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _correo;

  @override
  void initState() {
    super.initState();
    _nombre = widget.cliente?.nombre ?? '';
    _correo = widget.cliente?.correo ?? '';
  }

  void _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState?.save();

    final nuevoCliente = Cliente(
      id: widget.cliente?.id,
      nombre: _nombre,
      correo: _correo,
    );

    final provider = context.read<ClienteProvider>();
    if (widget.cliente == null) {
      await provider.agregarCliente(nuevoCliente);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente agregado exitosamente!')),
      );
    } else {
      await provider.actualizarCliente(nuevoCliente);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente actualizado exitosamente!'))
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
              initialValue: _correo,
              decoration: const InputDecoration(labelText: 'Correo'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido';
                }
                if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$')
                    .hasMatch(value.trim())) {
                  return 'Correo inválido';
                }
                return null;
              },
              onSaved: (value) => _correo = value!,
              keyboardType: TextInputType.emailAddress,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _guardar,
                child:
                    Text(widget.cliente == null ? 'Guardar' : 'Actualizar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
