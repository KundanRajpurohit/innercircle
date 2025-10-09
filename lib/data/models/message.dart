// models/chat_message.dart
class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String id) =>
      ChatMessage(
        id: id,
        text: json['text'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? 'Unknown',
        senderPhotoUrl: json['senderPhotoUrl'],
        timestamp:
            json['timestamp'] != null
                ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
                : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    'text': text,
    'senderId': senderId,
    'senderName': senderName,
    'senderPhotoUrl': senderPhotoUrl,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}
