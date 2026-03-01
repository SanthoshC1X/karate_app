class ConversationModel {
  final String id;
  final String studentId;
  final String studentName;
  final String studentBelt;
  final String masterId;
  final String masterName;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final bool lastMessageIsRead;
  final String? lastMessageSenderId;

  ConversationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentBelt,
    required this.masterId,
    required this.masterName,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.lastMessageIsRead = true,
    this.lastMessageSenderId,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    final lastMsg = (map['messages'] as List?)?.isNotEmpty == true
        ? map['messages'][0] as Map<String, dynamic>
        : null;
    return ConversationModel(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      studentName: (map['student'] as Map)['name'] as String,
      studentBelt: (map['student'] as Map)['belt_level'] as String? ?? 'White',
      masterId: map['master_id'] as String,
      masterName: (map['master'] as Map)['name'] as String,
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'] as String)
          : null,
      lastMessagePreview: lastMsg?['content'] as String?,
      lastMessageIsRead: lastMsg?['is_read'] as bool? ?? true,
      lastMessageSenderId: lastMsg?['sender_id'] as String?,
    );
  }

  /// Returns the name of the other participant.
  String otherName(String myId) =>
      myId == studentId ? masterName : studentName;

  /// Returns the first letter of the other participant's name.
  String otherInitial(String myId) {
    final name = otherName(myId);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// True if there are unread messages sent by the other person.
  bool hasUnread(String myId) =>
      !lastMessageIsRead && lastMessageSenderId != myId;
}
