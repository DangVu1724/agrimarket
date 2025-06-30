import 'package:agrimarket/data/models/store.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StoreAddressAdapter extends TypeAdapter<StoreAddress> {
  @override
  final int typeId = 1;

  @override
  StoreAddress read(BinaryReader reader) {
    return StoreAddress(
      label: reader.readString(),
      address: reader.readString(),
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, StoreAddress obj) {
    writer.writeString(obj.label);
    writer.writeString(obj.address);
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
}
