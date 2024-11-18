import 'package:get/get.dart';
import '../views/home/home_view.dart';
import '../views/home/home_binding.dart';
import '../views/notes/notes_view.dart';
import '../views/notes/notes_binding.dart';
import '../views/categories/categories_view.dart';
import '../views/categories/categories_binding.dart';
import '../views/tags/tags_view.dart';
import '../views/tags/tags_binding.dart';
import '../views/stats/stats_view.dart';
import '../views/stats/stats_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.NOTES,
      page: () => const NotesView(),
      binding: NotesBinding(),
    ),
    GetPage(
      name: Routes.CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: Routes.TAGS,
      page: () => const TagsView(),
      binding: TagsBinding(),
    ),
    GetPage(
      name: Routes.STATS,
      page: () => const StatsView(),
      binding: StatsBinding(),
    ),
  ];
}
