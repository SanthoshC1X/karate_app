import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _service;

  PostProvider({PostService? service}) : _service = service ?? PostService();

  List<PostModel> _posts = const [];
  bool _isLoading = false;
  String? _error;
  final Map<String, PostModel?> _detailCache = {};

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _posts = await _service.getPosts();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PostModel?> fetchPostDetail(String postId) async {
    _error = null;
    notifyListeners();
    try {
      final post = await _service.getPostById(postId);
      _detailCache[postId] = post;
      notifyListeners();
      return post;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  PostModel? getPostDetail(String postId) => _detailCache[postId];

  Future<void> createPost({
    required String title,
    String? description,
    DateTime? date,
    String? imageUrl,
    required String type,
  }) async {
    _error = null;
    notifyListeners();
    try {
      await _service.createPost(
        title: title,
        description: description,
        date: date,
        imageUrl: imageUrl,
        type: type,
      );
      await fetchPosts();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _service.deletePost(id);
      await fetchPosts();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
