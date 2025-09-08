import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

class CustomerService {
  final String baseUrl =
      "https://laughing-space-trout-9p9q95gqvrqf76jq-8088.app.github.dev/api/customers";

  /// Crear un cliente
  Future<Customer> create(Customer customer) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode == 201) {
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al crear cliente: ${response.body}");
    }
  }

  /// Obtener todos los clientes
  Future<List<Customer>> findAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener clientes");
    }
  }

  /// Obtener clientes activos
  Future<List<Customer>> findAllActive() async {
    final response = await http.get(Uri.parse("$baseUrl/active"));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener clientes activos");
    }
  }

  /// Buscar cliente por ID
  Future<Customer> findById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Cliente no encontrado");
    }
  }

  /// Buscar cliente activo por ID
  Future<Customer> findActiveById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/active/$id"));

    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Cliente activo no encontrado");
    }
  }

  /// Actualizar cliente
  Future<Customer> update(int id, Customer customer) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(customer.toJson()),
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al actualizar cliente");
    }
  }

  /// Eliminación lógica
  Future<void> logicalDelete(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/logical/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar lógicamente el cliente");
    }
  }

  /// Eliminación física
  Future<void> physicalDelete(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/physical/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar físicamente el cliente");
    }
  }

  /// Restaurar cliente
  Future<void> restore(int id) async {
    final response = await http.put(Uri.parse("$baseUrl/restore/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al restaurar el cliente");
    }
  }
}
