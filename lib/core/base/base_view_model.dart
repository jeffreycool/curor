import 'package:get/get.dart';

/// 基础视图模型类
abstract class BaseViewModel extends GetxController {
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  void startLoading() {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
  }

  void stopLoading() {
    isLoading.value = false;
  }

  void handleError(dynamic error) {
    hasError.value = true;
    errorMessage.value = error.toString();
    stopLoading();
  }

  /// 初始化数据
  Future<void> init();

  /// 释放资源
  void dispose();
}
