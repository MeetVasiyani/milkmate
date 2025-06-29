import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String customerId;
  final String partnerId;
  final double amount;
  final String status;
  final String method;
  final DateTime dueDate;
  final DateTime? paidAt;

  Payment({
    required this.id,
    required this.customerId,
    required this.partnerId,
    required this.amount,
    required this.status,
    required this.method,
    required this.dueDate,
    this.paidAt,
  });

  factory Payment.fromJson(String id, Map<String, dynamic> json) {
    return Payment(
      id: id,
      customerId: json['customerId'],
      partnerId: json['partnerId'],
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'],
      method: json['method'],
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      paidAt: json['paidAt'] != null ? (json['paidAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'partnerId': partnerId,
      'amount': amount,
      'status': status,
      'method': method,
      'dueDate': dueDate,
      'paidAt': paidAt,
    };
  }
}
