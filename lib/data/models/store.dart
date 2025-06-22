class StoreModel {
  final String storeId;
  final String ownerUid;
  final String name;
  final String description;
  final List<String> categories;
  final String address;
  final String? businessLicenseUrl;
  final String? foodSafetyCertificateUrl;
  final String? storeImageUrl ;
  final String state;
  final bool isOpened;
  

  StoreModel({
    required this.storeId,
    required this.ownerUid,
    required this.name,
    required this.description,
    required this.categories,
    required this.address,
    this.businessLicenseUrl,
    this.foodSafetyCertificateUrl,
    this.storeImageUrl ,
    this.state = 'pending',
    this.isOpened = false,
  });

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'ownerUid': ownerUid,
    'name': name,
    'description': description,
    'categories': categories,
    'address': address,
    'state': state,
    'businessLicenseUrl': businessLicenseUrl,
    'foodSafetyCertificateUrl': foodSafetyCertificateUrl,
    'storeImageUrl ': storeImageUrl ,
    'isOpened': isOpened,
  };

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
    storeId: json['storeId'],
    ownerUid: json['ownerUid'],
    name: json['name'],
    description: json['description'],
    categories: List<String>.from(json['categories']),
    address: json['address'],
    businessLicenseUrl: json['businessLicenseUrl'],
    foodSafetyCertificateUrl: json['foodSafetyCertificateUrl'],
    storeImageUrl : json['storeImageUrl '],
    state: json['state'] ?? 'pending',
    isOpened: json['isOpened'] ?? false,
  );
}
