import 'package:get/get.dart';
import '../../controllers/notes_controller.dart';
import '../../services/note_service.dart';

class NotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoteService());
    Get.lazyPut(() => NotesController(Get.find()));
  }
}
