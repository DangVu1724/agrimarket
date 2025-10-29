import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? hotSaleId;
  final DateTime? createdAt;
  final double? rating;
  final int? totalReviews;
  final List<Review> reviews;
  final DateTime? updatedAt;
  final List<String>? fcmTokens;
  final List<String>? tags;
  final int orderCount;

  StoreModel({
    required this.storeId,
    required this.ownerUid,
    required this.name,
    required this.description,
    required this.categories,
    required this.storeLocation,
    this.orderCount = 0,
    this.businessLicenseUrl,
    this.foodSafetyCertificateUrl,
    this.storeImageUrl,
    this.state = 'pending',
    this.isOpened = false,
    this.isPromotion = false,
    this.createdAt,
    this.hotSaleId,
    this.rating,
    this.totalReviews,
    this.reviews = const [],
    this.updatedAt,
    this.fcmTokens,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'ownerUid': ownerUid,
    'name': name,
    'description': description,
    'orderCount': orderCount,
    'categories': categories,
    'storeLocation': storeLocation.toJson(),
    'state': state,
    'businessLicenseUrl': businessLicenseUrl,
    'foodSafetyCertificateUrl': foodSafetyCertificateUrl,
    'storeImageUrl': storeImageUrl,
    'isOpened': isOpened,
    'isPromotion': isPromotion,
    'hotSaleId': hotSaleId,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    'rating': rating,
    'totalReviews': totalReviews,
    'reviews': reviews.map((e) => e.toJson()).toList(),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    'fcmTokens': fcmTokens,
    'tags': tags,

  };

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    storeId: json['storeId'],
    ownerUid: json['ownerUid'],
    name: json['name'],
    description: json['description'],
    categories: List<String>.from(json['categories']),

    storeLocation: StoreAddress.fromJson(Map<String, dynamic>.from(json['storeLocation'])),
    orderCount: json['orderCount'] ?? 0,
    businessLicenseUrl: json['businessLicenseUrl'],
    foodSafetyCertificateUrl: json['foodSafetyCertificateUrl'],
    storeImageUrl: json['storeImageUrl'],
    state: json['state'] ?? 'pending',
    isOpened: json['isOpened'] ?? false,
    isPromotion: json['isPromotion'] ?? false,
    hotSaleId: json['hotSaleId'] ?? '',
    createdAt:
        json['createdAt'] != null
            ? (json['createdAt'] is Timestamp
                ? (json['createdAt'] as Timestamp).toDate()
                : DateTime.tryParse(json['createdAt'].toString()))
            : null,
    rating: json['rating'],
    totalReviews: json['totalReviews'],
    reviews: (json['reviews'] as List? ?? []).map((e) => Review.fromJson(e)).toList(),
    updatedAt:
        json['updatedAt'] != null
            ? (json['updatedAt'] is Timestamp
                ? (json['updatedAt'] as Timestamp).toDate()
                : DateTime.tryParse(json['updatedAt'].toString()))
            : null,
    fcmTokens: json['fcmTokens'] != null ? List<String>.from(json['fcmTokens']) : null,
    tags: json['tags'] != null ? List<String>.from(json['tags']) : null,

  );

  StoreModel copyWith({
    String? storeId,
    String? ownerUid,
    String? name,
    String? description,
    List<String>? categories,
    StoreAddress? storeLocation,
    int? orderCount,
    String? businessLicenseUrl,
    String? foodSafetyCertificateUrl,
    String? storeImageUrl,
    String? state,
    bool? isOpened,
    bool? isPromotion,
    String? hotSaleId,
    DateTime? createdAt,
    double? rating,
    int? totalReviews,
    List<Review>? reviews,
    DateTime? updatedAt,
    List<String>? fcmTokens,
    List<String>? tags,
  }) {
    return StoreModel(
      storeId: storeId ?? this.storeId,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      orderCount: orderCount ?? this.orderCount,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      storeLocation: storeLocation ?? this.storeLocation,
      businessLicenseUrl: businessLicenseUrl ?? this.businessLicenseUrl,
      foodSafetyCertificateUrl: foodSafetyCertificateUrl ?? this.foodSafetyCertificateUrl,
      storeImageUrl: storeImageUrl ?? this.storeImageUrl,
      state: state ?? this.state,
      isOpened: isOpened ?? this.isOpened,
      isPromotion: isPromotion ?? this.isPromotion,
      hotSaleId: hotSaleId ?? this.hotSaleId,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      reviews: reviews ?? this.reviews,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      tags: tags ?? this.tags,
    );
  }

  List<double>? getDefaultLatLng() {
    return [storeLocation.latitude, storeLocation.longitude];
  }

  double? getAverageRating() {
    if (reviews.isEmpty) return null;
    return reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;
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

class Review {
  final String reviewId;
  final String buyerUid;
  final String storeId;
  final String orderId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? reviewImages;

  Review({
    required this.reviewId,
    required this.buyerUid,
    required this.storeId,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.reviewImages,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        reviewId: json['reviewId'] ?? '',
        buyerUid: json['buyerUid'] ?? '',
        storeId: json['storeId'] ?? '',
        orderId: json['orderId'] ?? '',
        rating: (json['rating'] ?? 0).toDouble(),
        comment: json['comment'] ?? '',
        reviewImages: json['reviewImages'] != null
            ? List<String>.from(json['reviewImages'])
            : [],
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'reviewId': reviewId,
        'buyerUid': buyerUid,
        'storeId': storeId,
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
        'reviewImages': reviewImages ?? [],
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

