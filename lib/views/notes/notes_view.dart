import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notes_controller.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notes'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshNotes,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo is ScrollEndNotification &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                controller.loadMoreNotes();
              }
              return true;
            },
            child: ListView.builder(
              itemCount: controller.notes.length +
                  (controller.hasMoreData.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notes.length) {
                  return controller.isLoadingMore.value
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox();
                }

                final note = controller.notes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            note.isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            color: note.isPinned ? Colors.blue : null,
                          ),
                          onPressed: () => controller.togglePin(note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _showDeleteConfirmation(context, note),
                        ),
                      ],
                    ),
                    onTap: () => _showEditNoteDialog(context, note),
                  ),
                );
              },
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController =
        TextEditingController(text: controller.searchQuery.value);

    Get.dialog(
      AlertDialog(
        title: Text('search'.tr),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'search_hint'.tr,
            prefixIcon: const Icon(Icons.search),
          ),
          onSubmitted: (value) {
            controller.searchNotes(value);
            Get.back();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              controller.searchNotes(searchController.text);
              Get.back();
            },
            child: Text('search'.tr),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, note) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_confirmation'.tr),
        content: Text('delete_note_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteNote(note);
            },
            child: Text('delete'.tr),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('add_note'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'title'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'content'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                controller.addNote(
                  titleController.text,
                  contentController.text,
                );
                Get.back();
              }
            },
            child: Text('add'.tr),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    Get.dialog(
      AlertDialog(
        title: Text('edit_note'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'title'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'content'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                controller.updateNote(
                  note,
                  titleController.text,
                  contentController.text,
                );
                Get.back();
              }
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }
}
