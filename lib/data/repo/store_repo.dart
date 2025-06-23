import 'package:agrimarket/data/models/store.dart';
import 'package:agrimarket/data/providers/firestore_provider.dart';

class StoreRepository {
  final FirestoreProvider _firestoreProvider = FirestoreProvider();

  Future<void> createStore(StoreModel store) async {
    await _firestoreProvider.createStore(store);
  }

  Future<void> updateStore(StoreModel store) async {
    await _firestoreProvider.updateStore(store);
  }
}