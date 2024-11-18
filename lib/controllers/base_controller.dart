import 'package:get/get.dart';

class BaseController extends GetxController {
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
}
