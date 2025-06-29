import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final List<String>? partnerIds;
  final String preferredTime;
  final double deliveryQuantity;
  final String deliveryType;
  final bool notificationsOn;
  final DateTime createdAt;

  Customer({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.partnerIds,
    required this.preferredTime,
    required this.deliveryQuantity,
    required this.deliveryType,
    required this.notificationsOn,
    required this.createdAt,
  });

  factory Customer.fromJson(String uid, Map<String, dynamic> json) {
    return Customer(
      uid: uid,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      partnerIds: (json['partnerIds'] as List<dynamic>?)?.map((id) => id as String).toList(), // Handle list
      preferredTime: json['preferredTime'],
      deliveryQuantity: (json['deliveryQuantity'] ?? 0).toDouble(),
      deliveryType: json['deliveryType'],
      notificationsOn: json['notificationsOn'] ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'partnerIds': partnerIds,
      'preferredTime': preferredTime,
      'deliveryQuantity': deliveryQuantity,
      'deliveryType': deliveryType,
      'notificationsOn': notificationsOn,
      'createdAt': createdAt,
    };
  }
}