import 'package:hive/hive.dart';
import '../user.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 3; // Đảm bảo unique, khác với các adapter khác

  @override
  UserModel read(BinaryReader reader) {
    return UserModel(
      uid: reader.readString(),
      email: reader.readString(),
      name: reader.readString(),
      phone: reader.readString(),
      role: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeString(obj.uid);
    writer.writeString(obj.email);
    writer.writeString(obj.name);
    writer.writeString(obj.phone);
    writer.writeString(obj.role ?? 'buyer');
    writer.writeString(obj.createdAt.toIso8601String());
  }
}
