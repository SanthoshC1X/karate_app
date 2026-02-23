import '../models/post_model.dart';
import 'mock_api_store.dart';

class PostService {
  final _store = MockApiStore.instance;

  Future<List<PostModel>> getPosts() async {
    final data = await _store.getPosts();
    return data.map(PostModel.fromMap).toList();
  }

  Future<PostModel?> getPostById(String id) async {
    final data = await _store.getPostById(id);
    if (data == null) return null;
    return PostModel.fromMap(data);
  }

  Future<PostModel> createPost({
    required String title,
    String? description,
    DateTime? date,
    String? imageUrl,
    required String type,
  }) async {
    final data = await _store.createPost(
      title: title,
      description: description,
      date: date,
      imageUrl: imageUrl,
      type: type,
    );
    return PostModel.fromMap(data);
  }

  Future<void> deletePost(String id) async {
    await _store.deletePost(id);
  }
}
