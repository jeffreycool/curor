import 'package:isar/isar.dart';
import '../models/note.dart';
import 'base/isar_service.dart';

class NoteService {
  final isar = IsarService.instance.isar;

  // 缓存键
  static const String _recentNotesKey = 'recent_notes';
  static const String _pinnedNotesKey = 'pinned_notes';

  // 保存笔记
  Future<void> saveNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
      await note.category.save();
      await note.tags.save();
    });
    // 清除相关缓存
    IsarService.instance.clearCache();
  }

  // 获取所有笔记（带缓存）
  Stream<List<Note>> getAllNotes() {
    final cached =
        IsarService.instance.getFromCache<List<Note>>(_recentNotesKey);
    if (cached != null) {
      return Stream.value(cached);
    }

    return isar.notes
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((notes) {
      // 缓存结果
      IsarService.instance.setCache(_recentNotesKey, notes);
      return notes;
    });
  }

  // 批量保存笔记
  Future<void> saveNotes(List<Note> notes) async {
    await IsarService.instance.batchOperation(
      notes,
      (note) async {
        await isar.notes.put(note);
        await note.category.save();
        await note.tags.save();
      },
    );
    IsarService.instance.clearCache();
  }

  // 搜索笔记（优化查询）
  Stream<List<Note>> searchNotes(String query) {
    if (query.isEmpty) {
      return getAllNotes();
    }

    return isar.notes
        .filter()
        .optional(
          query.isNotEmpty,
          (q) => q
              .titleContains(query, caseSensitive: false)
              .or()
              .contentContains(query, caseSensitive: false),
        )
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // 获取置顶笔记（带缓存）
  Stream<List<Note>> getPinnedNotes() {
    final cached =
        IsarService.instance.getFromCache<List<Note>>(_pinnedNotesKey);
    if (cached != null) {
      return Stream.value(cached);
    }

    return isar.notes
        .filter()
        .isPinnedEqualTo(true)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((notes) {
      IsarService.instance.setCache(_pinnedNotesKey, notes);
      return notes;
    });
  }

  // 批量删除笔记
  Future<void> batchDeleteNotes(List<Note> notes) async {
    await IsarService.instance.batchOperation(
      notes,
      (note) async => await isar.notes.delete(note.id),
    );
    IsarService.instance.clearCache();
  }

  // 导出加密的笔记
  Future<List<Map<String, dynamic>>> exportNotes() async {
    final notes = await isar.notes.where().findAll();
    return notes
        .map((note) => {
              'id': note.id,
              'title': note.encryptedTitle,
              'content': note.encryptedContent,
              'createdAt': note.createdAt.toIso8601String(),
              'isPinned': note.isPinned,
              'category': note.category.value?.name,
              'tags': note.tags.map((tag) => tag.name).toList(),
            })
        .toList();
  }

  // 导入加密的笔记
  Future<void> importNotes(List<Map<String, dynamic>> data) async {
    final notes = data
        .map((item) => Note()
          ..encryptedTitle = item['title']
          ..encryptedContent = item['content']
          ..createdAt = DateTime.parse(item['createdAt'])
          ..isPinned = item['isPinned'])
        .toList();

    await saveNotes(notes);
  }
}
