import 'package:flutter/material.dart';
import 'package:milkmate/services/models/partner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milkmate/screens/partner/partner_home_screen.dart';

class PartnerProfileSetupScreen extends StatefulWidget {
  final Partner partner;
  const PartnerProfileSetupScreen({super.key, required this.partner});

  @override
  State<PartnerProfileSetupScreen> createState() => _PartnerProfileSetupScreenState();
}

class _PartnerProfileSetupScreenState extends State<PartnerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String? _selectedCity;
  String? _selectedDeliveryArea;
  bool _isLoading = false;
  String? _error;

  final Map<String, List<String>> _cityAreas = {
    'Jamnagar': ['Patel Colony', 'Indira Marg', 'Park Colony', 'Bedipara', 'Digvijay Plot'],
    'Rajkot': ['Kalavad Road', 'Race Course', 'University Road', 'Sadar', 'Mavdi'],
    'Ahemdabad': ['Navrangpura', 'Satellite', 'Bopal', 'Maninagar', 'Vastrapur'],
    'Surat': ['Adajan', 'Vesu', 'Katargam', 'Varachha', 'Athwa'],
    'Vadodra': ['Alkapuri', 'Gotri', 'Manjalpur', 'Akota', 'Karelibaug'],
  };

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.partner.address;
    _selectedCity = _cityAreas.keys.contains(widget.partner.city) ? widget.partner.city : null;
    _selectedDeliveryArea = (_selectedCity != null && _cityAreas[_selectedCity!]!.contains(widget.partner.deliveryAreas.isNotEmpty ? widget.partner.deliveryAreas.first : ''))
      ? widget.partner.deliveryAreas.first
      : null;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partner.id)
          .update({
        'address': _addressController.text.trim(),
        'city': _selectedCity,
        'deliveryAreas': [_selectedDeliveryArea],
      });
      final updatedDoc = await FirebaseFirestore.instance
          .collection('partners')
          .doc(widget.partner.id)
          .get();
      final updatedPartner = Partner.fromJson(widget.partner.id, updatedDoc.data()!);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerHomeScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/img_login_screen_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    _buildHeader(),
                    SizedBox(height: 40),
                    _buildWelcomeMessage(),
                    SizedBox(height: 32),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    _buildForm(),
                    SizedBox(height: 32),
                    _buildSubmitButton(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: Icon(Icons.store, size: 40, color: Color(0xFF4A90E2)),
        ),
        SizedBox(height: 16),
        Text(
          'Complete Partner Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A90E2),
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.blueAccent,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4A90E2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome, ${widget.partner.name}!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90E2),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Please complete your profile to start managing your deliveries',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Business Address',
              prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF4A90E2)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your business address';
              }
              if (value.trim().length < 10) {
                return 'Please enter a complete address';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            items: _cityAreas.keys.map((city) => DropdownMenuItem(
              value: city,
              child: Text(city),
            )).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCity = val;
                _selectedDeliveryArea = null;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select City',
              prefixIcon: Icon(Icons.location_city_outlined, color: Color(0xFF4A90E2)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Please select your city' : null,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedDeliveryArea,
            items: _selectedCity == null
                ? []
                : _cityAreas[_selectedCity!]!.map((area) => DropdownMenuItem(
                    value: area,
                    child: Text(area),
                  )).toList(),
            onChanged: (val) => setState(() => _selectedDeliveryArea = val),
            decoration: InputDecoration(
              labelText: 'Select Delivery Area',
              prefixIcon: Icon(Icons.map_outlined, color: Color(0xFF4A90E2)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Please select a delivery area' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Color(0xFF4A90E2),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
