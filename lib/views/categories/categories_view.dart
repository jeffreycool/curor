import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/categories_controller.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('categories'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return ListTile(
              title: Text(category.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => controller.deleteCategory(category),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
