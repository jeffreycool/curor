import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Get.toNamed('/notes'),
              child: Text('notes'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/categories'),
              child: Text('categories'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/tags'),
              child: Text('tags'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/stats'),
              child: Text('statistics'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
