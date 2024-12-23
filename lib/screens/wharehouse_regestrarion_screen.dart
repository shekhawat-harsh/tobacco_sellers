// screens/warehouse_registration.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tobacCoSellers/const/api_keys.dart';
import 'package:tobacCoSellers/utils/server/delivery_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tobacCoSellers/widgets/page_container.dart';
import '../const/colors.dart';
import '../const/shared_preferences.dart';
import '../models/delhivery_models.dart';

class WarehouseRegistrationPage extends StatefulWidget {
  final String? email;
  const WarehouseRegistrationPage({Key? key, this.email}) : super(key: key);

  @override
  State<WarehouseRegistrationPage> createState() => _WarehouseRegistrationPageState();
}

class _WarehouseRegistrationPageState extends State<WarehouseRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _registeredNameController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  String? _sellerEmail;
  bool _isPhoneVerified = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _loadSellerEmail();
    _checkIfSellerExists();
  }

  Future<void> _loadSellerEmail() async {
    final prefs = SharedPreferenceHelper();
    final email = prefs.getEmail();
    setState(() {
      _sellerEmail = email;
    });
  }

  Future<void> _checkIfSellerExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final sellerQuery = await FirebaseFirestore.instance
          .collection('sellers')
          .where('email', isEqualTo: user.email)
          .get();

      if (sellerQuery.docs.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => PageContainer()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  String _getReadableError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    // Type conversion errors
    if (errorStr.contains('type \'string\' is not a subtype of type \'int\'')) {
      return 'Invalid number format. Please check PIN code and phone number fields.';
    }
    
    // Network related errors
    if (errorStr.contains('socketexception')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    
    // Delhivery API specific errors
    if (errorStr.contains('invalid api key')) {
      return 'Authentication failed. Please contact support.';
    }
    if (errorStr.contains('invalid pin')) {
      return 'Invalid PIN code. Please enter a valid 6-digit PIN code.';
    }
    if (errorStr.contains('invalid phone')) {
      return 'Invalid phone number. Please enter a valid 10-digit phone number.';
    }
    
    // Firebase related errors
    if (errorStr.contains('permission-denied')) {
      return 'You don\'t have permission to register a warehouse. Please check your account privileges.';
    }
    if (errorStr.contains('not-found')) {
      return 'Unable to access the database. Please try again later.';
    }
    
    // Validation errors
    if (errorStr.contains('required')) {
      return 'Please fill in all required fields.';
    }
    
    // Default error message
    return 'An unexpected error occurred: $error\nPlease try again or contact support if the issue persists.';
  }

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
      setState(() {
        _error = 'Please enter a valid 10-digit phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${_phoneController.text}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() {
          _isPhoneVerified = true;
          _isLoading = false;
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        _showOtpDialog();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
      },
    );
  }

  void _showOtpDialog() {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.primary,
          title: const Text(
            'Enter OTP',
            style: TextStyle(color: AppColor.secondary),
          ),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'OTP',
              labelStyle: TextStyle(color: AppColor.secondary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColor.secondary.withOpacity(0.3)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: AppColor.secondary),
              ),
            ),
            style: const TextStyle(color: AppColor.secondary),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final code = otpController.text.trim();
                if (code.isNotEmpty && _verificationId != null) {
                  try {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: _verificationId!,
                      smsCode: code,
                    );
                    await FirebaseAuth.instance.signInWithCredential(credential);
                    setState(() {
                      _isPhoneVerified = true;
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    setState(() {
                      _error = 'Invalid OTP. Please try again.';
                    });
                  }
                }
              },
              child: const Text(
                'Verify',
                style: TextStyle(color: AppColor.secondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerWarehouse() async {
    if (!_formKey.currentState!.validate() || !_isPhoneVerified) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Input validation with specific error messages
      if (_pinController.text.length != 6) {
        throw 'PIN code must be exactly 6 digits';
      }
      if (_phoneController.text.length != 10) {
        throw 'Phone number must be exactly 10 digits';
      }

      // Parse numeric values to ensure they're valid
      final pin = _pinController.text.trim();
      final phone = _phoneController.text.trim();

      final warehouse = DelhiveryWarehouse(
        name: _nameController.text.trim(),
        email: widget.email, // Use email from Google Sign-In
        phone: phone,
        address: _addressController.text.trim(),
        pin: pin,
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        registered_name: _registeredNameController.text.trim(),
        return_address: _addressController.text.trim(),
        return_pin: pin,
        return_city: _cityController.text.trim(),
        return_state: _stateController.text.trim(),
      );

      // Store warehouse details in Firebase
      try {
        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .set(warehouse.toJson());
      } catch (firestoreError) {
        print("Firestore error: $firestoreError");
        throw 'Failed to save warehouse details: ${_getReadableError(firestoreError)}';
      }

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColor.primary,
              title: const Text(
                'Success',
                style: TextStyle(color: AppColor.secondary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColor.secondary,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Warehouse registered successfully!',
                    style: TextStyle(color: AppColor.secondary),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => PageContainer()),
                      (Route<dynamic> route) => false,
                    ); // Navigate to PageContainer
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: AppColor.secondary),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if it's showing
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        
        final readableError = _getReadableError(e);
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColor.primary,
              title: const Text(
                'Error',
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    readableError,
                    style: const TextStyle(color: AppColor.secondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: AppColor.secondary),
                  ),
                ),
              ],
            );
          },
        );
      }

      setState(() {
        _error = _getReadableError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        style: const TextStyle(color: AppColor.secondary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColor.secondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColor.secondary.withOpacity(0.3)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColor.secondary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: AppColor.secondary.withOpacity(0.1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        title: const Text(
          'Register Warehouse',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                _buildTextField(
                  label: 'Warehouse Name',
                  controller: _nameController,
                ),

                _buildTextField(
                  label: 'Registered Business Name',
                  controller: _registeredNameController,
                ),

                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPhoneNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                          ),
                        )
                      : const Text(
                          'Verify Phone Number',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (!_isPhoneVerified)
                  Text(
                    'Phone number not verified',
                    style: TextStyle(color: Colors.red),
                  ),

                _buildTextField(
                  label: 'Complete Address',
                  controller: _addressController,
                  maxLines: 3,
                ),

                _buildTextField(
                  label: 'PIN Code',
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'PIN code is required';
                    }
                    if (value.length != 6) {
                      return 'PIN code must be 6 digits';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  label: 'City',
                  controller: _cityController,
                ),

                _buildTextField(
                  label: 'State',
                  controller: _stateController,
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _registerWarehouse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                          ),
                        )
                      : const Text(
                          'Register Warehouse',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColor.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pinController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _registeredNameController.dispose();
    super.dispose();
  }
}