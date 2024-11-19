import 'package:isar/isar.dart';
import '../core/base/base_repository.dart';
import '../models/note.dart';

class NoteRepository extends BaseRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  // 获取所有笔记
  Stream<List<Note>> getAllNotes() {
    return isar.notes
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // 保存笔记
  Future<void> saveNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
      await note.category.save();
      await note.tags.save();
    });
    clearCache();
  }

  // 删除笔记
  Future<void> deleteNote(Id id) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(id);
    });
    clearCache();
  }

  // 搜索笔记
  Stream<List<Note>> searchNotes(String query) {
    if (query.isEmpty) return getAllNotes();

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
}
