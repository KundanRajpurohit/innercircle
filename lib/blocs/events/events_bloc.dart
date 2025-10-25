// blocs/events/events_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/data/models/event.dart';
import 'package:innercircle/data/repositries/firebase_service.dart';

import 'events_event.dart';
import 'events_state.dart';
import 'dart:async';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final FirestoreService firestoreService;
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _hostedEventsSubscription;
  StreamSubscription? _joinedEventsSubscription;

  EventsBloc({required this.firestoreService}) : super(EventsInitial()) {
    on<EventsLoadRequested>(_onLoadEvents);
    on<EventsLoadHostedRequested>(_onLoadHostedEvents);
    on<EventsLoadJoinedRequested>(_onLoadJoinedEvents);
    on<EventCreateRequested>(_onCreateEvent);
    on<EventJoinRequested>(_onJoinEvent);
    on<EventLeaveRequested>(_onLeaveEvent);
    on<EventDeleteRequested>(_onDeleteEvent);
  }

  Future<void> _onLoadEvents(
    EventsLoadRequested event,
    Emitter<EventsState> emit,
  ) async {
    print('📱 EventsBloc: Loading events...');
    emit(EventsLoading());

    await _eventsSubscription?.cancel();

    await emit.forEach<List>(
      firestoreService.getEvents(),
      onData: (events) {
        print('📱 EventsBloc: Received ${events.length} events');
        return EventsLoaded(events.cast<Event>());
      },
      onError: (error, stackTrace) {
        print('❌ EventsBloc: Error - $error');
        return EventsError(error.toString());
      },
    );
  }

  Future<void> _onLoadHostedEvents(
    EventsLoadHostedRequested event,
    Emitter<EventsState> emit,
  ) async {
    print('📱 EventsBloc: Loading hosted events for ${event.hostId}');
    emit(EventsLoading());

    await _hostedEventsSubscription?.cancel();

    await emit.forEach<List>(
      firestoreService.getEventsByHost(event.hostId),
      onData: (events) {
        print('📱 EventsBloc: Received ${events.length} hosted events');
        return EventsHostedLoaded(events.cast<Event>());
      },
      onError: (error, stackTrace) {
        print('❌ EventsBloc: Hosted events error - $error');
        return EventsError(error.toString());
      },
    );
  }

  Future<void> _onLoadJoinedEvents(
    EventsLoadJoinedRequested event,
    Emitter<EventsState> emit,
  ) async {
    print('📱 EventsBloc: Loading joined events for ${event.userId}');
    emit(EventsLoading());

    await _joinedEventsSubscription?.cancel();

    await emit.forEach<List>(
      firestoreService.getJoinedEvents(event.userId),
      onData: (events) {
        print('📱 EventsBloc: Received ${events.length} joined events');
        return EventsJoinedLoaded(events.cast<Event>());
      },
      onError: (error, stackTrace) {
        print('❌ EventsBloc: Joined events error - $error');
        return EventsError(error.toString());
      },
    );
  }

  Future<void> _onCreateEvent(
    EventCreateRequested event,
    Emitter<EventsState> emit,
  ) async {
    print('📱 EventsBloc: Creating event...');
    emit(EventsLoading());

    try {
      final eventId = await firestoreService.createEvent(event.event);
      print('✅ EventsBloc: Event created with ID: $eventId');
      emit(EventCreated(eventId));
    } catch (e) {
      print('❌ EventsBloc: Create event error - $e');
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onJoinEvent(
    EventJoinRequested event,
    Emitter<EventsState> emit,
  ) async {
    print('📱 EventsBloc: Joining event ${event.eventId}');

    try {
      await firestoreService.joinEvent(event.eventId, event.userId);
      print('✅ EventsBloc: Successfully joined event');
      emit(EventJoined());
    } catch (e) {
      print('❌ EventsBloc: Join event error - $e');
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onLeaveEvent(
    EventLeaveRequested event,
    Emitter<EventsState> emit,
  ) async {
    print('📱 EventsBloc: Leaving event ${event.eventId}');

    try {
      await firestoreService.leaveEvent(event.eventId, event.userId);
      print('✅ EventsBloc: Successfully left event');
      emit(EventLeft());
    } catch (e) {
      print('❌ EventsBloc: Leave event error - $e');
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
    EventDeleteRequested event,
    Emitter<EventsState> emit,
  ) async {
    print('📱 EventsBloc: Deleting event ${event.eventId}');

    try {
      await firestoreService.deleteEvent(event.eventId);
      print('✅ EventsBloc: Successfully deleted event');
      emit(EventDeleted());
    } catch (e) {
      print('❌ EventsBloc: Delete event error - $e');
      emit(EventsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    print('📱 EventsBloc: Closing and canceling subscriptions');
    _eventsSubscription?.cancel();
    _hostedEventsSubscription?.cancel();
    _joinedEventsSubscription?.cancel();
    return super.close();
  }
}
