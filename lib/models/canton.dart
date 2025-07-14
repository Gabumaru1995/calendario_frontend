class Canton {
  final int id;
  final String nombre;

  Canton({required this.id, required this.nombre});

  factory Canton.fromJson(Map<String, dynamic> json) {
    return Canton(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
