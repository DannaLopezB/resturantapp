class Drink {
  int? drinkId;
  String name;
  String description;
  double price;
  String status;

  Drink({
    this.drinkId,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      drinkId: json['drinkId'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drinkId': drinkId,
      'name': name,
      'description': description,
      'price': price,
      'status': status,
    };
  }
}