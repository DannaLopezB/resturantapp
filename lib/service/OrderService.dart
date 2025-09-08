import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order.dart'; // Aquí ya están tus DTOs definidos en este mismo archivo

class OrderService {
  final String baseUrl = "https://laughing-space-trout-9p9q95gqvrqf76jq-8088.app.github.dev/api/orders";

  /// Crear nueva orden
  Future<OrderResponseDTO> createOrder(OrderRequestDTO orderRequest) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(orderRequest.toJson()),
    );

    if (response.statusCode == 201) {
      return OrderResponseDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al crear la orden");
    }
  }

  /// Obtener orden por ID
  Future<OrderResponseDTO> getOrderById(int orderId) async {
    final response = await http.get(Uri.parse("$baseUrl/$orderId"));

    if (response.statusCode == 200) {
      return OrderResponseDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Orden con id $orderId no encontrada");
    }
  }

  /// Obtener todas las órdenes
  Future<List<OrderResponseDTO>> getAllOrders() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => OrderResponseDTO.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener las órdenes");
    }
  }

  /// Obtener órdenes por cliente
  Future<List<OrderResponseDTO>> getOrdersByCustomer(int customerId) async {
    final response = await http.get(Uri.parse("$baseUrl/customer/$customerId"));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => OrderResponseDTO.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener órdenes del cliente $customerId");
    }
  }

  /// Obtener órdenes por empleado
  Future<List<OrderResponseDTO>> getOrdersByEmployee(int employeeId) async {
    final response = await http.get(Uri.parse("$baseUrl/employee/$employeeId"));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => OrderResponseDTO.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener órdenes del empleado $employeeId");
    }
  }

  /// Actualizar detalles de una orden
  Future<OrderResponseDTO> updateOrderDetails(
      int orderId, List<OrderDetailDTO> details) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$orderId/details"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(details.map((d) => d.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      return OrderResponseDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al actualizar detalles de la orden $orderId");
    }
  }

  /// Eliminar lógicamente una orden
  Future<void> deleteOrder(int orderId) async {
    final response = await http.delete(Uri.parse("$baseUrl/$orderId"));

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar la orden $orderId");
    }
  }

  /// Restaurar una orden
  Future<void> restoreOrder(int orderId) async {
    final response = await http.put(Uri.parse("$baseUrl/$orderId/restore"));

    if (response.statusCode != 200) {
      throw Exception("Error al restaurar la orden $orderId");
    }
  }
}
