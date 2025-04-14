import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';

class ClienteProvider extends ChangeNotifier {
  final ClienteService _service = ClienteService();

  List<Cliente> _clientes = [];
  List<Cliente> get clientes => _clientes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> cargarClientes() async {
    _isLoading = true;
    notifyListeners();
    _clientes = await _service.getClientes();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarCliente(Cliente cliente) async {
    await _service.insertCliente(cliente);
    await cargarClientes();
  }

  Future<void> actualizarCliente(Cliente cliente) async {
    await _service.updateCliente(cliente);
    await cargarClientes();
  }

  Future<void> eliminarCliente(int id) async {
    await _service.deleteCliente(id);
    await cargarClientes();
  }
}
