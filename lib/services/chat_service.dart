import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'api_client.dart';

class ChatService {
  final _api = ApiClient.instance;

  Future<List<ConversationModel>> getConversations() async {
    final data = await _api.get('/chat/conversations') as List<dynamic>;
    return data
        .map((e) => ConversationModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<ConversationModel> startConversation(String masterId) async {
    final data = await _api.post('/chat/conversations',
        body: {'master_id': masterId}) as Map<String, dynamic>;
    return ConversationModel.fromMap(data);
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final data =
        await _api.get('/chat/conversations/$conversationId/messages') as List<dynamic>;
    return data
        .map((e) => MessageModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageModel> sendMessage(String conversationId, String content) async {
    final data = await _api.post(
      '/chat/conversations/$conversationId/messages',
      body: {'content': content},
    ) as Map<String, dynamic>;
    return MessageModel.fromMap(data);
  }

  Future<void> markRead(String conversationId) async {
    await _api.patch('/chat/conversations/$conversationId/read');
  }
}
