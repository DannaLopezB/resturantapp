class OrderDetailDTO {
  int? detailId;
  int? dishId;
  int? drinkId;
  int quantity;
  double price;
  String? status;

  OrderDetailDTO({
    this.detailId,
    this.dishId,
    this.drinkId,
    required this.quantity,
    required this.price,
    this.status,
  });

  factory OrderDetailDTO.fromJson(Map<String, dynamic> json) {
    return OrderDetailDTO(
      detailId: json['detailId'],
      dishId: json['dishId'],
      drinkId: json['drinkId'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailId': detailId,
      'dishId': dishId,
      'drinkId': drinkId,
      'quantity': quantity,
      'price': price,
      'status': status,
    };
  }
}

class OrderRequestDTO {
  int tableNumber;
  int customerId;
  int employeeId;
  List<OrderDetailDTO> orderDetails;

  OrderRequestDTO({
    required this.tableNumber,
    required this.customerId,
    required this.employeeId,
    required this.orderDetails,
  });

  factory OrderRequestDTO.fromJson(Map<String, dynamic> json) {
    return OrderRequestDTO(
      tableNumber: json['tableNumber'],
      customerId: json['customerId'],
      employeeId: json['employeeId'],
      orderDetails: (json['orderDetails'] as List)
          .map((item) => OrderDetailDTO.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableNumber': tableNumber,
      'customerId': customerId,
      'employeeId': employeeId,
      'orderDetails': orderDetails.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderResponseDTO {
  int orderId;
  String orderDate;
  String orderTime;
  int tableNumber;
  int customerId;
  int employeeId;
  String status;
  List<OrderDetailDTO> orderDetails;

  OrderResponseDTO({
    required this.orderId,
    required this.orderDate,
    required this.orderTime,
    required this.tableNumber,
    required this.customerId,
    required this.employeeId,
    required this.status,
    required this.orderDetails,
  });

  factory OrderResponseDTO.fromJson(Map<String, dynamic> json) {
    return OrderResponseDTO(
      orderId: json['orderId'],
      orderDate: json['orderDate'],
      orderTime: json['orderTime'],
      tableNumber: json['tableNumber'],
      customerId: json['customerId'],
      employeeId: json['employeeId'],
      status: json['status'],
      orderDetails: (json['orderDetails'] as List)
          .map((item) => OrderDetailDTO.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderDate': orderDate,
      'orderTime': orderTime,
      'tableNumber': tableNumber,
      'customerId': customerId,
      'employeeId': employeeId,
      'status': status,
      'orderDetails': orderDetails.map((item) => item.toJson()).toList(),
    };
  }
}
