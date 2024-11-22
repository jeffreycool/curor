import 'package:isar/isar.dart';
import 'note.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  String? name;

  @Index()
  DateTime? createdAt;

  @Backlink(to: 'tags')
  final notes = IsarLinks<Note>();

  Tag({
    this.name,
    DateTime? createdAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }
}
