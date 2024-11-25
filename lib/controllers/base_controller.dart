import 'package:get/get.dart';

/// 基础控制器类，提供通用的状态管理功能
class BaseController extends GetxController {
  // 加载状态
  final isLoading = false.obs;
  // 错误状态
  final hasError = false.obs;
  // 错误信息
  final errorMessage = ''.obs;

  /// 开始加载
  void startLoading() {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
  }

  /// 停止加载
  void stopLoading() {
    isLoading.value = false;
  }

  /// 处理错误
  void handleError(dynamic error) {
    hasError.value = true;
    errorMessage.value = error.toString();
    stopLoading();
  }
}
