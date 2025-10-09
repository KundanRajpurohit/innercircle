// blocs/events/events_event.dart
import 'package:equatable/equatable.dart';
import 'package:innercircle/data/models/event.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class EventsLoadRequested extends EventsEvent {}

class EventsLoadHostedRequested extends EventsEvent {
  final String hostId;

  const EventsLoadHostedRequested(this.hostId);

  @override
  List<Object?> get props => [hostId];
}

class EventsLoadJoinedRequested extends EventsEvent {
  final String userId;

  const EventsLoadJoinedRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class EventCreateRequested extends EventsEvent {
  final Event event;

  const EventCreateRequested(this.event);

  @override
  List<Object?> get props => [event];
}

class EventJoinRequested extends EventsEvent {
  final String eventId;
  final String userId;

  const EventJoinRequested(this.eventId, this.userId);

  @override
  List<Object?> get props => [eventId, userId];
}

class EventLeaveRequested extends EventsEvent {
  final String eventId;
  final String userId;

  const EventLeaveRequested(this.eventId, this.userId);

  @override
  List<Object?> get props => [eventId, userId];
}

class EventDeleteRequested extends EventsEvent {
  final String eventId;

  const EventDeleteRequested(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
