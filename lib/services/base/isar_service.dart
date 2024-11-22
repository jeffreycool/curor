import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/note.dart';

/// Isar 数据库服务基类，提供数据库的基础功能
class IsarService {
  IsarService._();
  static final IsarService instance = IsarService._();

  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema],
      directory: dir.path,
      name: 'notes_db',
    );
  }

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
    await init();
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
    await init();
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
