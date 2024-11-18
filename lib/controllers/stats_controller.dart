import 'package:get/get.dart';
import '../services/stats_service.dart';
import 'base_controller.dart';

class StatsController extends BaseController {
  final StatsService statsService;

  StatsController(this.statsService);

  final statistics = RxMap<String, int>();
  final weeklyStats = RxMap<DateTime, int>();

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    startLoading();
    try {
      statistics.value = await statsService.getStatistics();
      weeklyStats.value = await statsService.getLastWeekNotesCount();
      stopLoading();
    } catch (e) {
      handleError(e);
    }
  }
}
