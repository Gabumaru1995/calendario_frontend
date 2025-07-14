class Provincia {
  final int id;
  final String nombre;

  Provincia({required this.id, required this.nombre});

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
