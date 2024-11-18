import 'package:get/get.dart';
import '../../controllers/categories_controller.dart';
import '../../services/category_service.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoryService());
    Get.lazyPut(() => CategoriesController(Get.find()));
  }
}
