import 'package:get/get.dart';
import '../views/notes/note_view.dart';
import '../viewmodels/note_view_model.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => const NoteView(),
      binding: BindingsBuilder(() {
        Get.put(NoteViewModel());
      }),
    ),
  ];
}
