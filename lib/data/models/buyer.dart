class BuyerModel {
  final String uid;
  final List<String> favoriteStoreIds;
  final List<Address> addresses;
  final List<Review> reviews;
  final List<String> orderIds;

  BuyerModel({
    required this.uid,
    this.favoriteStoreIds = const [],
    this.addresses = const [],
    this.reviews = const [],
    this.orderIds = const [],
  });

  factory BuyerModel.fromJson(Map<String, dynamic> json) {
    return BuyerModel(
      uid: json['uid'],
      favoriteStoreIds: List<String>.from(json['favoriteStoreIds'] ?? []),
      addresses:
          (json['addresses'] as List? ?? [])
              .map((e) => Address.fromJson(e))
              .toList(),
      reviews:
          (json['reviews'] as List? ?? [])
              .map((e) => Review.fromJson(e))
              .toList(),
      orderIds: List<String>.from(json['orderIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'favoriteStoreIds': favoriteStoreIds,
    'addresses': addresses.map((e) => e.toJson()).toList(),
    'reviews': reviews.map((e) => e.toJson()).toList(),
    'orderIds': orderIds,
  };

  BuyerModel copyWith({
    String? uid,
    List<String>? favoriteStoreIds,
    List<Address>? addresses,
    List<Review>? reviews,
    List<String>? orderIds,
  }) {
    return BuyerModel(
      uid: uid ?? this.uid,
      favoriteStoreIds: favoriteStoreIds ?? this.favoriteStoreIds,
      addresses: addresses ?? this.addresses,
      reviews: reviews ?? this.reviews,
      orderIds: orderIds ?? this.orderIds,
    );
  }
}

class Address {
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Address({
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    label: json['label'],
    address: json['address'],
    latitude: (json['latitude'] as num?)!.toDouble(),
    longitude: (json['longitude'] as num?)!.toDouble(),
    isDefault: json['isDefault'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'label': label,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
  };

  Address copyWith({
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class Review {
  final String userId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    userId: json['userId'],
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };
}
