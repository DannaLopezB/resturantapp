import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/dish.dart';

class DishService {
  final String baseUrl = "http://localhost:8080/api/dishes";

  /// Crear un plato
  Future<Dish> create(Dish dish) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(dish.toJson()),
    );

    if (response.statusCode == 201) {
      return Dish.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al crear el plato: ${response.body}");
    }
  }

  /// Obtener todos los platos
  Future<List<Dish>> findAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Dish.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener los platos");
    }
  }

  /// Obtener platos activos
  Future<List<Dish>> findAllActive() async {
    final response = await http.get(Uri.parse("$baseUrl/active"));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Dish.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener platos activos");
    }
  }

  /// Buscar plato por ID
  Future<Dish> findById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return Dish.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Plato no encontrado");
    }
  }

  /// Buscar plato activo por ID
  Future<Dish> findActiveById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/active/$id"));

    if (response.statusCode == 200) {
      return Dish.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Plato activo no encontrado");
    }
  }

  /// Actualizar un plato
  Future<Dish> update(int id, Dish dish) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(dish.toJson()),
    );

    if (response.statusCode == 200) {
      return Dish.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al actualizar el plato");
    }
  }

  /// Eliminación lógica
  Future<void> logicalDelete(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/logical/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar lógicamente el plato");
    }
  }

  /// Eliminación física
  Future<void> physicalDelete(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/physical/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar físicamente el plato");
    }
  }

  /// Restaurar un plato
  Future<void> restore(int id) async {
    final response = await http.put(Uri.parse("$baseUrl/restore/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al restaurar el plato");
    }
  }
}
