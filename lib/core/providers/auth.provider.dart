import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';

class AuthProvider extends ChangeNotifier {
  final UsuarioService _service = UsuarioService();
  Usuario? _usuarioActual;

  Usuario? get usuarioActual => _usuarioActual;
  bool get estaAutenticado => _usuarioActual != null;
  bool get esAdmin => _usuarioActual?.rol == 'admin';

  Future<bool> login(String correo, String contrasena) async {
    final usuario = await _service.login(correo, contrasena);
    if (usuario != null) {
      _usuarioActual = usuario;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _usuarioActual = null;
    notifyListeners();
  }
}
