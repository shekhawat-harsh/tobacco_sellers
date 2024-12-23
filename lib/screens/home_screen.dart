import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tobacCoSellers/const/colors.dart';
import 'package:tobacCoSellers/const/shared_preferences.dart';
import 'package:tobacCoSellers/screens/order_detail_page.dart';
import 'package:tobacCoSellers/screens/add_item.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? sellerEmail;
  final Set<String> selectedOrders = {};
  bool isLoading = false;
  String? _selectedDispatchTime;

  @override
  void initState() {
    super.initState();
    _loadSellerEmail();
  }

  Future<void> _loadSellerEmail() async {
    final prefs = SharedPreferenceHelper();
    final email = prefs.getEmail();
    setState(() {
      sellerEmail = email;
    });
  }

  Future<void> _createDispatchBatch() async {
    if (selectedOrders.isEmpty || _selectedDispatchTime == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Fetch orders using order_id field
      final orderQueries = await Future.wait(
        selectedOrders.map((orderId) => 
          FirebaseFirestore.instance
              .collection('orders')
              .where('order_id', isEqualTo: orderId)
              .limit(1)
              .get()
        ),
      );

      final orderDocs = orderQueries
          .where((query) => query.docs.isNotEmpty)
          .map((query) => query.docs.first)
          .toList();

      if (orderDocs.isEmpty) {
        throw Exception('No orders found');
      }

      // Create a new batch ID
      final batchId = Uuid().v4();

      // Create a new document in delivery_batches collection
      await FirebaseFirestore.instance.collection('delivery_batches').doc(batchId).set({
        'batch_id': batchId,
        'products': selectedOrders.toList(),
        'dispatch_schedule_time': _selectedDispatchTime,
      });

      // Update orders with dispatch information
      await Future.wait(
        orderDocs.map((orderDoc) =>
          orderDoc.reference.update({
            'status': 'ready for dispatch',
          })
        ),
      );

      setState(() {
        selectedOrders.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orders marked as ready for dispatch')),
        );
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    final orderData = order.data() as Map<String, dynamic>;
    final orderId = orderData['order_id']; // Changed from order.id to orderData['order_id']
    final hasDeliveryStatus = orderData.containsKey('status');
    final isPending = orderData['status'] == 'pending';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColor.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(orderData['product_image'], fit: BoxFit.cover, width: 80, height: 80),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderData['product_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order ID: ${orderData['order_id'].substring(0, 8)}...',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Status: ${orderData['status']}',
                            style: TextStyle(
                              color: orderData['status'] == 'success'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isPending)
                  Checkbox(
                    value: selectedOrders.contains(orderId),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedOrders.add(orderId);
                        } else {
                          selectedOrders.remove(orderId);
                        }
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.green;
                        }
                        return Colors.white.withOpacity(0.3);
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '₹${orderData['total_price']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sellerEmail == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColor.secondary,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Your Orders",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColor.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
              height: 1,
              width: double.infinity,
              color: AppColor.accent,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('seller_email', isEqualTo: sellerEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Something went wrong',
                        style: TextStyle(color: AppColor.secondary),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.secondary,
                      ),
                    );
                  }

                  final orders = snapshot.data!.docs;

                  if (orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'No orders yet',
                        style: TextStyle(color: AppColor.secondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) => _buildOrderCard(orders[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selectedOrders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FloatingActionButton.extended(
                onPressed: isLoading ? null : () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: const Text(
                          'Dispatch Schedule Time',
                          style: TextStyle(color: AppColor.secondary),
                        ),
                        content: DropdownButtonFormField<String>(
                          value: _selectedDispatchTime,
                          items: const [
                            DropdownMenuItem(value: 'Morning', child: Text('Before 12:00 PM')),
                            DropdownMenuItem(value: 'Afternoon', child: Text('12:00 PM - 5:00 PM')),
                            DropdownMenuItem(value: 'Evening', child: Text('After 5:00 PM')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedDispatchTime = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Select dispatch schedule time',
                            hintStyle: TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: AppColor.secondary.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: AppColor.primary,
                          style: const TextStyle(color: AppColor.secondary),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _createDispatchBatch();
                            },
                            child: const Text('Submit', style: TextStyle(color: AppColor.secondary)),
                          ),
                        ],
                      );
                    },
                  );
                },
                backgroundColor: AppColor.secondary,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                        ),
                      )
                    : const Icon(Icons.local_shipping, color: AppColor.primary),
                label: Text(
                  isLoading ? 'Creating Request...' : 'Ready for Dispatch',
                  style: const TextStyle(color: AppColor.primary),
                ),
              ),
            ),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItem()),
              );
            },
            backgroundColor: AppColor.secondary,
            icon: const Icon(Icons.add, color: AppColor.primary),
            label: const Text(
              'Add Product',
              style: TextStyle(color: AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }
}