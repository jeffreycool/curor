import 'package:get/get.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../services/note_service.dart';
import 'base_controller.dart';

class NotesController extends BaseController {
  final NoteService noteService;

  NotesController(this.noteService);

  final notes = <Note>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = Rxn<Category>();
  final selectedTags = <Tag>{}.obs;
  final isPinned = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotes();
  }

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

  Future<void> addNote(String title, String content) async {
    startLoading();
    try {
      final note = Note()
        ..title = title
        ..content = content
        ..createdAt = DateTime.now()
        ..isPinned = isPinned.value;

      if (selectedCategory.value != null) {
        note.category.value = selectedCategory.value;
      }

      note.tags.addAll(selectedTags);

      await noteService.saveNote(note);
      stopLoading();
      Get.back();
      Get.snackbar('success'.tr, 'note_added'.tr);
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      await noteService.isar.writeTxn(() async {
        await noteService.isar.notes.delete(note.id);
      });
    } catch (e) {
      handleError(e);
    }
  }

  // ... 其他方法
}
