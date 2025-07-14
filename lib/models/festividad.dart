class Festividad {
  final int id;
  final String nombre;
  final String descripcion;
  final String fecha;

  Festividad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
  });

  factory Festividad.fromJson(Map<String, dynamic> json) {
    return Festividad(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      fecha: json['fecha'],
    );
  }
}
