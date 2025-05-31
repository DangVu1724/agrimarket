import 'package:agrimarket/app/routes/app_routes.dart';
import 'package:agrimarket/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';


void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await dotenv.load(fileName: ".env");
    print('dotenv loaded successfully');
    print('GITHUB_TOKEN: ${dotenv.env['GITHUB_TOKEN']}');
    print('GITHUB_OWNER: ${dotenv.env['GITHUB_OWNER']}');
    print('GITHUB_REPO: ${dotenv.env['GITHUB_REPO']}');
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
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      
    
    );
  }
}