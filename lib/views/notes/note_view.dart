import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/note_view_model.dart';

class NoteView extends GetView<NoteViewModel> {
  const NoteView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记'),
      ),
      body: Center(
        child: Obx(() =>
            // 使用 controller 访问 ViewModel
            Text('笔记数量: ${controller.notes.length}')),
      ),
    );
  }
}
