import 'package:flutter/material.dart';
import 'models/note.dart';
import 'models/category.dart';
import 'models/tag.dart';
import 'services/base/isar_service.dart';
import 'services/note_service.dart';
import 'services/category_service.dart';
import 'services/tag_service.dart';
import 'services/stats_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Isar 服务
  await IsarService.initialize();

  // 创建各个服务实例
  final noteService = NoteService();
  final categoryService = CategoryService();
  final tagService = TagService();
  final statsService = StatsService();

  runApp(MyApp(
    noteService: noteService,
    categoryService: categoryService,
    tagService: tagService,
    statsService: statsService,
  ));
}

class MyApp extends StatelessWidget {
  final NoteService noteService;
  final CategoryService categoryService;
  final TagService tagService;
  final StatsService statsService;

  const MyApp({
    super.key,
    required this.noteService,
    required this.categoryService,
    required this.tagService,
    required this.statsService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isar 数据库演示',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(
        noteService: noteService,
        categoryService: categoryService,
        tagService: tagService,
        statsService: statsService,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final NoteService noteService;
  final CategoryService categoryService;
  final TagService tagService;
  final StatsService statsService;

  const HomePage({
    super.key,
    required this.noteService,
    required this.categoryService,
    required this.tagService,
    required this.statsService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // 添加这些 getter 来访问 widget 中的服务实例
  NoteService get noteService => widget.noteService;
  CategoryService get categoryService => widget.categoryService;
  TagService get tagService => widget.tagService;
  StatsService get statsService => widget.statsService;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Isar 数据库演示'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '所有笔记'),
              Tab(text: '分类管理'),
              Tab(text: '标签管理'),
              Tab(text: '统计信息'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            NotesTab(
              db: noteService,
              categoryService: categoryService,
              tagService: tagService,
            ),
            CategoriesTab(db: categoryService),
            TagsTab(db: tagService),
            StatsTab(db: statsService),
          ],
        ),
      ),
    );
  }
}

// 笔记标签页
class NotesTab extends StatefulWidget {
  final NoteService db;
  final CategoryService categoryService;
  final TagService tagService;

  const NotesTab({
    super.key,
    required this.db,
    required this.categoryService,
    required this.tagService,
  });

  @override
  State<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab>
    with AutomaticKeepAliveClientMixin {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final searchController = TextEditingController();
  Category? selectedCategory;
  final selectedTags = <Tag>{};
  bool isPinned = false;
  late Stream<List<Note>> notesStream;

  @override
  void initState() {
    super.initState();
    notesStream = widget.db.getAllNotes().asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: '搜索笔记',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  notesStream = (value.isEmpty
                          ? widget.db.getAllNotes()
                          : widget.db.searchNotes(value))
                      .asBroadcastStream();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: notesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data!;
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _buildNoteCard(note);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                  onPressed: () => _toggleNotePin(note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteNote(note),
                ),
              ],
            ),
          ),
          if (note.category.value != null || note.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  if (note.category.value != null)
                    Chip(label: Text(note.category.value!.name)),
                  ...note.tags.map((tag) => Chip(label: Text(tag.name))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addNote() async {
    final note = Note()
      ..title = titleController.text
      ..content = contentController.text
      ..createdAt = DateTime.now()
      ..isPinned = isPinned;

    if (selectedCategory != null) {
      note.category.value = selectedCategory;
    }

    note.tags.addAll(selectedTags);

    await widget.db.saveNote(note);

    titleController.clear();
    contentController.clear();
    setState(() {
      selectedCategory = null;
      selectedTags.clear();
      isPinned = false;
    });
  }

  Future<void> _deleteNote(Note note) async {
    await widget.db.isar.writeTxn(() async {
      await widget.db.isar.notes.delete(note.id);
    });
  }

  Future<void> _toggleNotePin(Note note) async {
    note.isPinned = !note.isPinned;
    await widget.db.saveNote(note);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新笔记'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '标题'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: '内容'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Category>>(
                stream: widget.categoryService
                    .getAllCategories()
                    .asBroadcastStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButton<Category>(
                    value: selectedCategory,
                    hint: const Text('选择分类'),
                    items: snapshot.data!.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Tag>>(
                stream: widget.tagService.getAllTags().asBroadcastStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Wrap(
                    spacing: 8.0,
                    children: snapshot.data!.map((tag) {
                      return FilterChip(
                        label: Text(tag.name),
                        selected: selectedTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              CheckboxListTile(
                title: const Text('置顶笔记'),
                value: isPinned,
                onChanged: (value) {
                  setState(() => isPinned = value ?? false);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _addNote();
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

// 分类标签页
class CategoriesTab extends StatefulWidget {
  final CategoryService db;

  const CategoriesTab({super.key, required this.db});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab>
    with AutomaticKeepAliveClientMixin {
  late Stream<List<Category>> categoriesStream;

  @override
  void initState() {
    super.initState();
    categoriesStream = widget.db.getAllCategories().asBroadcastStream();
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新分类'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '分类名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final category = Category()..name = controller.text;
              await widget.db.saveCategory(category);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    await widget.db.isar.writeTxn(() async {
      await widget.db.isar.categorys.delete(category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _showAddCategoryDialog,
            child: const Text('添加新分类'),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Category>>(
            stream: categoriesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final categories = snapshot.data!;
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteCategory(category),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// 标签标签页
class TagsTab extends StatefulWidget {
  final TagService db;

  const TagsTab({super.key, required this.db});

  @override
  State<TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends State<TagsTab> with AutomaticKeepAliveClientMixin {
  late Stream<List<Tag>> tagsStream;

  @override
  void initState() {
    super.initState();
    tagsStream = widget.db.getAllTags().asBroadcastStream();
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新标签'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '标签名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final tag = Tag()..name = controller.text;
              await widget.db.saveTag(tag);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTag(Tag tag) async {
    await widget.db.isar.writeTxn(() async {
      await widget.db.isar.tags.delete(tag.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _showAddTagDialog,
            child: const Text('添加新标签'),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Tag>>(
            stream: tagsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tags = snapshot.data!;
              return Wrap(
                spacing: 8.0,
                children: tags
                    .map((tag) => Chip(
                          label: Text(tag.name),
                          onDeleted: () => _deleteTag(tag),
                        ))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// 统计标签页
class StatsTab extends StatefulWidget {
  final StatsService db;

  const StatsTab({super.key, required this.db});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Map<String, int>>(
      future: widget.db.getStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatCard('总笔记数', stats['notes'] ?? 0),
            _buildStatCard('分类数量', stats['categories'] ?? 0),
            _buildStatCard('标签数量', stats['tags'] ?? 0),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showWeeklyStats,
              child: const Text('查看周统计'),
            ),
          ],
        );
      },
    );
  }

  void _showWeeklyStats() async {
    final stats = await widget.db.getLastWeekNotesCount();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '周统计',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: stats.entries.map((entry) {
                      final date = entry.key;
                      final count = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            count.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(value.toString(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
