import 'package:hive/hive.dart';
import '../product.dart';

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 4; // Đảm bảo unique, khác với các adapter khác

  @override
  ProductModel read(BinaryReader reader) {
    return ProductModel(
      id: reader.readString(),
      storeId: reader.readString(),
      name: reader.readString(),
      description: reader.readString(),
      category: reader.readString(),
      price: reader.readDouble(),
      unit: reader.readString(),
      quantity: reader.readInt(),
      imageUrl: reader.readString(),
      promotion: reader.readString(),
      promotionPrice: reader.readDouble(),
      promotionEndDate: reader.readString().isNotEmpty ? DateTime.parse(reader.readString()) : null,
      tags: reader.readStringList(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.storeId);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeString(obj.category);
    writer.writeDouble(obj.price);
    writer.writeString(obj.unit);
    writer.writeInt(obj.quantity);
    writer.writeString(obj.imageUrl);
    writer.writeString(obj.promotion ?? '');
    writer.writeDouble(obj.promotionPrice ?? 0.0);
    writer.writeString(obj.promotionEndDate?.toIso8601String() ?? '');
    writer.writeList(obj.tags);
  }
}
