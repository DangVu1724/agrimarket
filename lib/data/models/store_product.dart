import 'package:agrimarket/data/models/product.dart';
import 'package:agrimarket/data/models/store.dart';

class ProductModelWithStore {
  final ProductModel product;
  final StoreModel? store;

  ProductModelWithStore({
    required this.product,
    this.store,
  });

  double getPrice(){
    return product.price;
  }
  int getSold(){
    return product.totalSold;
  }
  String getStore(){
    return store!.name;
  }
}
