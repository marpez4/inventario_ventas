import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/usuario_service.dart';

class UsuarioForm extends StatefulWidget {
  final Usuario? usuario;
  final VoidCallback onSave;

  const UsuarioForm({super.key, this.usuario, required this.onSave});

  @override
  State<UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _correo;
  late String _contrasena;
  String _rol = 'vendedor';
  final _usuarioService = UsuarioService();

  @override
  void initState() {
    super.initState();
    _nombre = widget.usuario?.nombre ?? '';
    _correo = widget.usuario?.correo ?? '';
    _contrasena = widget.usuario?.contrasena ?? '';
    _rol = widget.usuario?.rol ?? 'vendedor';
  }

  void _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState?.save();

    final usuario = Usuario(
      id: widget.usuario?.id,
      nombre: _nombre,
      correo: _correo,
      contrasena: _contrasena,
      rol: _rol,
    );

    if (widget.usuario == null) {
      await _usuarioService.insertUsuario(usuario);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado exitosamente!')),
      );
    } else {
      await _usuarioService.updateUsuario(usuario);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado exitosamente!')),
      );
    }

    widget.onSave();
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
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
              onSaved: (v) => _nombre = v!,
            ),
            TextFormField(
              initialValue: _correo,
              decoration: const InputDecoration(labelText: 'Correo'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
              onSaved: (v) => _correo = v!,
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              initialValue: _contrasena,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
              onSaved: (v) => _contrasena = v!,
            ),
            DropdownButtonFormField<String>(
              value: _rol,
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
              ],
              decoration: const InputDecoration(labelText: 'Rol'),
              onChanged: (value) => setState(() => _rol = value!),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _guardar,
                child: Text(widget.usuario == null ? 'Guardar' : 'Actualizar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
