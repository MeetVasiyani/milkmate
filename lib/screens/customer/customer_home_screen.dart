import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:milkmate/services/models/customer.dart';
import 'package:milkmate/services/models/delivery.dart';
import 'package:milkmate/services/models/payment.dart';
import 'package:milkmate/screens/manage_partners_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  final Customer customer;
  final List<Delivery> recentDeliveries;
  final List<Payment> pendingPayments;
  final VoidCallback? onProfileTap;
  final VoidCallback? onDeliveryHistoryTap;
  final VoidCallback? onPaymentsTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onSettingsTap;

  const CustomerHomeScreen({
    super.key,
    required this.customer,
    this.recentDeliveries = const [],
    this.pendingPayments = const [],
    this.onProfileTap,
    this.onDeliveryHistoryTap,
    this.onPaymentsTap,
    this.onNotificationsTap,
    this.onSettingsTap,
  });

  void _onManagePartnersTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagePartnersScreen(
          userCity: customer.city,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Hello, ${customer.name.split(' ').first}!',
          style: GoogleFonts.poppins(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationsTap,
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
              ),
              if (customer.notificationsOn)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: onProfileTap,
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Cards
            _buildQuickStatsSection(),
            const SizedBox(height: 20),
            
            // Current Delivery Info
            _buildCurrentDeliveryCard(),
            const SizedBox(height: 20),
            
            // Recent Activity
            _buildRecentActivitySection(),
            const SizedBox(height: 20),
            
            // Quick Actions
            _buildQuickActionsSection(context),
            const SizedBox(height: 20),
            
            // Pending Payments
            if (pendingPayments.isNotEmpty) ...[
              _buildPendingPaymentsSection(),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Daily Quantity',
            value: customer.deliveryQuantity == 0.0 ? 'N/A' : '${customer.deliveryQuantity}L',
            icon: Icons.local_drink,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Delivery Time',
            value: customer.preferredTime == '' ? 'N/A' : customer.preferredTime,
            icon: Icons.schedule,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Frequency',
            value: customer.deliveryType == '' ? 'N/A' : customer.deliveryType,
            icon: Icons.repeat,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 125, // Fixed height for consistency
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDeliveryCard() {
    final nextDelivery = recentDeliveries.isNotEmpty 
        ? recentDeliveries.first 
        : null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Delivery',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  nextDelivery?.delivered == true ? 'Delivered' : 'Scheduled',
                  style: GoogleFonts.poppins(
                    color: Colors.blue[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nextDelivery != null 
                ? 'Today at ${customer.preferredTime}'
                : 'Today at ${customer.preferredTime}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${customer.deliveryQuantity}L - ${customer.deliveryType}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: onDeliveryHistoryTap,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentDeliveries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.local_shipping_outlined, 
                     size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'No recent deliveries',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          ...recentDeliveries.take(3).map((delivery) => 
            _buildActivityItem(delivery)).toList(),
      ],
    );
  }

  Widget _buildActivityItem(Delivery delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: delivery.delivered ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              delivery.delivered ? Icons.check_circle : Icons.schedule,
              color: delivery.delivered ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.delivered ? 'Delivery Completed' : 'Delivery Scheduled',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${delivery.quantity}L - ${_formatDate(delivery.date)}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'Manage Partners',
                icon: Icons.store,
                onTap: () => _onManagePartnersTap(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: 'Payments',
                icon: Icons.payment,
                onTap: onPaymentsTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'Delivery History',
                icon: Icons.history,
                onTap: onDeliveryHistoryTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: 'Settings',
                icon: Icons.settings,
                onTap: onSettingsTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue[600]),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPaymentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Payments',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: onPaymentsTap,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...pendingPayments.take(2).map((payment) => 
          _buildPaymentItem(payment)).toList(),
      ],
    );
  }

  Widget _buildPaymentItem(Payment payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Due',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.red[800],
                  ),
                ),
                Text(
                  '₹${payment.amount.toStringAsFixed(2)} - Due ${_formatDate(payment.dueDate)}',
                  style: GoogleFonts.poppins(
                    color: Colors.red[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
                      Text(
            payment.status.toUpperCase(),
            style: GoogleFonts.poppins(
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1) return 'In $difference days';
    if (difference < -1) return '${-difference} days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}