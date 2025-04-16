import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _correo = '';
  String _contrasena = '';
  bool _cargando = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _cargando = true);
    final auth = context.read<AuthProvider>();
    final exito = await auth.login(_correo, _contrasena);

    setState(() => _cargando = false);

    if (exito) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(24, 64, 24, bottom + 24),
        child: Form(
          key: _formKey,
          child: Wrap(
            runSpacing: 16,
            children: [
              const Text(
                'Iniciar Sesión',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese su correo' : null,
                onSaved: (v) => _correo = v!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingrese su contraseña' : null,
                onSaved: (v) => _contrasena = v!,
              ),
              _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(
                      onPressed: _login,
                      child: const Text('Ingresar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
