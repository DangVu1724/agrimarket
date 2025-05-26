abstract class UserDetails {
  Map<String, dynamic> toJson();
}

class BuyerDetails extends UserDetails {
  final String address;
  final double? latitude;
  final double? longitude;

  BuyerDetails({
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory BuyerDetails.fromJson(Map<String, dynamic> json) {
    return BuyerDetails(
      address: json['address'] ?? '',
      latitude: (json['latitude'] != null) ? (json['latitude'] as num).toDouble() : null,
      longitude: (json['longitude'] != null) ? (json['longitude'] as num).toDouble() : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}


class SellerDetails extends UserDetails {
  final String storeName;
  final String storeAddress;

  SellerDetails({required this.storeName, required this.storeAddress});

  factory SellerDetails.fromJson(Map<String, dynamic> json) {
    return SellerDetails(
      storeName: json['storeName'] ?? '',
      storeAddress: json['storeAddress'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'storeAddress': storeAddress,
    };
  }
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? role; 
  final UserDetails? details;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.role,
    this.details,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] ?? 'buyer'; // mặc định buyer nếu không có role

    UserDetails details;
    if (role == 'buyer') {
      details = BuyerDetails.fromJson(json['details'] ?? {});
    } else {
      details = SellerDetails.fromJson(json['details'] ?? {});
    }

    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: role,
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'details': details?.toJson(),
    };
  }
}
