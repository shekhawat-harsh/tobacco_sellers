import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../const/colors.dart';
import '../const/shared_preferences.dart';
import '../utils/common_widgets/textfield_widget.dart';
import '../utils/server/Firebase_store_fetch.dart';
import '../utils/server/Product_normal_selling_services.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  File? _image;
  final picker = ImagePicker();
  DateTime dateTime = DateTime(2023, 07, 19, 3, 24);
  String dropdownValue = 'Gadget';
  String listingType = 'Normal'; // Default to Normal listing
  final String? userName = SharedPreferenceHelper().getUserName();
  final String? userEmail = SharedPreferenceHelper().getEmail();
  final FirestoreService _firestoreService = FirestoreService();
  final NormalSellingService _normalSellingService = NormalSellingService();

  TextEditingController productNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController sizeStockController = TextEditingController();
  TextEditingController weightController = TextEditingController(); // Add this line

  Map<String, int> sizeStocks = {};

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void addSizeWithStock() {
    if (sizeController.text.isNotEmpty && sizeStockController.text.isNotEmpty) {
      setState(() {
        sizeStocks[sizeController.text.trim()] = int.parse(sizeStockController.text.trim());
        sizeController.clear();
        sizeStockController.clear();
      });
    }
  }

  void removeSize(String size) {
    setState(() {
      sizeStocks.remove(size);
    });
  }

  Future pickDateTime() async {
    DateTime? date = await pickDate();
    if (date == null) return;
    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      this.dateTime = dateTime;
    });
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      );

  String _formatNumber(int number) => number.toString().padLeft(2, '0');

  Future<bool> _isProductNameUnique(String productName) async {
    final normalProducts = await _firestoreService.fetchNormalProductsByUserEmail(userEmail!);
    final auctionProducts = await _firestoreService.fetchAuctionsByUserEmail(userEmail!);
    return !normalProducts.any((product) => product['product_name'] == productName) &&
           !auctionProducts.any((product) => product['product_name'] == productName);
  }

  Future<void> _handleSubmit() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    if (productNameController.text.isEmpty || 
        descriptionController.text.isEmpty || 
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final isUnique = await _isProductNameUnique(productNameController.text.trim());
    if (!isUnique) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product name must be unique')),
      );
      return;
    }

    if (listingType == 'Normal') {
      if (sizeStocks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one size with stock')),
        );
        return;
      }

      _normalSellingService.uploadProductData(
        context,
        productNameController.text.trim(),
        dropdownValue,
        priceController.text.trim(),
        descriptionController.text.trim(),
        userName!,
        userEmail!,
        _image!,
        sizeStocks,
      );
    } else {
      _firestoreService.uploadAuctionData(
        context,
        productNameController.text.trim(),
        dropdownValue,
        priceController.text.trim(),
        dateTime,
        descriptionController.text.trim(),
        userName!,
        userEmail!,
        _image!,
        weightController.text.trim(), // Pass weight to the method
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          listingType == 'Normal' ? "Add Product" : "Add item for Auction",
          style: TextStyle(color: AppColor.secondary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Listing Type Toggle
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.secondary),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => listingType = 'Normal'),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: listingType == 'Normal'
                                ? AppColor.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(7),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Normal Listing',
                              style: TextStyle(
                                color: listingType == 'Normal'
                                    ? AppColor.primary
                                    : AppColor.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => listingType = 'Auction'),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: listingType == 'Auction'
                                ? AppColor.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(7),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Auction',
                              style: TextStyle(
                                color: listingType == 'Auction'
                                    ? AppColor.primary
                                    : AppColor.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Image Picker
              Row(
                children: [
                  InkWell(
                    onTap: getImage,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white54),
                      ),
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : Center(
                              child: Icon(
                                Icons.add_circle_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Add item photo",
                        style: TextStyle(color: AppColor.secondary, fontSize: 16),
                      ),
                      Text(
                        "Max 5 MB",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Product Details
              CustomTextfield(
                label: 'Product Name',
                hinttext: "Enter Your Product Name",
                type: TextInputType.text,
                size: 5.0,
                controller: productNameController,
              ),
              SizedBox(height: 20),

              CustomTextfield(
                label: 'Product Description',
                hinttext: "Describe your product",
                type: TextInputType.multiline,
                size: 100.0,
                controller: descriptionController,
              ),
              SizedBox(height: 20),

              CustomTextfield(
                label: listingType == 'Normal' ? 'Price' : 'Minimum Bid Price',
                hinttext: listingType == 'Normal' ? "Selling Price" : "Minimum Bid Price",
                type: TextInputType.number,
                size: 5.0,
                controller: priceController,
              ),
              SizedBox(height: 20),

              // Conditional Widgets based on listing type
              if (listingType == 'Normal') ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextfield(
                        label: 'Size',
                        hinttext: "Add size (e.g., S, M, L, XL)",
                        type: TextInputType.text,
                        size: 5.0,
                        controller: sizeController,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: CustomTextfield(
                        label: 'Stock',
                        hinttext: "Quantity",
                        type: TextInputType.number,
                        size: 5.0,
                        controller: sizeStockController,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: AppColor.secondary),
                      onPressed: addSizeWithStock,
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Wrap(
                  spacing: 8.0,
                  children: sizeStocks.entries.map((entry) => Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    onDeleted: () => removeSize(entry.key),
                    backgroundColor: AppColor.secondary,
                    labelStyle: TextStyle(color: Colors.white),
                    deleteIconColor: Colors.white,
                  )).toList(),
                ),
              ] else ...[
                Text(
                  "Auction End Date",
                  style: TextStyle(color: AppColor.secondary),
                ),
                TextField(
                  controller: TextEditingController(
                    text: '${_formatNumber(dateTime.day)}/${_formatNumber(dateTime.month)}/${dateTime.year} at ${_formatNumber(dateTime.hour)}:${_formatNumber(dateTime.minute)}',
                  ),
                  style: TextStyle(color: AppColor.secondary),
                  onTap: pickDateTime,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5),
                    hintText: 'Choose end date and time',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.secondary),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: AppColor.secondary),
                  ),
                ),
              ],
              SizedBox(height: 20),

              CustomTextfield(
                label: 'Weight (per unit)',
                hinttext: "Enter weight of one unit",
                type: TextInputType.number,
                size: 5.0,
                controller: weightController,
              ),
              SizedBox(height: 20),

              // Category Selection
              Text(
                'Category',
                style: TextStyle(color: AppColor.secondary),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.secondary),
                ),
                child: Padding(
                 padding:  const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    dropdownColor: AppColor.primary,
                    isExpanded: true,
                    items: ['Gadget', 'Art', 'Toys', 'Cars', 'Shoes', 'Misc']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.white),
                              ),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    style: TextStyle(color: Colors.white),
                    underline: Container(),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: Text(
                      listingType == 'Normal' ? "Add Product" : "Add Auction Item",
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}