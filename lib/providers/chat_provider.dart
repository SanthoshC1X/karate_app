import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service;

  ChatProvider({ChatService? service}) : _service = service ?? ChatService();

  List<ConversationModel> _conversations = const [];
  final Map<String, List<MessageModel>> _messages = {};
  bool _isLoading = false;
  String? _error;
  bool _isSending = false;

  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSending => _isSending;

  List<MessageModel> messagesFor(String convId) =>
      _messages[convId] ?? const [];

  int unreadCount(String myId) =>
      _conversations.where((c) => c.hasUnread(myId)).length;

  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _conversations = await _service.getConversations();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Student calls this to open/create a conversation with their master.
  Future<ConversationModel?> startConversation(String masterId) async {
    _error = null;
    notifyListeners();
    try {
      final conv = await _service.startConversation(masterId);
      final idx = _conversations.indexWhere((c) => c.id == conv.id);
      if (idx >= 0) {
        _conversations = List.of(_conversations)..[idx] = conv;
      } else {
        _conversations = [conv, ..._conversations];
      }
      notifyListeners();
      return conv;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchMessages(String conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _messages[conversationId] = await _service.getMessages(conversationId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    _isSending = true;
    notifyListeners();
    try {
      final msg = await _service.sendMessage(conversationId, content);
      _messages[conversationId] = [...messagesFor(conversationId), msg];
      // refresh conversation list so last-message preview updates
      await fetchConversations();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String conversationId, String myId) async {
    try {
      await _service.markRead(conversationId);
      // update local read state
      final idx = _conversations.indexWhere((c) => c.id == conversationId);
      if (idx >= 0) await fetchConversations();
    } catch (_) {}
  }
}
