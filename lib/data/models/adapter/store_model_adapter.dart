import 'package:hive/hive.dart';
import 'package:agrimarket/data/models/store.dart';

class StoreModelAdapter extends TypeAdapter<StoreModel> {
  @override
  final int typeId = 0; 

  @override
  StoreModel read(BinaryReader reader) {
    return StoreModel(
      storeId: reader.readString(),
      name: reader.readString(),
      address: reader.readString(),
      storeImageUrl: reader.readString(),
      isOpened: reader.readBool(),
      state: reader.readString(),
      ownerUid: reader.readString(),
      description: reader.readString(),
      categories: (reader.readList()).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreModel obj) {
    writer.writeString(obj.storeId);
    writer.writeString(obj.name);
    writer.writeString(obj.address);
    writer.writeString(obj.storeImageUrl ?? '');
    writer.writeBool(obj.isOpened);
    writer.writeString(obj.state);
    writer.writeString(obj.ownerUid);
    writer.writeString(obj.description);
    writer.writeList(obj.categories);
  }
}