// blocs/events/events_state.dart
import 'package:equatable/equatable.dart';
import 'package:innercircle/data/models/event.dart';

abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventsHostedLoaded extends EventsState {
  final List<Event> hostedEvents;

  const EventsHostedLoaded(this.hostedEvents);

  @override
  List<Object?> get props => [hostedEvents];
}

class EventsJoinedLoaded extends EventsState {
  final List<Event> joinedEvents;

  const EventsJoinedLoaded(this.joinedEvents);

  @override
  List<Object?> get props => [joinedEvents];
}

class EventCreated extends EventsState {
  final String eventId;

  const EventCreated(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class EventJoined extends EventsState {}

class EventLeft extends EventsState {}

class EventDeleted extends EventsState {}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}
