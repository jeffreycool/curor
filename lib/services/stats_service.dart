import 'package:isar/isar.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/tag.dart';
import 'base/isar_service.dart';

class StatsService {
  final isar = IsarService.instance.isar;

  // 获取统计信息
  Future<Map<String, int>> getStatistics() async {
    final notesCount = await isar.notes.count();
    final categoriesCount = await isar.categorys.count();
    final tagsCount = await isar.tags.count();

    return {
      'notes': notesCount,
      'categories': categoriesCount,
      'tags': tagsCount,
    };
  }

  // 获取最近7天的笔记统计
  Future<Map<DateTime, int>> getLastWeekNotesCount() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final notes =
        await isar.notes.filter().createdAtBetween(weekAgo, now).findAll();

    final Map<DateTime, int> dailyCounts = {};
    for (var i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      dailyCounts[dayStart] =
          notes.where((note) => note.createdAt.day == dayStart.day).length;
    }

    return dailyCounts;
  }
}
