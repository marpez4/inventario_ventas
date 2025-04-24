class DetalleVenta {
  final int? id;
  final int idVenta;
  final int idProducto;
  final int cantidad;
  final double precioUnitario;

  DetalleVenta({
    this.id,
    required this.idVenta,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_venta': idVenta,
      'id_producto': idProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
    };
  }

  factory DetalleVenta.fromMap(Map<String, dynamic> map) {
    return DetalleVenta(
      id: map['id'],
      idVenta: map['id_venta'],
      idProducto: map['id_producto'],
      cantidad: map['cantidad'],
      precioUnitario: map['precio_unitario'] is int
          ? (map['precio_unitario'] as int).toDouble()
          : map['precio_unitario'] as double,
    );
  }

  DetalleVenta copyWith({int? idVenta}) {
    return DetalleVenta(
      id: id,
      idVenta: idVenta ?? this.idVenta,
      idProducto: idProducto,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
    );
  }
}
