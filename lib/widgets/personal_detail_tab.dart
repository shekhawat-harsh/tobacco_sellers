import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tobacco_sellers/const/colors.dart';
import 'package:tobacco_sellers/utils/common_methods/methods.dart';
import 'package:flutter/services.dart'; // Add this import

class PersonalDetailsTab extends StatefulWidget {
  const PersonalDetailsTab({Key? key}) : super(key: key);

  @override
  _PersonalDetailsTabState createState() => _PersonalDetailsTabState();
}

class _PersonalDetailsTabState extends State<PersonalDetailsTab> {
  final _formKey = GlobalKey<FormState>();
  final CommonMethods methods = CommonMethods();
  late Stream<DocumentSnapshot> _userStream;
  String? _verificationId;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .snapshots();
  }

  Future<void> _verifyPhone(String phoneNumber) async {
    setState(() => _isVerifying = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _updatePhoneNumber(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isVerifying = false);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isVerifying = false;
        });
        _showOtpDialog(phoneNumber);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _updatePhoneNumber(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.currentUser?.updatePhoneNumber(credential);
      methods.showSimpleToast('Phone number updated successfully');
    } catch (e) {
      methods.showSimpleToast('Error updating phone number');
    }
  }

  Future<void> _getCurrentLocation() async {
    final location = Location();
    final user = FirebaseAuth.instance.currentUser;
    
    try {
      final LocationData currentLocation = await location.getLocation();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'location': GeoPoint(
          currentLocation.latitude!,
          currentLocation.longitude!,
        ),
      });
      methods.showSimpleToast('Location updated successfully');
    } catch (e) {
      methods.showSimpleToast('Error updating location');
    }
  }

 Future<void> _showOtpDialog(String phoneNumber) async {
  String? otp;
  
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Enter OTP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Enter 6-digit OTP',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.green.withOpacity(0.5), width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.green, width: 2),
            ),
          ),
          onChanged: (value) => otp = value,
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColor.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              child: Text(
                'Verify',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                if (otp?.length == 6) {
                  try {
                    PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: _verificationId!,
                      smsCode: otp!,
                    );
                    Navigator.of(context).pop();
                    await _updatePhoneNumber(credential);
                    
                    final user = FirebaseAuth.instance.currentUser;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .update({'phone': phoneNumber});
                        
                  } catch (e) {
                    methods.showSimpleToast('Invalid OTP');
                  }
                }
              },
            ),
          ),
          SizedBox(width: 8),
        ],
      );
    },
  );
}
  Future<bool> _isUsernameAvailable(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<void> _updateUserField(String field, String value) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      if (field == 'username') {
        bool isAvailable = await _isUsernameAvailable(value);
        if (!isAvailable) {
          methods.showSimpleToast('Username not available');
          return;
        }
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({field: value});
      methods.showSimpleToast('Updated successfully');
    } catch (e) {
      methods.showSimpleToast('Error updating profile');
    }
  }

Widget _buildEditableField(String label, String value, String field) {
    final bool isEmail = field == 'email';
    final bool isUsername = field == 'username';
    final bool isPincode = field == 'pincode';
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Darker background for cards
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColor.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!isEmail)
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    constraints: BoxConstraints.tightFor(width: 36, height: 36),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      if (field == 'phone') {
                        _showEditDialog(label, value, field, isPhone: true);
                      } else if (isPincode) {
                        _showEditDialog(label, value, field, isPincode: true);
                      } else {
                        _showEditDialog(label, value, field, isUsername: isUsername);
                      }
                    },
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value.isEmpty ? 'Not set' : value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String label, String currentValue, String field, {bool isPhone = false, bool isUsername = false, bool isPincode = false}) {
    String newValue = currentValue;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Edit $label',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            keyboardType: isPincode ? TextInputType.number : TextInputType.text,
            inputFormatters: isPincode ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)] : [],
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter new $label',
              hintStyle: TextStyle(color: Colors.white38),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColor.green.withOpacity(0.5), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColor.green, width: 2),
              ),
            ),
            onChanged: (value) => newValue = value,
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColor.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isPhone) {
                    _verifyPhone(newValue);
                  } else if (isPincode) {
                    if (newValue.length == 6) {
                      _updateUserField(field, newValue);
                    } else {
                      methods.showSimpleToast('Pincode must be 6 digits');
                    }
                  } else {
                    _updateUserField(field, newValue);
                  }
                },
              ),
            ),
            SizedBox(width: 8),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Personal Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.green),
              ),
            );
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          if (userData == null) {
            return Center(
              child: Text(
                'No user data found',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  _buildEditableField('Full Name', userData['name'] ?? '', 'name'),
                  _buildEditableField('Email', userData['email'] ?? '', 'email'),
                  _buildEditableField('Phone', userData['phone'] ?? '', 'phone'),
                  _buildEditableField('Address', userData['address'] ?? '', 'address'),
                  _buildEditableField('Pincode', userData['pincode'] ?? '', 'pincode'),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.green,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Update Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  }