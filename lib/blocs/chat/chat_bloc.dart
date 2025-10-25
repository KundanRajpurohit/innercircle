// blocs/chat/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/data/repositries/firebase_service.dart';

import 'chat_event.dart' as chat_event;
import 'chat_state.dart' as chat_state;
import 'dart:async';

class ChatBloc extends Bloc<chat_event.ChatEvent, chat_state.ChatState> {
  final FirestoreService firestoreService;
  StreamSubscription? _messagesSubscription;

  ChatBloc({required this.firestoreService}) : super(chat_state.ChatInitial()) {
    on<chat_event.ChatLoadRequested>(_onLoadMessages);
    on<chat_event.ChatMessageSent>(_onSendMessage);
  }

  Future<void> _onLoadMessages(
    chat_event.ChatLoadRequested event,
    Emitter<chat_state.ChatState> emit,
  ) async {
    emit(chat_state.ChatLoading());

    await _messagesSubscription?.cancel();

    try {
      await emit.forEach(
        firestoreService.getMessages(event.eventId),
        onData: (messages) => chat_state.ChatLoaded(messages),
        onError: (error, stackTrace) => chat_state.ChatError(error.toString()),
      );
    } catch (e) {
      emit(chat_state.ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    chat_event.ChatMessageSent event,
    Emitter<chat_state.ChatState> emit,
  ) async {
    try {
      await firestoreService.sendMessage(
        eventId: event.eventId,
        message: event.message,
      );
    } catch (e) {
      emit(chat_state.ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
