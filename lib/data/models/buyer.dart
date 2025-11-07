import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerModel {
  final String uid;
  final int? points;
  final List<String> fcmTokens;
  final List<String> favoriteStoreIds;
  final List<Address> addresses;
  final int totalOrders;
  final int totalPointsEarned;
  final String rank;

  BuyerModel({
    required this.uid,
    this.points = 0,
    this.favoriteStoreIds = const [],
    this.addresses = const [],
    this.fcmTokens = const [],
    this.totalOrders = 0,
    this.totalPointsEarned = 0,
    this.rank = 'Bronze'
  });

  factory BuyerModel.fromJson(Map<String, dynamic> json) {
    return BuyerModel(
      uid: json['uid'] ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalPointsEarned: (json['totalPointsEarned'] as num?)?.toInt() ?? 0,
      rank: json['rank'] ?? 'Bronze',
      favoriteStoreIds: List<String>.from(json['favoriteStoreIds'] ?? []),
      addresses: (json['addresses'] as List? ?? [])
          .map((e) => Address.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      fcmTokens: List<String>.from(json['fcmTokens'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'points': points,
    'totalOrders': totalOrders,
    'totalPointsEarned': totalPointsEarned,
    'rank': rank,
    'favoriteStoreIds': favoriteStoreIds,
    'addresses': addresses.map((e) => e.toJson()).toList(),
    'fcmTokens': fcmTokens,
  };

  BuyerModel copyWith({
    String? uid,
    int? points,
    int? totalOrders,
    int? totalPointsEarned,
    String? rank,
    List<String>? favoriteStoreIds,
    List<Address>? addresses,
    List<String>? fcmTokens,
  }) {
    return BuyerModel(
      uid: uid ?? this.uid,
      points: points ?? this.points,
      totalOrders: totalOrders ?? this.totalOrders,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      rank: rank ?? this.rank,
      favoriteStoreIds: favoriteStoreIds ?? this.favoriteStoreIds,
      addresses: addresses ?? this.addresses,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  List<double>? getDefaultLatLng() {
    if (addresses.isEmpty) return null;

    final defaultAddress = addresses.firstWhere((addr) => addr.isDefault, orElse: () => addresses.first);

    return [defaultAddress.latitude, defaultAddress.longitude];
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

  Address copyWith({String? label, String? address, double? latitude, double? longitude, bool? isDefault}) {
    return Address(
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}


