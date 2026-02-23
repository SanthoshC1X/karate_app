import '../models/post_model.dart';
import 'api_client.dart';

class PostService {
  final _api = ApiClient.instance;

  Future<List<PostModel>> getPosts() async {
    final data = await _api.get('/posts') as List<dynamic>;
    return data
        .map((item) => PostModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<PostModel?> getPostById(String id) async {
    try {
      final data = await _api.get('/posts/$id') as Map<String, dynamic>;
      return PostModel.fromMap(data);
    } catch (_) {
      return null;
    }
  }

  Future<PostModel> createPost({
    required String title,
    String? description,
    DateTime? date,
    String? imageUrl,
    required String type,
  }) async {
    final data = await _api.post('/posts', body: {
      'title': title,
      'description': description,
      'date': date?.toIso8601String().split('T')[0],
      'image_url': imageUrl,
      'type': type,
    }) as Map<String, dynamic>;

    return PostModel.fromMap(data);
  }

  Future<void> deletePost(String id) async {
    await _api.delete('/posts/$id');
  }
}

