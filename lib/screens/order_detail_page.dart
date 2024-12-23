// order_details_page.dart
import 'package:flutter/material.dart';
import 'package:tobacCoSellers/const/colors.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const OrderDetailsPage({
    Key? key, 
    required this.orderData, 
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        title: const Text(
          'Order Details',
          style: TextStyle(color: AppColor.secondary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.secondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(orderData['product_image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Product Details
              _buildSection(
                'Product Details',
                [
                  _buildDetailRow('Product Name', orderData['product_name']),
                  _buildDetailRow('Size', orderData['size']),
                  _buildDetailRow('Quantity', orderData['quantity'].toString()),
                  _buildDetailRow('Price per unit', '₹${orderData['price_per_unit']}'),
                  _buildDetailRow('Total Price', '₹${orderData['total_price']}'),
                ],
              ),
              const SizedBox(height: 16),
              // Order Information
              _buildSection(
                'Order Information',
                [
                  _buildDetailRow('Order ID', orderData['order_id']),
                  _buildDetailRow('Order Date', orderData['order_date'].toDate().toString().split('.')[0]),
                  _buildDetailRow('Status', orderData['status'].toUpperCase(),
                    valueColor: orderData['status'] == 'success' ? Colors.green : Colors.orange),
                ],
              ),
              const SizedBox(height: 16),
              // Payment Details
              _buildSection(
                'Payment Details',
                [
                  _buildDetailRow('Payment ID', orderData['payment_id']),
                  _buildDetailRow('Payment Status', orderData['payment_status']),
                  _buildDetailRow('Payment Date', 
                    orderData['payment_date'].toDate().toString().split('.')[0]),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.secondary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColor.accent,
            ),
          ),
          Flexible(
            child: Text(
              value.length > 20 ? '${value.substring(0, 20)}...' : value,
              style: TextStyle(
                color: valueColor ?? AppColor.secondary,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}