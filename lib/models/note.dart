import 'package:isar/isar.dart';
import 'category.dart';
import 'tag.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  String? title;

  String? content;

  @Index()
  DateTime? createdAt;

  @Index()
  DateTime? updatedAt;

  final category = IsarLink<Category>();
  final tags = IsarLinks<Tag>();

  Note({
    this.title,
    this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }
}
