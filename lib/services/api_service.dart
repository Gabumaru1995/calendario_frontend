import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/provincia.dart';
import '../models/canton.dart';
import '../models/festividad.dart';
import '../models/recordatorio.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8080'; // cambia si estás en emulador o red real

  Future<List<Canton>> obtenerCantones() async {
    final response = await http.get(Uri.parse('$baseUrl/cantones'));

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(utf8Body);
      return data.map((json) => Canton.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar cantones');
    }
  }

  Future<List<Festividad>> obtenerFestividadesPorCanton(int cantonId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/festividades/canton/$cantonId'));

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(utf8Body);
      return data.map((json) => Festividad.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar festividades');
    }
  }

  Future<List<Festividad>> buscarFestividades(String nombre) async {
    final response = await http.get(Uri.parse('$baseUrl/api/festividades/buscar?nombre=$nombre'));

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(utf8Body);
      return data.map((json) => Festividad.fromJson(json)).toList();
    } else {
      throw Exception('Error al buscar festividades');
    }
  }

  Future<List<Festividad>> obtenerFestividades() async {
    final response = await http.get(Uri.parse('$baseUrl/api/festividades'));

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(utf8Body);
      return data.map((json) => Festividad.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar festividades');
    }
  }

  Future<void> crearRecordatorio({
    String? titulo,
    String? mensaje,
    required String fechaHora,
    int? festividadId,
  }) async {
    final body = {
      'titulo': titulo,
      'mensaje': mensaje,
      'fechaHora': fechaHora,
      if (festividadId != null) 'festividadId': festividadId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/recordatorios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear recordatorio');
    }
  }

  Future<List<Recordatorio>> obtenerRecordatorios() async {
    final response = await http.get(Uri.parse('$baseUrl/recordatorios'));

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(utf8Body);
      return data.map((json) => Recordatorio.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar recordatorios');
    }
  }

  Future<void> actualizarRecordatorio(Recordatorio recordatorio) async {
    final response = await http.put(
      Uri.parse('$baseUrl/recordatorios/${recordatorio.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(recordatorio.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el recordatorio');
    }
  }

  Future<void> eliminarRecordatorio(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/recordatorios/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el recordatorio');
    }
  }
}
