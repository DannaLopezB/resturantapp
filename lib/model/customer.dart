class Customer {
  int customerId; // Ahora es obligatorio
  String name;
  String phone;
  String email;
  String status; // "A" activo, "I" inactivo, etc.

  Customer({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
    };
  }
}
