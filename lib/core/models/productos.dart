class Producto {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int stock;
  final int idSucursal; // Identificador de la sucursal asociada

  Producto({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    required this.idSucursal,
  });

  // Convierte el objeto en un Map para guardarlo en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'id_sucursal': idSucursal,
    };
  }

  // Se crea un objeto Producto a partir de un Map
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
      // Se hace una conversión para manejar si se devuelve un int en lugar de double
      precio: map['precio'] is int ? (map['precio'] as int).toDouble() : map['precio'] as double,
      stock: map['stock'],
      idSucursal: map['id_sucursal'],
    );
  }
}
