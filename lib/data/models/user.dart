class User {
  final int id;
  final int idConsumidor;
  final String nombre;
  final String correo;
  final String rol;

  User({
    required this.id,
    required this.idConsumidor,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    idConsumidor: json["idConsumidor"],
    nombre: json["nombre"],
    correo: json["correo"],
    rol: json["rol"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "idConsumidor": idConsumidor,
    "nombre": nombre,
    "correo": correo,
    "rol": rol,
  };
}
