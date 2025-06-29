import 'package:cloud_firestore/cloud_firestore.dart';

class Delivery {
  final String id;
  final String customerId;
  final String partnerId;
  final DateTime date;
  final double quantity;
  final bool delivered;
  final String? notes;
  final DateTime timestamp;

  Delivery({
    required this.id,
    required this.customerId,
    required this.partnerId,
    required this.date,
    required this.quantity,
    required this.delivered,
    this.notes,
    required this.timestamp,
  });

  factory Delivery.fromJson(String id, Map<String, dynamic> json) {
    return Delivery(
      id: id,
      customerId: json['customerId'],
      partnerId: json['partnerId'],
      date: (json['date'] as Timestamp).toDate(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      delivered: json['delivered'] ?? false,
      notes: json['notes'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'partnerId': partnerId,
      'date': date,
      'quantity': quantity,
      'delivered': delivered,
      'notes': notes,
      'timestamp': timestamp,
    };
  }
}
