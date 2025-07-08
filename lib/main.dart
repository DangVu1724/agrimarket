import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_theme.dart';
import 'package:agrimarket/core/utils/cache_utils.dart';
import 'package:agrimarket/core/widgets/error_boundary.dart';
import 'package:agrimarket/data/models/adapter/store_address.dart';
import 'package:agrimarket/data/models/adapter/store_model_adapter.dart';
import 'package:agrimarket/data/models/adapter/user_model_adapter.dart';
import 'package:agrimarket/data/models/adapter/product_model_adapter.dart';
import 'package:agrimarket/data/models/adapter/timestamp_adapter.dart';
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

  // Clear cache on app start to prevent corruption issues
  await CacheUtils.clearAllCache();

  // Register adapters
  try {
    Hive.registerAdapter(StoreModelAdapter());
    Hive.registerAdapter(StoreAddressAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(TimestampAdapter());
  } catch (e) {
    print('Error registering adapters: $e');
  }

  // Open boxes with error handling
  await CacheUtils.openAllBoxes();

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
    return ErrorBoundary(
      child: GetMaterialApp(
        title: 'Chợ Nông Sản Sạch',
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
      ),
    );
  }
}
