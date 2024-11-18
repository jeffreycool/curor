import 'package:isar/isar.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/tag.dart';

class DatabaseService {
  final Isar isar;

  DatabaseService(this.isar);

  // 笔记相关操作
  Future<void> saveNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
      await note.category.save();
      await note.tags.save();
    });
  }

  // 按标题搜索笔记
  Stream<List<Note>> searchNotes(String query) {
    return isar.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // 获取置顶笔记
  Stream<List<Note>> getPinnedNotes() {
    return isar.notes
        .filter()
        .isPinnedEqualTo(true)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // 按分类获取笔记
  Stream<List<Note>> getNotesByCategory(Category category) {
    return isar.notes
        .filter()
        .category((q) => q.idEqualTo(category.id))
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // 按标签获取笔记
  Stream<List<Note>> getNotesByTag(Tag tag) {
    return isar.notes
        .filter()
        .tags((q) => q.idEqualTo(tag.id))
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // 分类操作
  Future<void> saveCategory(Category category) async {
    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  Stream<List<Category>> getAllCategories() {
    return isar.categorys.where().sortByName().watch(fireImmediately: true);
  }

  // 标签操作
  Future<void> saveTag(Tag tag) async {
    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
  }

  Stream<List<Tag>> getAllTags() {
    return isar.tags.where().sortByName().watch(fireImmediately: true);
  }

  // 统计信息
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

  // 批量操作示例
  Future<void> batchDeleteNotes(List<Note> notes) async {
    await isar.writeTxn(() async {
      await isar.notes.deleteAll(notes.map((e) => e.id).toList());
    });
  }

  // 高级查询示例：获取最近7天的笔记统计
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
