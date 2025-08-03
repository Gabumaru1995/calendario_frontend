import 'canton.dart';

class Provincia {
  final int id;
  final String nombre;
  final List<Canton> cantones;

  Provincia({required this.id, required this.nombre, required this.cantones});

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(
      id: json['id'],
      nombre: json['nombre'],
      cantones: json['cantones'] != null
          ? List<Canton>.from(
              (json['cantones'] as List).map((c) => Canton.fromJson(c)))
          : [],
    );
  }
}
