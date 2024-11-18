import 'package:get/get.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'base_controller.dart';
import 'package:flutter/material.dart';

class CategoriesController extends BaseController {
  final CategoryService categoryService;

  CategoriesController(this.categoryService);

  final categories = <Category>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  void _loadCategories() {
    startLoading();
    try {
      categoryService.getAllCategories().listen(
        (categoriesList) {
          categories.value = categoriesList;
          stopLoading();
        },
        onError: handleError,
      );
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> deleteCategory(Category category) async {
    try {
      await categoryService.deleteCategory(category.id);
    } catch (e) {
      handleError(e);
    }
  }

  void showAddCategoryDialog() {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('add_category'.tr),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'name'.tr),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              final category = Category()..name = controller.text;
              await categoryService.saveCategory(category);
              Get.back();
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }
}
