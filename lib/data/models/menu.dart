class MenuModel {
  final String storeId;
  final List<MenuGroup> groups;

  MenuModel({
    required this.storeId,
    required this.groups,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
        storeId: json['storeId'] ?? '',
        groups: (json['groups'] as List? ?? [])
            .map((e) => MenuGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'storeId': storeId,
        'groups': groups.map((e) => e.toJson()).toList(),
      };
}

class MenuGroup {
  final String title;
  final String description;
  final List<String> productIds;

  MenuGroup({
    required this.title,
    this.description = '',
    required this.productIds,
  });

  factory MenuGroup.fromJson(Map<String, dynamic> json) => MenuGroup(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        productIds: List<String>.from(json['productIds'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'productIds': productIds,
      };
}