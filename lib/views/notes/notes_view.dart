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
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            return ListTile(
              title: Text(note.title),
              subtitle: Text(note.content),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => controller.deleteNote(note),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context),
        child: const Icon(Icons.add),
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
              decoration: InputDecoration(labelText: 'title'.tr),
            ),
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
