class Sucursal {
  final int? id;
  final String nombre;
  final String? ubicacion;

  Sucursal({
    this.id,
    required this.nombre,
    this.ubicacion,
  });

  // Convertir objeto a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'ubicacion': ubicacion,
    };
  }

  // Crear objeto desde un Map de SQLite
  factory Sucursal.fromMap(Map<String, dynamic> map) {
    return Sucursal(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      ubicacion: map['ubicacion'] as String?,
    );
  }
}
