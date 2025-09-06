import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/drink.dart';

class DrinkService {
  final String baseUrl = "http://localhost:8080/api/drinks";

  Future<Drink> createDrink(Drink drink) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(drink.toJson()),
    );

    if (response.statusCode == 201) {
      return Drink.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al crear la bebida");
    }
  }

  Future<List<Drink>> getAllDrinks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Drink.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener las bebidas");
    }
  }

  Future<List<Drink>> getAllActiveDrinks() async {
    final response = await http.get(Uri.parse("$baseUrl/active"));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Drink.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener bebidas activas");
    }
  }

  Future<Drink> getDrinkById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return Drink.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al obtener la bebida con id $id");
    }
  }

  Future<Drink> updateDrink(int id, Drink drink) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(drink.toJson()),
    );

    if (response.statusCode == 200) {
      return Drink.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al actualizar la bebida con id $id");
    }
  }

  Future<void> logicalDeleteDrink(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/logical/$id"));

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar lógicamente la bebida con id $id");
    }
  }

  Future<void> physicalDeleteDrink(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/physical/$id"));

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar físicamente la bebida con id $id");
    }
  }

  Future<void> restoreDrink(int id) async {
    final response = await http.put(Uri.parse("$baseUrl/restore/$id"));

    if (response.statusCode != 204) {
      throw Exception("Error al restaurar la bebida con id $id");
    }
  }
}
