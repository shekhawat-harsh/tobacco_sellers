import 'package:tobacco_sellers/const/colors.dart';
import 'package:tobacco_sellers/screens/product_page.dart';
import 'package:tobacco_sellers/screens/normal_selling_product_page.dart';
import 'package:flutter/material.dart';
import '../utils/server/Firebase_store_fetch.dart';

class ProductLoading extends StatefulWidget {
  final int item_no;
  const ProductLoading({required this.item_no, Key? key}) : super(key: key);

  @override
  State<ProductLoading> createState() => _ProductLoadingState();
}

class _ProductLoadingState extends State<ProductLoading> {
  List<String> items = [
    "All",
    "Completed",
    "Gadget",
    "Art",
    "Toys",
    "Cars",
    "Shoes",
    "Misc"
  ];

  FirestoreService firestoreFetch = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.primary,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("A Server Error has occurred!"),
          );
        } else {
          List<Map<String, dynamic>> productLists = snapshot.data ?? [];
          
          // Filter out ended auctions except in "Completed" category
          if (widget.item_no != 1) {
            productLists = productLists.where((product) {
              if (product['isAuction'] == true) {
                return product['status'] == 'running';
              }
              return true; // Keep all normal products
            }).toList();
          }

          if (productLists.isEmpty) {
            return Center(
              child: Text(
                'No products available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return PageView.builder(
            itemCount: productLists.length,
            itemBuilder: (context, index) {
              final product = productLists[index];
              return GestureDetector(
                onTap: () {
                  if (product['isAuction'] == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          image: product['productPhotoUrl'],
                          name: product['product_name'],
                          price: product['currentBid'],
                          author: product['posted-by'],
                          desc: product['description'],
                          email: product['Poster_email'],
                          time: product['BiddingEnd'].toDate(),
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NormalProductPage(
                          image: product['productPhotoUrl'],
                          name: product['product_name'],
                          price: product['price'],
                          seller: product['seller'],
                          desc: product['description'],
                          email: product['seller_email'],
                          sizeStocks: Map<String, int>.from(product['size_stocks']),
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: _ProductCard(product: product),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getProducts() {
    if (widget.item_no == 0) {
      return firestoreFetch.fetchProductsAll();
    } else if (widget.item_no == 1) {
      return firestoreFetch.fetchCompletedProducts();
    } else {
      return firestoreFetch.fetchProductsByType(items[widget.item_no]);
    }
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAuction = product['isAuction'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                product['productPhotoUrl'] ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  );
                },
              ),
            ),
          ),

          // Product Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['product_name'] ?? 'Unknown Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    isAuction 
                        ? 'By ${product['posted-by'] ?? 'Unknown Seller'}'
                        : 'By ${product['seller'] ?? 'Unknown Seller'}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAuction
                            ? '₹${product['currentBid'] ?? product['minimumBidPrice'] ?? '0'}'
                            : '₹${product['price'] ?? '0'}',
                        style: TextStyle(
                          color: AppColor.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isAuction ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAuction ? 'Auction' : 'Buy Now',
                          style: TextStyle(
                            color: isAuction ? Colors.orange : Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}