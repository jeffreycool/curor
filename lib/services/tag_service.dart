import 'package:isar/isar.dart';
import '../models/tag.dart';
import '../models/note.dart';
import 'base/isar_service.dart';

class TagService {
  final isar = IsarService.instance.isar;

  // 保存标签
  Future<void> saveTag(Tag tag) async {
    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
  }

  // 获取所有标签
  Stream<List<Tag>> getAllTags() {
    return isar.tags.where().sortByName().watch(fireImmediately: true);
  }

  // 删除标签
  Future<void> deleteTag(Id id) async {
    await isar.writeTxn(() async {
      await isar.tags.delete(id);
    });
  }

  // 获取标签下的笔记
  Stream<List<Note>> getNotesByTag(Tag tag) {
    return isar.notes
        .filter()
        .tags((q) => q.idEqualTo(tag.id))
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }
}
