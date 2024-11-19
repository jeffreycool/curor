import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'translations/app_translations.dart';
import 'services/base/isar_service.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Isar 数据库服务
  await IsarService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 GetMaterialApp 替代 MaterialApp 以支持 GetX 功能
    return GetMaterialApp(
      title: 'app_title'.tr, // 使用国际化翻译
      translations: AppTranslations(), // 注册翻译服务
      locale: Get.deviceLocale, // 使用设备语言
      fallbackLocale: const Locale('en', 'US'), // 设置默认语言
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // 使用 Material 3 设计
      ),
      initialRoute: AppPages.INITIAL, // 设置初始路由
      getPages: AppPages.routes, // 注册所有路由
    );
  }
}
