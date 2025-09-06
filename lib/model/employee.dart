class Employee {
  int? employeeId; // opcional al crear
  String name;
  String role;
  String phone;
  String status; // "A" activo, "I" inactivo

  Employee({
    this.employeeId,
    required this.name,
    required this.role,
    required this.phone,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'role': role,
      'phone': phone,
      'status': status,
    };
  }
}