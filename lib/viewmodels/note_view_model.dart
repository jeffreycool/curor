import 'package:get/get.dart';
import '../repositories/note_repository.dart';
import '../models/note.dart';

class NoteViewModel extends GetxController {
  final NoteRepository _repository = NoteRepository();
  final RxList<Note> notes = <Note>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  void loadNotes() {
    // 监听笔记流
    _repository.getAllNotes().listen((notesList) {
      notes.assignAll(notesList);
    });
  }

  // 其他方法...
}
