import 'package:isar/isar.dart';
import 'note.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  @Backlink(to: 'category')
  final notes = IsarLinks<Note>();
}
