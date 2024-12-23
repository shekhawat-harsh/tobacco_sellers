// models/delhivery_models.dart
class DelhiveryWarehouse {

  final String? name;
  final String? email; // Add email field
  final String? pin;
  final String? address;
  final String? phone;
  final String? city;
  final String? state;
  final String? country;
  final String? registered_name;
  final String? return_address;
  final String? return_pin;
  final String? return_city;
  final String? return_state;
  final String? return_country;

  DelhiveryWarehouse({
    this.name,
    this.email, // Add email parameter
    this.pin,
    this.address,
    this.phone,
    this.city,
    this.state,
    this.country = 'India',
    this.registered_name,
    this.return_address,
    this.return_pin,
    this.return_city,
    this.return_state,
    this.return_country = 'India',
  });

  Map<String, dynamic> toJson() => {
    'isApproved': false,
    'name': name,
    'email': email, // Add email to JSON
    'pin': pin,
    'address': address,
    'phone': phone,
    'city': city,
    'state': state,
    'country': country,
    'registered_name': registered_name,
    'return_address': return_address,
    'return_pin': return_pin,
    'return_city': return_city,
    'return_state': return_state,
    'return_country': return_country,
  };

  factory DelhiveryWarehouse.fromJson(Map<String, dynamic> json) => DelhiveryWarehouse(
    name: json['name'],
    email: json['email'], // Add email to fromJson
    pin: json['pin'],
    address: json['address'],
    phone: json['phone'],
    city: json['city'],
    state: json['state'],
    country: json['country'],
    registered_name: json['registered_name'],
    return_address: json['return_address'],
    return_pin: json['return_pin'],
    return_city: json['return_city'],
    return_state: json['return_state'],
    return_country: json['return_country'],
  );
}
// class ShipmentModel {
//   final String name;
//   final String add;
//   final String pin;
//   final String phone;
//   final String order;
//   final String city;
//   final String state;
//   final String paymentMode;
//   final String seller_gst_tin;
//   final String hsn_code;
//   final String products_desc;
//   final String quantity;
//   final String total_amount;
//   final String? order_date;
  
//   ShipmentModel({
//     required this.name,
//     required this.add,
//     required this.pin,
//     required this.phone,
//     required this.order,
//     required this.city,
//     required this.state,
//     required this.paymentMode,
//     required this.seller_gst_tin,
//     required this.hsn_code,
//     required this.products_desc,
//     required this.quantity,
//     required this.total_amount,
//     this.order_date,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       "name": name,
//       "add": add,
//       "pin": pin,
//       "city": city,
//       "state": state,
//       "country": "India",
//       "phone": phone,
//       "order": order,
//       "payment_mode": paymentMode,
//       "products_desc": products_desc,
//       "hsn_code": hsn_code,
//       "order_date": order_date,
//       "total_amount": total_amount,
//       "quantity": quantity,
//       "seller_gst_tin": seller_gst_tin,
//       "shipping_mode": "Surface",
//     };
//   }
// }