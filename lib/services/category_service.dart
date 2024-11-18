import 'package:isar/isar.dart';
import '../models/category.dart';
import '../models/note.dart';
import 'base/isar_service.dart';

class CategoryService {
  final isar = IsarService.instance.isar;

  // 保存分类
  Future<void> saveCategory(Category category) async {
    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  // 获取所有分类
  Stream<List<Category>> getAllCategories() {
    return isar.categorys.where().sortByName().watch(fireImmediately: true);
  }

  // 删除分类
  Future<void> deleteCategory(Id id) async {
    await isar.writeTxn(() async {
      await isar.categorys.delete(id);
    });
  }

  // 获取分类下的笔记
  Stream<List<Note>> getNotesByCategory(Category category) {
    return isar.notes
        .filter()
        .category((q) => q.idEqualTo(category.id))
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }
}
