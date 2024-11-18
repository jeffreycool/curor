import 'package:get/get.dart';
import '../../controllers/stats_controller.dart';
import '../../services/stats_service.dart';

class StatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StatsService());
    Get.lazyPut(() => StatsController(Get.find()));
  }
}
