import 'package:isar/isar.dart';
import '../core/base/base_repository.dart';
import '../models/note.dart';

class NoteRepository extends BaseRepository {
  // 获取所有笔记
  Stream<List<Note>> getAllNotes() {
    return isar.notes.where().watch(fireImmediately: true);
  }

  // 添加笔记
  Future<void> addNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }

  // 删除笔记
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(id);
    });
  }

  // 更新笔记
  Future<void> updateNote(Note note) async {
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
  }

  // 根据ID获取笔记
  Future<Note?> getNoteById(int id) async {
    return await isar.notes.get(id);
  }
}
