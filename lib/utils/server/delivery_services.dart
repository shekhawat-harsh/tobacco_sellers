// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:tobacco_sellers/models/delhivery_models.dart';

// class DelhiveryService {
//   final String apiToken;
//   final bool isProduction;
//   final bool enableDebug;
  
//   // Constants for HSN code and GST
//   static const String DEFAULT_HSN_CODE = '84719000';
//   static const String DEFAULT_GST_NUMBER = 'dummygst';
  
//   DelhiveryService({
//     required this.apiToken,
//     this.isProduction = false,
//     this.enableDebug = true,
//   });

//   String get baseUrl => isProduction 
//     ? 'https://track.delhivery.com'
//     : 'https://staging-express.delhivery.com';

//   Future<Map<String, dynamic>> createShipments(
//     List<ShipmentModel> shipments, {
//     required DelhiveryWarehouse pickupLocation,
//   }) async {
//     try {
//       _validateShipments(shipments);
//       _validatePickupLocation(pickupLocation);

//       final url = Uri.parse('$baseUrl/api/cmu/create.json');
      
//       // Format shipments according to Delhivery's requirements
//       final formattedShipments = shipments.map((shipment) => {
//         'name': shipment.name,
//         'add': shipment.add,
//         'pin': shipment.pin,
//         'phone': shipment.phone,
//         'order': shipment.order,
//         'payment_mode': shipment.paymentMode,
//         'products_desc': shipment.products_desc,
//         'seller_gst_tin': DEFAULT_GST_NUMBER,  // Using constant GST
//         'hsn_code': DEFAULT_HSN_CODE,          // Using constant HSN code
//         'cod_amount': shipment.paymentMode.toLowerCase() == 'cod' ? shipment.total_amount : '0',
//         'order_date': shipment.order_date,
//         'total_amount': shipment.total_amount,
//         'quantity': shipment.quantity,
//         'shipping_mode': 'Surface',
//         'country': 'India',
//       }).toList();

//       // Format pickup location
//       final formattedPickupLocation = {
//         'name': pickupLocation.registered_name,
//         'add': pickupLocation.address,
//         'city': pickupLocation.city,
//         'pin': pickupLocation.pin,
//         'phone': pickupLocation.phone,
//         'state': pickupLocation.state,
//         'country': pickupLocation.country,
//       };

//       // Construct the final payload
//       final requestData = {
//         'shipments': formattedShipments,
//         'pickup_location': formattedPickupLocation,
//       };

//       // Format as per Delhivery's requirement
//       final payload = 'format=json&data=${json.encode(requestData)}';

//       if (enableDebug) {
//         print('Request URL: $url');
//         print('Request Headers: ${_getHeaders()}');
//         print('Request Payload: $payload');
//       }

//       final response = await http.post(
//         url,
//         headers: _getHeaders(),
//         body: payload,
//       );

//       if (enableDebug) {
//         print('Response Status Code: ${response.statusCode}');
//         print('Response Body: ${response.body}');
//       }

//       final responseData = json.decode(response.body);
      
//       // Check for API-specific errors
//       if (responseData['success'] == false) {
//         throw Exception('API Error: ${responseData['error'] ?? 'Unknown error'}');
//       }

//       return responseData;
//     } catch (e) {
//       if (enableDebug) {
//         print('Error in createShipments: $e');
//       }
//       rethrow;
//     }
//   }

//   Map<String, String> _getHeaders() => {
//     'Content-Type': 'application/x-www-form-urlencoded',
//     'Accept': 'application/json',
//     'Authorization': 'Token $apiToken',
//   };

//   void _validateShipments(List<ShipmentModel> shipments) {
//     if (shipments.isEmpty) {
//       throw Exception('No shipments provided');
//     }
    
//     for (final shipment in shipments) {
//       final errors = <String>[];
      
//       if (shipment.pin.isEmpty) errors.add('PIN code');
//       if (shipment.phone.isEmpty) errors.add('Phone number');
//       if (shipment.add.isEmpty) errors.add('Address');
//       if (shipment.name.isEmpty) errors.add('Name');
//       if (shipment.order.isEmpty) errors.add('Order ID');
      
//       if (errors.isNotEmpty) {
//         throw Exception('Missing required fields: ${errors.join(", ")}');
//       }
//     }
//   }

//   void _validatePickupLocation(DelhiveryWarehouse location) {
//     final errors = <String>[];
    
//     if (location.registered_name?.isEmpty ?? true) errors.add('Registered name');
//     if (location.address?.isEmpty ?? true) errors.add('Address');
//     if (location.pin?.isEmpty ?? true) errors.add('PIN code');
//     if (location.phone?.isEmpty ?? true) errors.add('Phone');
//     if (location.city?.isEmpty ?? true) errors.add('City');
//     if (location.state?.isEmpty ?? true) errors.add('State');
    
//     if (errors.isNotEmpty) {
//       throw Exception('Missing required pickup location fields: ${errors.join(", ")}');
//     }
//   }
// }