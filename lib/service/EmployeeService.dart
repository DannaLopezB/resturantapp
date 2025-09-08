import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class EmployeeService {
  final String baseUrl = "https://laughing-space-trout-9p9q95gqvrqf76jq-8088.app.github.dev/api/employees";

  Future<Employee> createEmployee(Employee employee) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(employee.toJson()),
    );

    if (response.statusCode == 201) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al crear el empleado");
    }
  }

  Future<List<Employee>> getAllEmployees() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener empleados");
    }
  }

  Future<List<Employee>> getAllActiveEmployees() async {
    final response = await http.get(Uri.parse("$baseUrl/active"));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener empleados activos");
    }
  }

  Future<Employee> getEmployeeById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al obtener el empleado con id $id");
    }
  }

  Future<Employee> updateEmployee(int id, Employee employee) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(employee.toJson()),
    );

    if (response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al actualizar el empleado con id $id");
    }
  }

  Future<void> logicalDeleteEmployee(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/logical/$id"));

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar lógicamente el empleado con id $id");
    }
  }

  Future<void> physicalDeleteEmployee(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/physical/$id"));

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar físicamente el empleado con id $id");
    }
  }

  Future<void> restoreEmployee(int id) async {
    final response = await http.put(Uri.parse("$baseUrl/restore/$id"));

    if (response.statusCode != 204) {
      throw Exception("Error al restaurar el empleado con id $id");
    }
  }
}
