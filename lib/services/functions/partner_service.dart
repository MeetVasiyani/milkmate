import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milkmate/services/models/partner.dart';

class PartnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get partners from user's city
  Future<List<Partner>> getPartnersByCity(String city) async {
    try {
      final querySnapshot = await _firestore
          .collection('partners')
          .where('city', isEqualTo: city)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Partner.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch partners: $e');
    }
  }

  // Get all partners (for "see other" option)
  Future<List<Partner>> getAllPartners() async {
    try {
      final querySnapshot = await _firestore
          .collection('partners')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Partner.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all partners: $e');
    }
  }

  // Search partners by name or address
  List<Partner> searchPartners(List<Partner> partners, String query) {
    if (query.isEmpty) return partners;
    
    final lowercaseQuery = query.toLowerCase();
    return partners.where((partner) {
      return partner.name.toLowerCase().contains(lowercaseQuery) ||
             partner.address.toLowerCase().contains(lowercaseQuery) ||
             partner.shopName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}