class Employee {
  int? employeeId; // opcional al crear
  String name;
  String lastname; // Campo faltante
  String role;
  String phone;
  DateTime? registerDate; // Campo faltante - opcional porque se asigna automáticamente
  String status; // "A" activo, "I" inactivo

  Employee({
    this.employeeId,
    required this.name,
    required this.lastname, // Ahora requerido
    required this.role,
    required this.phone,
    this.registerDate, // Opcional porque se asigna en la BD
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employee_id'], // Nota: coincide con el nombre de columna SQL
      name: json['name'],
      lastname: json['lastname'], // Campo agregado
      role: json['role'],
      phone: json['phone'],
      registerDate: json['register_date'] != null 
          ? DateTime.parse(json['register_date']) 
          : null, // Campo agregado con parsing de fecha
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId, // Coincide con el nombre de columna SQL
      'name': name,
      'lastname': lastname, // Campo agregado
      'role': role,
      'phone': phone,
      'register_date': registerDate?.toIso8601String(), // Campo agregado con formato ISO
      'status': status,
    };
  }

  // Método adicional útil para crear un empleado nuevo (sin ID ni fecha)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'name': name,
      'lastname': lastname,
      'role': role,
      'phone': phone,
      'status': status,
      // No incluimos employee_id ni register_date porque se generan automáticamente
    };
  }

  @override
  String toString() {
    return 'Employee{employeeId: $employeeId, name: $name, lastname: $lastname, role: $role, phone: $phone, registerDate: $registerDate, status: $status}';
  }
}