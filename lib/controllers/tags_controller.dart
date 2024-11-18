import 'package:get/get.dart';
import '../models/tag.dart';
import '../services/tag_service.dart';
import 'base_controller.dart';
import 'package:flutter/material.dart';

class TagsController extends BaseController {
  final TagService tagService;

  TagsController(this.tagService);

  final tags = <Tag>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTags();
  }

  void _loadTags() {
    startLoading();
    try {
      tagService.getAllTags().listen(
        (tagsList) {
          tags.value = tagsList;
          stopLoading();
        },
        onError: handleError,
      );
    } catch (e) {
      handleError(e);
    }
  }

  Future<void> deleteTag(Tag tag) async {
    try {
      await tagService.deleteTag(tag.id);
    } catch (e) {
      handleError(e);
    }
  }

  void showAddTagDialog() {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('add_tag'.tr),
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
              final tag = Tag()..name = controller.text;
              await tagService.saveTag(tag);
              Get.back();
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }
}
