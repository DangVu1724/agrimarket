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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_pages.dart';
import 'package:intl/date_symbol_data_local.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN', null);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  await CacheUtils.clearAllCache();

  try {
    Hive.registerAdapter(StoreModelAdapter());
    Hive.registerAdapter(StoreAddressAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(TimestampAdapter());
  } catch (e) {
    print('Error registering adapters: $e');
  }

  await CacheUtils.openAllBoxes();

  final isHealthy = await CacheUtils.isCacheHealthy();
  if (!isHealthy) {
    await CacheUtils.cleanExpiredCache();
  }

  // ✅ Cách khởi tạo Firebase an toàn tuyệt đối
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } else {
      Firebase.app(); // Dùng lại app mặc định
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('⚠️ Firebase app đã tồn tại, bỏ qua khởi tạo lại.');
    } else {
      rethrow;
    }
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading dotenv: $e');
  }

  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("📩 Foreground FCM: ${message.notification?.title}");

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Thông báo',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "Thông báo",
      message.notification?.body ?? "",
      platformDetails,
      payload: message.data['orderId'],
    );
  });

  final backgroundService = BackgroundPromotionService();
  backgroundService.startBackgroundService();

  Get.put(backgroundService, permanent: true);
  _scheduleCacheCleanup();
  Get.put(NetworkService(), permanent: true);

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('⚠️ Firebase background app đã tồn tại, bỏ qua khởi tạo lại.');
    } else {
      rethrow;
    }
  }

  print("📩 Background FCM: ${message.notification?.title}");
}

void _scheduleCacheCleanup() {
  Future.delayed(const Duration(hours: 6), () async {
    await CacheUtils.cleanExpiredCache();
    _scheduleCacheCleanup();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: GetMaterialApp(
            title: 'Chợ Nông Sản Sạch',
            initialRoute: AppRoutes.splash,
            getPages: AppPages.pages,
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
          ),
        );
      },
    );
  }
}
