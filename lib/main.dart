import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'translations/app_translations.dart';
import 'services/base/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Isar 服务
  await IsarService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'app_title'.tr,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
