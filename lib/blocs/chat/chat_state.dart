// blocs/chat/chat_state.dart
import 'package:equatable/equatable.dart';
import 'package:innercircle/data/models/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatMessageSending extends ChatState {}

class ChatMessageSent extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
