import 'package:flutter/material.dart';
import 'package:milkmate/screens/customer/customer_profile_setup_screen.dart';
import 'package:milkmate/screens/partner/partner_profile_setup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milkmate/services/models/partner.dart';
import 'package:milkmate/services/models/customer.dart';

import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isCustomer = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _navigateToCustomerHome(Customer customer) async {
    Navigator.pushReplacementNamed(
      context,
      '/customer-home',
      arguments: customer,
    );
  }

  Future<void> _navigateToPartnerHome() async {
    Navigator.pushReplacementNamed(context, '/partner-home');
  }

  Future<void> _updateCustomerAddress(
    String uid,
    Map<String, String> data,
  ) async {
    await FirebaseFirestore.instance.collection('customers').doc(uid).update({
      'address': data['address'],
      'city': data['city'],
    });
  }

  Future<void> _handleCustomerProfile(Customer customer, String uid) async {
    if (customer.address.isEmpty || customer.city.isEmpty) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerProfileSetupScreen(customer: customer),
        ),
      );
      if (result is Map<String, String>) {
        await _updateCustomerAddress(customer.uid, result);
        final updatedCustomer = await _authService.getCustomerData(uid);
        if (updatedCustomer != null) {
          await _navigateToCustomerHome(updatedCustomer);
        }
      } else {
        await _navigateToCustomerHome(customer);
      }
    } else {
      await _navigateToCustomerHome(customer);
    }
  }

  Future<void> _handlePartnerProfile(Partner partner) async {
    if (partner.address.isEmpty ||
        partner.city.isEmpty ||
        partner.deliveryAreas.isEmpty) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PartnerProfileSetupScreen(partner: partner),
        ),
      );
    } else {
      await _navigateToPartnerHome();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (isLogin) {
        final user = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (user != null) {
          final userType = await _authService.getUserType(user.uid);
          if (mounted) {
            if (userType == 'customer') {
              final customer = await _authService.getCustomerData(user.uid);
              if (customer != null) {
                await _handleCustomerProfile(customer, user.uid);
              } else {
                setState(() => _error = 'Customer data not found.');
              }
            } else if (userType == 'partner') {
              final partner = await _authService.getPartnerData(user.uid);
              if (partner != null) {
                await _handlePartnerProfile(partner);
              } else {
                setState(() => _error = 'Partner data not found.');
              }
            } else {
              setState(
                () => _error = 'User type not found. Please contact support.',
              );
            }
          }
        }
      } else {
        if (isCustomer) {
          final user = await _authService.registerCustomer(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );

          if (user != null && mounted) {
            final customer = await _authService.getCustomerData(user.uid);
            if (customer != null) {
              await _handleCustomerProfile(customer, user.uid);
            }
          }
        } else {
          final user = await _authService.registerPartner(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            businessName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
          );

          if (user != null && mounted) {
            final partner = await _authService.getPartnerData(user.uid);
            if (partner != null) {
              await _handlePartnerProfile(partner);
            }
          }
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your email first');
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      setState(() => _error = 'Password reset email sent!');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/img_login_screen_background.png', // Update with your image path
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
                    SizedBox(height: 32),
                    _buildUserTypeSelector(),
                    SizedBox(height: 24),
                    _buildAuthToggle(),
                    SizedBox(height: 24),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _error!.contains('sent!')
                                    ? Icons.check_circle
                                    : Icons.error_outline,
                                color:
                                    _error!.contains('sent!')
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    _buildForm(),
                    SizedBox(height: 24),
                    _buildSubmitButton(),
                    if (isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: Text('Forgot Password?',style: TextStyle(
                            color: Colors.white,
                          ),),
                        ),
                      ),
                    SizedBox(height: 24),
                    _buildSwitchText(),
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
          child: Icon(Icons.local_drink, size: 40, color: Color(0xFF4A90E2)),
        ),
        SizedBox(height: 16),
        Text(
          'MilkMate',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A90E2),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Fresh milk, delivered daily',
          style: TextStyle(color: Colors.white, fontSize: 18,shadows: [ Shadow(blurRadius: 8.0,color: Colors.blueAccent,offset: Offset(0, 0),),
              ],),
        ),
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isCustomer = true),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isCustomer ? Color(0xFF4A90E2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Customer',
                  style: TextStyle(
                    color: isCustomer ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isCustomer = false),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !isCustomer ? Color(0xFF4A90E2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Partner',
                  style: TextStyle(
                    color: !isCustomer ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => isLogin = true),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isLogin ? Color(0xFF1976D2) : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isLogin ? Colors.white : Colors.black54,
                shadows:
                    isLogin
                        ? [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.blueAccent,
                            offset: Offset(0, 0),
                          ),
                        ]
                        : [],
              ),
            ),
          ),
        ),
        SizedBox(width: 32),
        GestureDetector(
          onTap: () => setState(() => isLogin = false),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: !isLogin ? Color(0xFF1976D2) : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: !isLogin ? Colors.white : Colors.black54,
                shadows:
                    !isLogin
                        ? [
                          Shadow(
                            blurRadius: 8.0,
                            color: Colors.blueAccent,
                            offset: Offset(0, 0),
                          ),
                        ]
                        : [],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!isLogin)
            _buildTextField(
              controller: _nameController,
              label: isCustomer ? 'Full Name' : 'Business Name',
              icon: isCustomer ? Icons.person_outline : Icons.business_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isCustomer
                      ? 'Please enter your full name'
                      : 'Please enter your business name';
                }
                return null;
              },
            ),
          if (!isLogin) SizedBox(height: 16),
          if (!isLogin)
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          if (!isLogin) SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF4A90E2)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                  isLogin ? 'Login' : 'Create Account',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
      ),
    );
  }

  Widget _buildSwitchText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(isLogin ? "Don't have an account? " : "Already have an account? "),
        GestureDetector(
          onTap: () => setState(() => isLogin = !isLogin),
          child: Text(
            isLogin ? 'Sign up' : 'Login',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 8.0,
                  color: Colors.blueAccent,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
