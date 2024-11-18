import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tags_controller.dart';

class TagsView extends GetView<TagsController> {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tags'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: controller.tags.map((tag) {
              return Chip(
                label: Text(tag.name),
                onDeleted: () => controller.deleteTag(tag),
              );
            }).toList(),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddTagDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
