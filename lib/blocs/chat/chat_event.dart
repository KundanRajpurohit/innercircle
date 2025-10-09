// blocs/chat/chat_event.dart
import 'package:equatable/equatable.dart';

import '../../data/models/message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatLoadRequested extends ChatEvent {
  final String eventId;

  const ChatLoadRequested(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class ChatMessageSent extends ChatEvent {
  final String eventId;
  final ChatMessage message;

  const ChatMessageSent(this.eventId, this.message);

  @override
  List<Object?> get props => [eventId, message];
}
