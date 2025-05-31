class StoreModel {
  final String storeId;
  final String ownerUid;
  final String name;
  final String description;
  final List<String> categories;
  final String address;
  final String? businessLicenseUrl; 
  final String? foodSafetyCertificateUrl;
  final String state;

  StoreModel({
    required this.storeId,
    required this.ownerUid,
    required this.name,
    required this.description,
    required this.categories,
    required this.address,
    required this.businessLicenseUrl, 
    required this.foodSafetyCertificateUrl,
    this.state = 'pending',
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
    state: json['state'] ?? 'pending',
  );
}
