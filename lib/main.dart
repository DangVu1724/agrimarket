import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/app/theme/app_theme.dart';
import 'package:agrimarket/core/utils/cache_utils.dart';
import 'package:agrimarket/data/models/adapter/store_address.dart';
import 'package:agrimarket/data/models/adapter/store_model_adapter.dart';
import 'package:agrimarket/data/models/adapter/user_model_adapter.dart';
import 'package:agrimarket/data/models/adapter/product_model_adapter.dart';
import 'package:agrimarket/data/models/adapter/timestamp_adapter.dart';
import 'package:agrimarket/data/services/background_promotion_service.dart';
import 'package:agrimarket/data/services/network_service.dart';
import 'package:agrimarket/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_pages.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN', null);

  await Hive.initFlutter();
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

  // Check cache health
  final isHealthy = await CacheUtils.isCacheHealthy();
  if (!isHealthy) {
    print('⚠️ Cache health check failed, performing cleanup...');
    await CacheUtils.cleanExpiredCache();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading dotenv: $e');
  }

  // Khởi động background promotion service
  final backgroundService = BackgroundPromotionService();
  backgroundService.startBackgroundService();

  // Lưu service instance để có thể truy cập từ nơi khác
  Get.put(backgroundService, permanent: true);

  // Schedule periodic cache cleanup (every 6 hours)
  _scheduleCacheCleanup();

  // Khởi động network service
  Get.put(NetworkService(), permanent: true);

  runApp(const MyApp());
}

void _scheduleCacheCleanup() {
  Future.delayed(const Duration(hours: 6), () async {
    await CacheUtils.cleanExpiredCache();
    _scheduleCacheCleanup(); // Schedule next cleanup
  });
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
