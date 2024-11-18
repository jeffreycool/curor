import 'package:get/get.dart';
import '../../controllers/tags_controller.dart';
import '../../services/tag_service.dart';

class TagsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TagService());
    Get.lazyPut(() => TagsController(Get.find()));
  }
}
