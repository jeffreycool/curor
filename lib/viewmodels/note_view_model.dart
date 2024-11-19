import 'package:get/get.dart';
import '../core/base/base_view_model.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../repositories/note_repository.dart';

class NoteViewModel extends BaseViewModel {
  final _repository = NoteRepository();

  final notes = <Note>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = Rxn<Category>();
  final selectedTags = <Tag>{}.obs;
  final isPinned = false.obs;

  @override
  Future<void> init() async {
    _loadNotes();
    ever(searchQuery, (_) => _onSearchQueryChanged());
  }

  void _loadNotes() {
    startLoading();
    try {
      _repository.getAllNotes().listen(
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

  void _onSearchQueryChanged() {
    if (searchQuery.value.isEmpty) {
      _loadNotes();
      return;
    }

    startLoading();
    try {
      _repository.searchNotes(searchQuery.value).listen(
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
      await _repository.saveNote(note);

      stopLoading();
      Get.back();
      Get.snackbar('success'.tr, 'note_added'.tr);
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      await _repository.deleteNote(note.id);
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> togglePin(Note note) async {
    try {
      note.isPinned = !note.isPinned;
      await _repository.saveNote(note);
    } catch (e) {
      handleError(e);
    }
  }

  @override
  void dispose() {
    searchQuery.close();
    notes.close();
    super.dispose();
  }
}
