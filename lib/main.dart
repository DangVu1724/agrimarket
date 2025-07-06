import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_theme.dart';
import 'package:agrimarket/data/models/adapter/store_address.dart';
import 'package:agrimarket/data/models/adapter/store_model_adapter.dart';
import 'package:agrimarket/data/models/adapter/user_model_adapter.dart';
import 'package:agrimarket/data/models/adapter/product_model_adapter.dart';
import 'package:agrimarket/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Comment out cache deletion to prevent crashes
  // await Hive.deleteBoxFromDisk('storeCache');
  // await Hive.deleteBoxFromDisk('userCache');
  // await Hive.deleteBoxFromDisk('productCache');
  // await Hive.deleteBoxFromDisk('menuCache');
  // await Hive.deleteBoxFromDisk('promotionCache');
  // await Hive.deleteBoxFromDisk('discountCodeCache');
  // await Hive.deleteBoxFromDisk('payment_method');

  Hive.registerAdapter(StoreModelAdapter());
  Hive.registerAdapter(StoreAddressAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ProductModelAdapter());
  await Hive.openBox('storeCache');
  await Hive.openBox('searchCache');
  await Hive.openBox('userCache');
  await Hive.openBox('productCache');
  await Hive.openBox('menuCache');
  await Hive.openBox('promotionCache');
  await Hive.openBox('discountCodeCache');
  await Hive.openBox('payment_method');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading dotenv: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chợ Nông Sản Sạch',
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
    );
  }
}
