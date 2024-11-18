import 'package:isar/isar.dart';
import '../services/encryption_service.dart';
import 'category.dart';
import 'tag.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? _encryptedTitle;

  String? _encryptedContent;

  @Index()
  late DateTime createdAt;

  @Index(composite: [CompositeIndex('createdAt')])
  bool isPinned = false;

  final category = IsarLink<Category>();
  final tags = IsarLinks<Tag>();

  // 加密的标题
  String get title => _encryptedTitle != null
      ? EncryptionService.instance.decrypt(_encryptedTitle!)
      : '';

  set title(String value) {
    _encryptedTitle = EncryptionService.instance.encrypt(value);
  }

  // 加密的内容
  String get content => _encryptedContent != null
      ? EncryptionService.instance.decrypt(_encryptedContent!)
      : '';

  set content(String value) {
    _encryptedContent = EncryptionService.instance.encrypt(value);
  }

  // 添加这些 getter 和 setter 来访问加密字段
  String? get encryptedTitle => _encryptedTitle;
  set encryptedTitle(String? value) => _encryptedTitle = value;

  String? get encryptedContent => _encryptedContent;
  set encryptedContent(String? value) => _encryptedContent = value;

  @Index(caseSensitive: false, type: IndexType.value)
  List<String> get searchableContent => [title, content];
}
