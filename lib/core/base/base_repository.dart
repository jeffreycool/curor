import 'package:isar_demo/services/base/isar_service.dart';

/// 基础仓库类
abstract class BaseRepository {
  final isar = IsarService.instance.isar;

  /// 清除缓存
  void clearCache() {
    IsarService.instance.clearCache();
  }
}
