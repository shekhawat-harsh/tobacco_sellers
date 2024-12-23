import 'package:tobacCoSellers/const/colors.dart';
import 'package:tobacCoSellers/const/shared_preferences.dart';
import 'package:tobacCoSellers/utils/server/Firebase_store_fetch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tobacCoSellers/utils/server/Product_normal_selling_services.dart';

class PostedContainer extends StatelessWidget {
  FirestoreService firestoreFetch = FirestoreService();
  NormalSellingService normalSellingService = NormalSellingService();
  final String? userEmail = SharedPreferenceHelper().getEmail();
  
  Future<List<Map<String, dynamic>>> _fetchAllProducts() async {
    List<Map<String, dynamic>> auctionProducts = await firestoreFetch.fetchProductsByUserEmail(userEmail!);
    List<Map<String, dynamic>> normalProducts = await normalSellingService.fetchUserListings(userEmail!);
    return [...auctionProducts, ...normalProducts];
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: AppColor.secondary),
            borderRadius: BorderRadius.circular(20)),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchAllProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColor.secondary,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error fetching products: ${snapshot.error}", style: TextStyle(color: AppColor.secondary)),
              );
            } else {
              List<Map<String, dynamic>> productList = snapshot.data ?? [];
              return ListView.separated(
                shrinkWrap: true,
                itemCount: productList.length,
                separatorBuilder: (context, index) => Divider(
                  color: AppColor.secondary,
                ),
                itemBuilder: (context, index) {
                  Map<String, dynamic> productData = productList[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.network(productData['productPhotoUrl'], fit: BoxFit.cover,),
                      ),
                    ),
                    title: Text(
                      "${productData['product_name']}",
                      style: TextStyle(
                        color: AppColor.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productData.containsKey('BiddingEnd')
                            ? "Ending on ${DateFormat('MM-dd-yyyy').format(productData['BiddingEnd'].toDate())}"
                            : "Price:  ₹${productData['price']}",
                          style: TextStyle(
                            color: AppColor.secondary,
                            fontSize: 10,
                          ),
                        ),
                        if (productData.containsKey('size_stocks'))
                          ...productData['size_stocks'].entries.map<Widget>((entry) {
                            return Text(
                              "Size ${entry.key}: ${entry.value} units",
                              style: TextStyle(
                                color: AppColor.secondary,
                                fontSize: 10,
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                    trailing: Text(
                      productData.containsKey('minimumBidPrice')
                        ? ' ₹${productData['minimumBidPrice']}'
                        : ' ₹${productData['price']}',
                      style: TextStyle(
                        color: AppColor.secondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
