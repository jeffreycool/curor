import 'package:isar/isar.dart';
import '../models/note.dart';
import 'base/isar_service.dart';
import 'encryption_service.dart';

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

  // 删除笔记
  Future<void> deleteNote(Note note) async {
    await isar.writeTxn(() async {
      // 删除笔记与分类的关联
      await note.category.reset();
      // 删除笔记与标签的关联
      await note.tags.reset();
      // 删除笔记
      await isar.notes.delete(note.id);
    });
    // 清除相关缓存
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

  // 分页获取笔记
  Future<List<Note>> getNotesByPage({
    required int page,
    required int pageSize,
    String? searchQuery,
    bool isPinned = false,
  }) async {
    final query = isar.notes.where();

    // 添加固定状态筛选
    if (isPinned) {
      query.filter().isPinnedEqualTo(true);
    }

    // 添加搜索条件
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.filter().titleContains(searchQuery, caseSensitive: false);
    }

    // 计算偏移量
    final offset = page * pageSize;

    // 获取分页数据
    return await query
        .sortByCreatedAtDesc()
        .offset(offset)
        .limit(pageSize)
        .findAll();
  }

  // 获取笔记总数
  Future<int> getNoteCount({bool isPinned = false, String? searchQuery}) async {
    final query = isar.notes.where();

    if (isPinned) {
      query.filter().isPinnedEqualTo(true);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.filter().titleContains(searchQuery, caseSensitive: false);
    }

    return await query.count();
  }

  // 重新加密所有笔记
  Future<void> reEncryptAllNotes() async {
    try {
      print('Starting notes re-encryption...');
      final notes = await isar.notes.where().findAll();
      print('Found ${notes.length} notes to process');

      await isar.writeTxn(() async {
        for (final note in notes) {
          try {
            if (note.encryptedContent == null) {
              print('Skipping note ${note.id}: content is null');
              continue;
            }

            // 尝试解密内容（如果失败，则假设内容未加密）
            String decryptedContent;
            try {
              decryptedContent =
                  EncryptionService.instance.decrypt(note.encryptedContent!);
              print('Successfully decrypted note ${note.id}');
            } catch (e) {
              print(
                  'Decryption failed for note ${note.id}, treating as unencrypted');
              decryptedContent = note.encryptedContent!;
            }

            // 使用新密钥重新加密
            note.encryptedContent =
                EncryptionService.instance.encrypt(decryptedContent);
            await isar.notes.put(note);
            print('Successfully re-encrypted and saved note ${note.id}');
          } catch (e) {
            print('Failed to process note ${note.id}: $e');
            // 继续处理下一个笔记
            continue;
          }
        }
      });

      // 清除缓存
      IsarService.instance.clearCache();
      print('Re-encryption completed successfully');
    } catch (e) {
      print('Fatal error during re-encryption: $e');
      rethrow;
    }
  }
}
