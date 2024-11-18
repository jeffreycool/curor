import 'package:get/get.dart';
import 'base_controller.dart';

class HomeController extends BaseController {
  // 可以添加首页需要的状态和方法
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
