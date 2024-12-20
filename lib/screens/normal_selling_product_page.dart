import 'package:flutter/material.dart';
import '../const/colors.dart';
import '../const/shared_preferences.dart';
import '../utils/common_methods/methods.dart';
import '../utils/server/Product_normal_selling_services.dart';
import '../screens/sellers_profile_page.dart';

class NormalProductPage extends StatefulWidget {
  final String image;
  final String name;
  final String price;
  final String seller;
  final String desc;
  final String email;
  final Map<String, int> sizeStocks;

  const NormalProductPage({
    required this.image,
    required this.name,
    required this.price,
    required this.seller,
    required this.desc,
    required this.email,
    required this.sizeStocks,
    Key? key,
  }) : super(key: key);

  @override
  State<NormalProductPage> createState() => _NormalProductPageState();
}

class _NormalProductPageState extends State<NormalProductPage> {
  CommonMethods methods = CommonMethods();
  NormalSellingService sellingService = NormalSellingService();
  final String? userEmail = SharedPreferenceHelper().getEmail();
  final String? userName = SharedPreferenceHelper().getUserName();
  final String? balance = SharedPreferenceHelper().getBalance();
  late String? productId;
  String? selectedSize;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    productId = "${widget.name}-${widget.email}";
    if (widget.sizeStocks.isNotEmpty) {
      selectedSize = widget.sizeStocks.keys.first;
    }
  }

  void _handlePurchase() {
    if (widget.email == userEmail) {
      methods.showSimpleToast("You can't buy your own listed item");
      return;
    }

    if (selectedSize == null) {
      methods.showSimpleToast("Please select a size");
      return;
    }

    if (widget.sizeStocks[selectedSize]! < quantity) {
      methods.showSimpleToast("Not enough stock available");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Confirm Purchase",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Size: $selectedSize",
                style: TextStyle(color: Colors.black87),
              ),
              Text(
                "Quantity: $quantity",
                style: TextStyle(color: Colors.black87),
              ),
              Text(
                "Total Price: ₹${(double.parse(widget.price) * quantity).toStringAsFixed(2)}",
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel", 
                style: TextStyle(color: Colors.grey[800])
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Buy Now", 
                style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold
                )
              ),
              onPressed: () {
                sellingService.purchaseProduct(
                  productId!,
                  userName!,
                  userEmail!,
                  widget.price,
                  balance!,
                  selectedSize!,
                  quantity,
                );
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.primary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Product Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(widget.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Product Details Section
              Text(
                widget.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.desc,
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              SizedBox(height: 20),

              // Seller Profile Section
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerProfilePage(
                        sellerEmail: widget.email,
                        sellerName: widget.seller,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColor.primary,
                        child: Text(
                          widget.seller[0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Seller",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14
                              ),
                            ),
                            Text(
                              widget.seller,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColor.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Price Display
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Price:",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      "₹${widget.price}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Size Selection
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Size",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.sizeStocks.entries.map((entry) {
                        final isSelected = selectedSize == entry.key;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSize = entry.key;
                              quantity = 1;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColor.primary : Colors.white,
                              border: Border.all(
                                color: isSelected ? AppColor.primary : Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${entry.value} left",
                                  style: TextStyle(
                                    color: isSelected ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Quantity Selection
              if (selectedSize != null)
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Quantity:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.black),
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                quantity.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.black),
                              onPressed: quantity < (widget.sizeStocks[selectedSize] ?? 0)
                                  ? () => setState(() => quantity++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 30),

              // Buy Now Button
              InkWell(
                onTap: _handlePurchase,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: selectedSize != null ? AppColor.primary : Colors.grey,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: selectedSize != null ? [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      selectedSize != null ? "Buy Now" : "Select Size",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}