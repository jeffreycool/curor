import 'package:isar/isar.dart';
import 'note.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  String? name;

  @Index()
  DateTime? createdAt;

  @Backlink(to: 'category')
  final notes = IsarLinks<Note>();

  Category({
    this.name,
    DateTime? createdAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }
}
