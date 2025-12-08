class User {
  final int id;
  final String nombre;
  final String correo;
  final String rol;
  final String? token;

  User({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    nombre: json["nombre"],
    correo: json["correo"],
    rol: json["rol"],
    token: json["token"],
  );
}
