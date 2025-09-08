class Payment {
  int? paymentId; // opcional al crear
  int orderId; // referencia a la orden
  String paymentDate; // ISO date string: 'YYYY-MM-DD'
  String paymentTime; // ISO time string: 'HH:mm:ss'
  double amount; // BigDecimal -> double
  String paymentMethod; // Ejemplo: "Cash", "Card", "Yape", etc.
  String status; // "A" activo, "I" inactivo

  Payment({
    this.paymentId,
    required this.orderId,
    required this.paymentDate,
    required this.paymentTime,
    required this.amount,
    required this.paymentMethod,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      orderId: json['orderId'],
      paymentDate: json['paymentDate'],
      paymentTime: json['paymentTime'],
      amount: json['amount'].toDouble(),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'paymentDate': paymentDate,
      'paymentTime': paymentTime,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }
}