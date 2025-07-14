class Recordatorio {
  final int id;
  final String? titulo;
  final String? mensaje;
  final String fechaHora;

  Recordatorio({
    required this.id,
    this.titulo,
    this.mensaje,
    required this.fechaHora,
  });

  factory Recordatorio.fromJson(Map<String, dynamic> json) {
    return Recordatorio(
      id: json['id'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      fechaHora: json['fechaHora'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "titulo": titulo,
      "mensaje": mensaje,
      "fechaHora": fechaHora,
    };
  }
}
