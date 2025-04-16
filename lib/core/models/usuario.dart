class Usuario {
  final int? id;
  final String nombre;
  final String correo;
  final String contrasena;
  final String rol; // usuarios: 'admin' o 'vendedor'

  Usuario({
    this.id,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.rol,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
      'rol': rol,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      correo: map['correo'],
      contrasena: map['contrasena'],
      rol: map['rol'],
    );
  }
}
