import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../common_methods/methods.dart';

class NormalSellingService {
  CommonMethods methods = CommonMethods();

  Future<void> uploadProductData(
    BuildContext context,
    String productName,
    String type,
    String price,
    String desc,
    String seller,
    String sellerEmail,
    File photo,
    Map<String, int> sizeStocks,
  ) async {
    try {
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref();

      final photoRef = storageRef.child(
          'NormalProducts/$productName - $seller/Product.jpg');
      final uploadTask = await photoRef.putFile(photo);

      final productPicUrl = await uploadTask.ref.getDownloadURL();

      final firestore = FirebaseFirestore.instance;
      final productsCollection = firestore.collection('NormalProducts');

      final productDocument = productsCollection.doc('$productName-$sellerEmail');

      // Calculate total stock
      int totalStock = sizeStocks.values.fold(0, (sum, stock) => sum + stock);

      await productDocument.set({
        'product_name': productName,
        'type': type,
        'description': desc,
        'price': price,
        'seller': seller,
        'seller_email': sellerEmail,
        'status': 'available',
        'productPhotoUrl': productPicUrl,
        'listed_date': DateTime.now(),
        'size_stocks': sizeStocks, // Store the size-stock mapping
        'total_stock': totalStock, // Store total stock across all sizes
      });

      methods.showSimpleToast("Your Product has been Listed");

      // Navigator.pushAndRemoveUntil(
      //   context,
        // MaterialPageRoute(
        //   builder: (context) => NormalProductPage(
        //     image: productPicUrl,
        //     name: productName,
        //     price: price,
        //     seller: seller,
        //     desc: desc,
        //     email: sellerEmail,
        //     sizeStocks: sizeStocks, // Pass size stocks to product page
        //   ),
        // ),
        // (Route<dynamic> route) => false,
      // );
    } catch (e) {
      print('Error uploading product data: $e');
    }
  }

  Future<void> purchaseProduct(
    String productID,
    String buyerName,
    String buyerEmail,
    String price,
    String balance,
    String size,
    int quantity,
  ) async {
    try {
      double productPrice = double.parse(price) * quantity;
      double currentBalance = double.parse(balance);

      if (productPrice <= currentBalance) {
        double remainingBalance = currentBalance - productPrice;
        if (remainingBalance < 0) {
          methods.showSimpleToast("Insufficient Balance!");
          return;
        }

        final DocumentReference productDoc = 
            FirebaseFirestore.instance.collection('NormalProducts').doc(productID);

        // Get current product data
        DocumentSnapshot productSnapshot = await productDoc.get();
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> sizeStocks = Map<String, dynamic>.from(productData['size_stocks']);

        // Check if size exists and has enough stock
        if (!sizeStocks.containsKey(size)) {
          methods.showSimpleToast("Size not available!");
          return;
        }

        int currentStock = sizeStocks[size];
        if (currentStock < quantity) {
          methods.showSimpleToast("Insufficient stock for selected size!");
          return;
        }

        // Update stock
        sizeStocks[size] = currentStock - quantity;
        int newTotalStock = productData['total_stock'] - quantity;

        // Determine if the product is now out of stock
        String newStatus = newTotalStock > 0 ? 'available' : 'sold out';

        // Create purchase record
        await productDoc.collection('purchases').add({
          'buyer_name': buyerName,
          'buyer_email': buyerEmail,
          'purchase_date': DateTime.now(),
          'size': size,
          'quantity': quantity,
          'price_per_unit': price,
          'total_price': productPrice,
        });

        // Update product document
        await productDoc.update({
          'size_stocks': sizeStocks,
          'total_stock': newTotalStock,
          'status': newStatus,
        });

        methods.showSimpleToast("Purchase Successful!");
        
        // Update user balance
        // Note: Implement your balance update logic here using SharedPreferences
      } else {
        methods.showSimpleToast('Insufficient balance for purchase.');
      }
    } catch (e) {
      print('Error purchasing product: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchAvailableProducts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('NormalProducts')
          .where('status', isEqualTo: 'available')
          .get();

      List<Map<String, dynamic>> productList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return productList;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserPurchases(String buyerEmail) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('NormalProducts')
          .where('buyer_email', isEqualTo: buyerEmail)
          .where('status', isEqualTo: 'sold')
          .get();

      List<Map<String, dynamic>> purchases = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return purchases;
    } catch (e) {
      print("Error fetching purchases: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserListings(String sellerEmail) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('NormalProducts')
          .where('seller_email', isEqualTo: sellerEmail)
          .get();

      List<Map<String, dynamic>> listings = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return listings;
    } catch (e) {
      print("Error fetching listings: $e");
      return [];
    }
  }
}