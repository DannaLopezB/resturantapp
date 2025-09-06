import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/payment.dart';

class PaymentService {
  final String baseUrl = "http://localhost:8080/api/payments";

  /// Crear un pago
  Future<Payment> create(Payment payment) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payment.toJson()),
    );

    if (response.statusCode == 201) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al crear el pago");
    }
  }

  /// Obtener todos los pagos
  Future<List<Payment>> findAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener pagos");
    }
  }

  /// Obtener pagos activos
  Future<List<Payment>> findAllActive() async {
    final response = await http.get(Uri.parse("$baseUrl/active"));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener pagos activos");
    }
  }

  /// Buscar pago por ID
  Future<Payment> findById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Pago con id $id no encontrado");
    }
  }

  /// Buscar pago activo por ID
  Future<Payment> findActiveById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/active/$id"));

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Pago activo con id $id no encontrado");
    }
  }

  /// Buscar pagos por ID de orden
  Future<List<Payment>> findByOrderId(int orderId) async {
    final response = await http.get(Uri.parse("$baseUrl/order/$orderId"));

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener pagos de la orden $orderId");
    }
  }

  /// Buscar pagos por método de pago
  Future<List<Payment>> findByPaymentMethod(String paymentMethod) async {
    final response = await http.get(
      Uri.parse("$baseUrl/method/$paymentMethod"),
    );

    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      return list.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception("Error al obtener pagos con método $paymentMethod");
    }
  }

  /// Actualizar un pago
  Future<Payment> update(int id, Payment payment) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payment.toJson()),
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al actualizar el pago $id");
    }
  }

  /// Eliminación lógica
  Future<void> logicalDelete(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/logical/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar lógicamente el pago $id");
    }
  }

  /// Eliminación física
  Future<void> physicalDelete(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/physical/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar físicamente el pago $id");
    }
  }

  /// Restaurar pago
  Future<void> restore(int id) async {
    final response = await http.put(Uri.parse("$baseUrl/restore/$id"));
    if (response.statusCode != 204) {
      throw Exception("Error al restaurar el pago $id");
    }
  }
}
