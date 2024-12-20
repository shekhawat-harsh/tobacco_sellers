import 'package:tobacco_sellers/const/colors.dart';
import 'package:tobacco_sellers/screens/product_page.dart';
import 'package:tobacco_sellers/utils/server/Firebase_store_fetch.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProfilePage extends StatefulWidget {
  final String sellerEmail;
  final String sellerName;

  const SellerProfilePage({
    Key? key, 
    required this.sellerEmail,
    required this.sellerName,
  }) : super(key: key);

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  final FirestoreService _firestoreService = FirestoreService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColor.green,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "${widget.sellerName}'s Profile",
          style: TextStyle(color: AppColor.green),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Seller Profile Header
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColor.green,
                  child: Image.asset(
                    "assets/images/avatar2.png", 
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sellerName,
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      widget.sellerEmail,
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Listed Products Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getSellerListedProducts(widget.sellerEmail),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.green,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No products listed",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var productData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    
                    return GestureDetector(
                      onTap: () {
                        // Navigate to Product Page
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => ProductPage(
                              image: productData['productPhotoUrl'] ?? '',
                              name: productData['product_name'] ?? '',
                              price: productData['currentBid'] ?? '',
                              author: productData['posted-by'] ?? '',
                              desc: productData['description'] ?? '',
                              email: productData['Poster_email'] ?? '',
                              time: (productData['BiddingEnd'] as Timestamp).toDate(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: AppColor.secondary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              productData['productPhotoUrl'] ?? '',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey,
                                  child: Icon(Icons.image_not_supported, color: Colors.white),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            productData['product_name'] ?? 'Unknown Product',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '\$${productData['currentBid'] ?? '0'}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to FirestoreService to get seller's listed products
extension SellerProductsExtension on FirestoreService {
  Stream<QuerySnapshot> getSellerListedProducts(String sellerEmail) {
    return FirebaseFirestore.instance
        .collection('Auctions')
        .where('Poster_email', isEqualTo: sellerEmail)
        .snapshots();
  }
}