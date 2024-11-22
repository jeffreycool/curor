import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar_demo/services/base/isar_service.dart';
import 'package:isar_demo/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Isar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Routes.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
