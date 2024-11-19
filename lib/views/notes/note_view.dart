import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/note_view_model.dart';

class NoteView extends GetView<NoteViewModel> {
  const NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.init();

    return Scaffold(
      appBar: AppBar(
        title: Text('notes'.tr),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildNotesList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          labelText: 'search'.tr,
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            return Card(
              child: ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                      ),
                      onPressed: () => controller.togglePin(note),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => controller.deleteNote(note),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
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
              decoration: InputDecoration(labelText: 'title'.tr),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'content'.tr),
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
              controller.addNote(
                titleController.text,
                contentController.text,
              );
              Get.back();
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }
}
