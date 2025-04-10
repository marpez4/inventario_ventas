import 'package:flutter/material.dart';
import '../models/sucursal.dart';
import '../services/sucursal_service.dart';

class SucursalProvider extends ChangeNotifier {
  final SucursalService _service = SucursalService();

  List<Sucursal> _sucursales = [];
  List<Sucursal> get sucursales => _sucursales;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> cargarSucursales() async {
    _isLoading = true;
    notifyListeners();

    _sucursales = await _service.getSucursales();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarSucursal(Sucursal sucursal) async {
    await _service.insertSucursal(sucursal);
    await cargarSucursales(); // Refrescar lista
  }

  Future<void> actualizarSucursal(Sucursal sucursal) async {
    await _service.updateSucursal(sucursal);
    await cargarSucursales();
  }

  Future<void> eliminarSucursal(int id) async {
    await _service.deleteSucursal(id);
    await cargarSucursales();
  }
}
