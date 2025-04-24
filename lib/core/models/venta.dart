class Venta {
  final int? id;
  final String fecha; // en formato ISO (ej. 2025-04-14 16:20)
  final int? idCliente;
  final int idSucursal;
  final String metodoPago;
  final double total;

  Venta({
    this.id,
    required this.fecha,
    this.idCliente,
    required this.idSucursal,
    required this.metodoPago,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'id_cliente': idCliente,
      'id_sucursal': idSucursal,
      'metodo_pago': metodoPago,
      'total': total,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map['id'],
      fecha: map['fecha'],
      idCliente: map['id_cliente'],
      idSucursal: map['id_sucursal'],
      metodoPago: map['metodo_pago'],
      total: map['total'] is int
          ? (map['total'] as int).toDouble()
          : map['total'] as double,
    );
  }
}
