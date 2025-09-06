class Dish {
  int? dishId; // opcional al crear
  String name;
  String description;
  double price; // BigDecimal -> double en Dart
  String status; // "A" activo, "I" inactivo, etc.

  Dish({
    this.dishId,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      dishId: json['dishId'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dishId': dishId,
      'name': name,
      'description': description,
      'price': price,
      'status': status,
    };
  }
}