/// Direct chat with an Agricultural Officer — the human-in-the-loop
/// channel that escalation cases (FR-2.3) route into.
enum ChatSender { farmer, officer }

class ChatMessage {
  final String id;
  final ChatSender sender;
  final String body;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender.name,
        'body': body,
        'sentAt': sentAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        sender: ChatSender.values.byName(json['sender'] as String),
        body: json['body'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
}
