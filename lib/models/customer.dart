class Customer {
  int? customerId; // Opcional, porque al crear todavía no existe
  String name;
  String? lastname; // Nuevo campo opcional
  String phone;
  String email;
  String status; // "A" activo, "I" inactivo, etc.
  DateTime? registerDate; // Fecha de registro automática

  Customer({
    this.customerId,
    required this.name,
    this.lastname,
    required this.phone,
    required this.email,
    required this.status,
    this.registerDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? json['customer_id'],
      name: json['name'] ?? '',
      lastname: json['lastname'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'A',
      registerDate: json['registerDate'] != null 
          ? DateTime.parse(json['registerDate'])
          : json['register_date'] != null 
              ? DateTime.parse(json['register_date'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'name': name,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'status': status,
      'registerDate': registerDate?.toIso8601String(),
    };
  }

  // Método para obtener el nombre completo
  String get fullName {
    if (lastname != null && lastname!.isNotEmpty) {
      return '$name $lastname';
    }
    return name;
  }

  // Método para formatear la fecha de registro
  String get formattedRegisterDate {
    if (registerDate != null) {
      return '${registerDate!.day.toString().padLeft(2, '0')}/${registerDate!.month.toString().padLeft(2, '0')}/${registerDate!.year}';
    }
    return 'N/A';
  }
}