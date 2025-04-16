import 'package:flutter/material.dart';
import 'package:inventario_ventas/core/ui/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../providers/auth.provider.dart';
import '../../services/usuario_service.dart';
import '../widgets/usuario_form.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final _usuarioService = UsuarioService();
  List<Usuario> _usuarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final data = await _usuarioService.getUsuarios();
    setState(() {
      _usuarios = data;
      _cargando = false;
    });
  }

  Future<void> _eliminar(int id) async {
    await _usuarioService.deleteUsuario(id);
    _cargarUsuarios();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
       appBar: const CustomAppBar(titulo: 'Usuarios'),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? const Center(child: Text('No hay usuarios registrados'))
              : ListView.builder(
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final u = _usuarios[index];
                    return ListTile(
                      title: Text(u.nombre),
                      subtitle: Text('${u.correo} • Rol: ${u.rol}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) =>
                                    UsuarioForm(usuario: u, onSave: _cargarUsuarios),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Eliminar usuario'),
                                  content: const Text(
                                      '¿Estás seguro de eliminar este usuario?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancelar'),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                    TextButton(
                                      child: const Text('Eliminar'),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) _eliminar(u.id!);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => UsuarioForm(onSave: _cargarUsuarios),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
