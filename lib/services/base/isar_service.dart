import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/note.dart';
import '../../models/category.dart';
import '../../models/tag.dart';
import '../encryption_service.dart';

/// Isar 数据库服务基类，提供数据库的基础功能
class IsarService {
  static late final IsarService instance;
  late final Isar isar;

  /// 初始化数据库
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    // 初始化加密服务
    await EncryptionService.initialize('your_secret_key_here');

    // 配置并打开 Isar 实例
    final isar = await Isar.open(
      [NoteSchema, CategorySchema, TagSchema],
      directory: dir.path,
      name: 'encrypted_db',
      maxSizeMiB: 512, // 设置数据库最大大小
      inspector: false, // 禁用检查器以提高性能
    );

    instance = IsarService._(isar);
  }

  IsarService._(this.isar);

  // 清除所有数据
  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  // 关闭数据库
  Future<void> close() async {
    await isar.close();
  }

  // 备份数据库
  Future<void> backup(String path) async {
    await isar.copyToFile(path);
  }

  // 从备份恢复
  Future<void> restore(String path) async {
    await close();
    // 重新打开数据库
    await initialize();
  }

  // 数据库维护
  Future<void> maintenance() async {
    await isar.writeTxn(() async {
      // 在事务中执行维护操作
      await isar.clear(); // 清理数据库
      await isar.copyToFile('backup.isar'); // 创建备份
    });
  }

  // 处理数据库损坏
  Future<void> _handleCorruption() async {
    // 1. 尝试从最近的备份恢复
    // 2. 如果没有备份，重新初始化数据库
    await clearAllData();
    await initialize();
  }

  // 批量操作优化
  Future<void> batchOperation<T>(
    List<T> items,
    Future<void> Function(T item) operation,
  ) async {
    const batchSize = 100; // 每批处理100条数据

    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      final batch = items.sublist(i, end);

      await isar.writeTxn(() async {
        for (final item in batch) {
          await operation(item);
        }
      });
    }
  }

  // 缓存管理
  final _cache = <String, dynamic>{};
  final _cacheExpiry = <String, DateTime>{};

  T? getFromCache<T>(String key) {
    final expiry = _cacheExpiry[key];
    if (expiry != null && expiry.isAfter(DateTime.now())) {
      return _cache[key] as T?;
    }
    _cache.remove(key);
    _cacheExpiry.remove(key);
    return null;
  }

  void setCache<T>(String key, T value, {Duration? expiry}) {
    _cache[key] = value;
    _cacheExpiry[key] =
        DateTime.now().add(expiry ?? const Duration(minutes: 5));
  }

  void clearCache() {
    _cache.clear();
    _cacheExpiry.clear();
  }
}
