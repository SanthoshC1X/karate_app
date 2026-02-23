import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

final postServiceProvider = Provider<PostService>((ref) => PostService());

final postsProvider = FutureProvider<List<PostModel>>((ref) async {
  return ref.read(postServiceProvider).getPosts();
});

final postDetailProvider =
    FutureProvider.family<PostModel?, String>((ref, postId) async {
  return ref.read(postServiceProvider).getPostById(postId);
});
