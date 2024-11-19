import 'package:get/get.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../services/note_service.dart';
import 'base_controller.dart';

/// 笔记控制器，处理笔记相关的业务逻辑
class NotesController extends BaseController {
  final NoteService noteService;

  NotesController(this.noteService);

  // 笔记列表
  final notes = <Note>[].obs;
  // 搜索关键词
  final searchQuery = ''.obs;
  // 选中的分类
  final selectedCategory = Rxn<Category>();
  // 选中的标签集合
  final selectedTags = <Tag>{}.obs;
  // 是否置顶
  final isPinned = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotes(); // 初始化时加载笔记
  }

  /// 加载所有笔记
  void _loadNotes() {
    startLoading();
    try {
      noteService.getAllNotes().listen(
        (notesList) {
          notes.value = notesList;
          stopLoading();
        },
        onError: handleError,
      );
    } catch (e) {
      handleError(e);
    }
  }

  /// 添加新笔记
  Future<void> addNote(String title, String content) async {
    startLoading();
    try {
      final note = Note()
        ..title = title
        ..content = content
        ..createdAt = DateTime.now()
        ..isPinned = isPinned.value;

      // 设置分类
      if (selectedCategory.value != null) {
        note.category.value = selectedCategory.value;
      }

      // 设置标签
      note.tags.addAll(selectedTags);

      await noteService.saveNote(note);
      stopLoading();
      Get.back();
      Get.snackbar('success'.tr, 'note_added'.tr);
    } catch (e) {
      handleError(e);
    }
  }

  /// 删除笔记
  Future<void> deleteNote(Note note) async {
    try {
      await noteService.isar.writeTxn(() async {
        await noteService.isar.notes.delete(note.id);
      });
    } catch (e) {
      handleError(e);
    }
  }
}
