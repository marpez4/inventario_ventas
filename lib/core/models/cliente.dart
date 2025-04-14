class Cliente {
  final int? id;
  final String nombre;
  final String correo;

  Cliente({
    this.id,
    required this.nombre,
    required this.correo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nombre: map['nombre'],
      correo: map['correo'],
    );
  }
}
