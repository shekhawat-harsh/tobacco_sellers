import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tobacCoSellers/const/colors.dart';
import 'package:tobacCoSellers/utils/server/Firebase_store_fetch.dart';
import 'package:flutter/material.dart';
import 'package:tobacCoSellers/const/shared_preferences.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  FirestoreService firestoreService = FirestoreService();
  late List<Map<String, dynamic>> userProducts = [];
  late List<Map<String, dynamic>> userAuctions = [];
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _fetchUserProducts();
    _fetchUserAuctions();
  }

  Future<void> _loadUserEmail() async {
    final prefs = SharedPreferenceHelper();
    final email = prefs.getEmail();
    setState(() {
      userEmail = email;
    });
  }

  Future<void> _fetchUserProducts() async {
    if (userEmail != null) {
      final products = await firestoreService.fetchProductsAll();
      setState(() {
        userProducts = products.where((product) => product['seller_email'] == userEmail && !product['isAuction']).toList();
      });
    }
  }

  Future<void> _fetchUserAuctions() async {
    if (userEmail != null) {
      final auctions = await firestoreService.fetchProductsByUserEmail(userEmail!);
      setState(() {
        userAuctions = auctions;
      });
    }
  }

  Future<void> _markSizeAsSold(Map<String, dynamic> product, String size) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('NormalProducts')
          .where('product_id', isEqualTo: product['product_id'])
          .get();

      for (var doc in querySnapshot.docs) {
        final sizeStocks = doc['size_stocks'] as Map<String, dynamic>;
        if (sizeStocks[size] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock is already set to zero')),
          );
        } else {
          await doc.reference.update({'size_stocks.$size': 0});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock set to zero')),
          );
        }
      }
      _fetchUserProducts();
    } catch (e) {
      print('Error marking size as sold: $e');
    }
  }

  void _showConfirmDialog(Map<String, dynamic> product, String size) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.primary,
          title: const Text('Confirm', style: TextStyle(color: AppColor.secondary)),
          content: Text(
            'Are you sure you want to set the stock of size $size to 0?',
            style: const TextStyle(color: AppColor.secondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColor.secondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markSizeAsSold(product, size);
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      color: AppColor.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(product['productPhotoUrl'], fit: BoxFit.cover, width: 60, height: 60),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['product_name'], style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold)),
                      Text('Type: ${product['type']}', style: const TextStyle(color: AppColor.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...product['size_stocks'].entries.map<Widget>((entry) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Size ${entry.key}: ",
                      style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: "${entry.value} units",
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showConfirmDialog(product, entry.key),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                    ),
                    child: const Text('Mark as Sold', style: TextStyle(color: AppColor.secondary)),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuctionCard(Map<String, dynamic> auction) {
    return Card(
      color: AppColor.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(auction['productPhotoUrl'], fit: BoxFit.cover, width: 60, height: 60),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auction['product_name'], style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold)),
                      Text('Type: ${auction['type']}', style: const TextStyle(color: AppColor.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Ending Date and Time: ${DateFormat('MM-dd-yyyy hh:mm a').format(auction['BiddingEnd'].toDate())}",
              style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
            ),
            Text(
              "Current Bidding Price: ₹${auction['currentBid']}",
              style: const TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu_rounded, color: AppColor.secondary),
                  SizedBox(width: 10),
                  Text("Dashboard", style: TextStyle(color: AppColor.secondary, fontWeight: FontWeight.bold, fontSize: 22)),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(Icons.list, 'Number of Products Listed', userProducts.length.toString()),
                  _buildGridItem(Icons.gavel, 'Total Number of Auctions Placed by You', userAuctions.length.toString()),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Normally Listed Products',
                style: TextStyle(color: AppColor.secondary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userProducts.length,
                itemBuilder: (context, index) {
                  final product = userProducts[index];
                  return _buildProductCard(product);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Auctions',
                style: TextStyle(color: AppColor.secondary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userAuctions.length,
                itemBuilder: (context, index) {
                  final auction = userAuctions[index];
                  return _buildAuctionCard(auction);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String title, String number) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColor.primary, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 13, color: AppColor.primary)),
          const SizedBox(height: 10),
          Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.primary)),
        ],
      ),
    );
  }
}


