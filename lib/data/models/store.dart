class StoreModel {
  final String storeId;
  final String ownerUid;
  final String name;
  final String description;
  final List<String> categories;
  final StoreAddress storeLocation;
  final String? businessLicenseUrl;
  final String? foodSafetyCertificateUrl;
  final String? storeImageUrl;
  final String state;
  final bool isOpened;
  final bool isPromotion;
  final DateTime? createdAt;

  StoreModel({
    required this.storeId,
    required this.ownerUid,
    required this.name,
    required this.description,
    required this.categories,
    required this.storeLocation,
    this.businessLicenseUrl,
    this.foodSafetyCertificateUrl,
    this.storeImageUrl,
    this.state = 'pending',
    this.isOpened = false,
    this.isPromotion = false,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'ownerUid': ownerUid,
    'name': name,
    'description': description,
    'categories': categories,
    'storeLocation': storeLocation.toJson(),
    'state': state,
    'businessLicenseUrl': businessLicenseUrl,
    'foodSafetyCertificateUrl': foodSafetyCertificateUrl,
    'storeImageUrl': storeImageUrl,
    'isOpened': isOpened,
    'isPromotion': isPromotion,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    storeId: json['storeId'],
    ownerUid: json['ownerUid'],
    name: json['name'],
    description: json['description'],
    categories: List<String>.from(json['categories']),

    storeLocation: StoreAddress.fromJson(Map<String, dynamic>.from(json['storeLocation'])),

    businessLicenseUrl: json['businessLicenseUrl'],
    foodSafetyCertificateUrl: json['foodSafetyCertificateUrl'],
    storeImageUrl: json['storeImageUrl'],
    state: json['state'] ?? 'pending',
    isOpened: json['isOpened'] ?? false,
    isPromotion: json['isPromotion'] ?? false,
    createdAt:
        json['createdAt'] != null
            ? (json['createdAt'] is DateTime ? json['createdAt'] : DateTime.tryParse(json['createdAt'].toString()))
            : null,
  );

  StoreModel copyWith({
    String? storeId,
    String? ownerUid,
    String? name,
    String? description,
    List<String>? categories,
    StoreAddress? storeLocation,
    String? businessLicenseUrl,
    String? foodSafetyCertificateUrl,
    String? storeImageUrl,
    String? state,
    bool? isOpened,
    bool? isPromotion,
    DateTime? createdAt,
  }) {
    return StoreModel(
      storeId: storeId ?? this.storeId,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      storeLocation: storeLocation ?? this.storeLocation,
      businessLicenseUrl: businessLicenseUrl ?? this.businessLicenseUrl,
      foodSafetyCertificateUrl: foodSafetyCertificateUrl ?? this.foodSafetyCertificateUrl,
      storeImageUrl: storeImageUrl ?? this.storeImageUrl,
      state: state ?? this.state,
      isOpened: isOpened ?? this.isOpened,
      isPromotion: isPromotion ?? this.isPromotion,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  List<double>? getDefaultLatLng() {
    return [storeLocation.latitude, storeLocation.longitude];
  }
}

class StoreAddress {
  final String label;
  final String address;
  final double latitude;
  final double longitude;

  StoreAddress({required this.label, required this.address, required this.latitude, required this.longitude});

  factory StoreAddress.fromJson(Map<String, dynamic> json) => StoreAddress(
    label: json['label'],
    address: json['address'],
    latitude: (json['latitude'] as num?)!.toDouble(),
    longitude: (json['longitude'] as num?)!.toDouble(),
  );

  Map<String, dynamic> toJson() => {'label': label, 'address': address, 'latitude': latitude, 'longitude': longitude};

  StoreAddress copyWith({String? label, String? address, double? latitude, double? longitude, bool? isDefault}) {
    return StoreAddress(
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
