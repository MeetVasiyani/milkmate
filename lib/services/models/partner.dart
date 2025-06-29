import 'package:cloud_firestore/cloud_firestore.dart';

class Partner {
  final String id;
  final String name;
  final String shopName;
  final String phone;
  final String address;
  final String city;
  final List<String> deliveryAreas;
  final double pricingPerLiter;
  final bool isVerified;
  final DateTime createdAt;

  Partner({
    required this.id,
    required this.name,
    required this.shopName,
    required this.phone,
    required this.address,
    required this.city,
    required this.deliveryAreas,
    required this.pricingPerLiter,
    required this.isVerified,
    required this.createdAt,
  });

  factory Partner.fromJson(String id, Map<String, dynamic> json) {
    return Partner(
      id: id,
      name: json['name'],
      shopName: json['shopName'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      deliveryAreas: List<String>.from(json['deliveryAreas'] ?? []),
      pricingPerLiter: (json['pricingPerLiter'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shopName': shopName,
      'phone': phone,
      'address': address,
      'city': city,
      'deliveryAreas': deliveryAreas,
      'pricingPerLiter': pricingPerLiter,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
  }
}
