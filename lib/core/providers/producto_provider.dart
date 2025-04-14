import 'package:flutter/material.dart';
import '../models/productos.dart';
import '../services/producto_service.dart';


class ProductoProvider extends ChangeNotifier {
  final ProductoService _service = ProductoService();

  List<Producto> _productos = [];
  List<Producto> get productos => _productos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> cargarProductos() async {
    _isLoading = true;
    notifyListeners();
    _productos = await _service.getProductos();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarProducto(Producto producto) async {
    await _service.insertProducto(producto);
    await cargarProductos();
  }

  Future<void> actualizarProducto(Producto producto) async {
    await _service.updateProducto(producto);
    await cargarProductos();
  }

  Future<void> eliminarProducto(int id) async {
    await _service.deleteProducto(id);
    await cargarProductos();
  }
}
