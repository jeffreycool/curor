import 'package:get/get.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../services/note_service.dart';
import 'base_controller.dart';

/// 笔记控制器，处理笔记相关的业务逻辑
class NotesController extends BaseController {
  final NoteService noteService;

  NotesController(this.noteService);

  // 笔记列表
  final notes = <Note>[].obs;
  // 搜索关键词
  final searchQuery = ''.obs;
  // 选中的分类
  final selectedCategory = Rxn<Category>();
  // 选中的标签集合
  final selectedTags = <Tag>{}.obs;
  // 是否置顶
  final isPinned = false.obs;

  // 分页相关变量
  static const int _pageSize = 20;
  final _currentPage = 0.obs;
  final hasMoreData = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) => refreshNotes());
    ever(isPinned, (_) => refreshNotes());
    _loadInitialNotes();
  }

  /// 加载初始笔记
  Future<void> _loadInitialNotes() async {
    _currentPage.value = 0;
    notes.clear();
    hasMoreData.value = true;
    await _loadMoreNotes();
  }

  /// 加载更多笔记
  Future<void> loadMoreNotes() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await _loadMoreNotes();
  }

  /// 内部加载笔记方法
  Future<void> _loadMoreNotes() async {
    isLoadingMore.value = true;
    try {
      final newNotes = await noteService.getNotesByPage(
        page: _currentPage.value,
        pageSize: _pageSize,
        searchQuery: searchQuery.value,
        isPinned: isPinned.value,
      );

      if (newNotes.isEmpty) {
        hasMoreData.value = false;
      } else {
        notes.addAll(newNotes);
        _currentPage.value++;
      }
    } catch (e) {
      handleError(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// 刷新笔记列表
  Future<void> refreshNotes() async {
    await _loadInitialNotes();
  }

  /// 搜索笔记
  void searchNotes(String query) {
    searchQuery.value = query;
  }

  /// 添加新笔记
  Future<void> addNote(String title, String content) async {
    if (title.isEmpty) return;

    try {
      final note = Note()
        ..title = title
        ..content = content
        ..createdAt = DateTime.now()
        ..isPinned = false;

      await noteService.saveNote(note);
      await refreshNotes();
    } catch (e) {
      handleError(e);
    }
  }

  /// 更新笔记
  Future<void> updateNote(Note note, String title, String content) async {
    if (title.isEmpty) return;

    try {
      note.title = title;
      note.content = content;
      await noteService.saveNote(note);
      await refreshNotes();
    } catch (e) {
      handleError(e);
    }
  }

  /// 删除笔记
  Future<void> deleteNote(Note note) async {
    try {
      await noteService.deleteNote(note);
      await refreshNotes();
    } catch (e) {
      handleError(e);
    }
  }

  /// 切换笔记置顶状态
  Future<void> togglePin(Note note) async {
    try {
      note.isPinned = !note.isPinned;
      await noteService.saveNote(note);
      await refreshNotes();
    } catch (e) {
      handleError(e);
    }
  }
}
