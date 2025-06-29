import 'package:flutter/material.dart';
import 'package:milkmate/services/models/customer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milkmate/screens/customer/customer_home_screen.dart';

class CustomerProfileSetupScreen extends StatefulWidget {
  final Customer customer;
  const CustomerProfileSetupScreen({super.key, required this.customer});

  @override
  State<CustomerProfileSetupScreen> createState() => _CustomerProfileSetupScreenState();
}

class _CustomerProfileSetupScreenState extends State<CustomerProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final List<String> _cities = [
    'Jamnagar',
    'Rajkot',
    'Ahemdabad',
    'Surat',
    'Vadodra',
  ];
  String? _selectedCity;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.customer.address;
    _selectedCity = _cities.contains(widget.customer.city) ? widget.customer.city : null;
    _notificationsEnabled = widget.customer.notificationsOn ?? true;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Save address, city, and notifications to Firestore
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customer.uid)
          .update({
        'address': _addressController.text.trim(),
        'city': _selectedCity,
        'notificationsOn': _notificationsEnabled,
      });
      // Fetch updated customer data (optional, for passing to home screen)
      final updatedDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customer.uid)
          .get();
      final updatedCustomer = Customer.fromJson(widget.customer.uid, updatedDoc.data()!);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerHomeScreen(customer: updatedCustomer),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image similar to auth screen
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
          child: Icon(Icons.person_pin_circle, size: 40, color: Color(0xFF4A90E2)),
        ),
        SizedBox(height: 16),
        Text(
          'Complete Profile',
          style: TextStyle(
            fontSize: 32,
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
            'Welcome, ${widget.customer.name}!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90E2),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Please complete your profile to start receiving fresh milk deliveries',
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
          _buildTextField(
            controller: _addressController,
            label: 'Delivery Address',
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your delivery address';
              }
              if (value.trim().length < 10) {
                return 'Please enter a complete address';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildCityDropdown(),
          SizedBox(height: 16),
          _buildNotificationsToggle(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: label.contains('Address') ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF4A90E2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF4A90E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF4A90E2), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      items: _cities.map((city) => DropdownMenuItem(
        value: city,
        child: Text(
          city,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      )).toList(),
      onChanged: (value) => setState(() => _selectedCity = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your city';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Select City',
        prefixIcon: Icon(Icons.location_city_outlined, color: Color(0xFF4A90E2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF4A90E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF4A90E2), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(color: Colors.grey[700]),
      ),
      dropdownColor: Colors.white,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
    );
  }

  Widget _buildNotificationsToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF4A90E2)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: Color(0xFF4A90E2)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enable Notifications',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            activeColor: Color(0xFF4A90E2),
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
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