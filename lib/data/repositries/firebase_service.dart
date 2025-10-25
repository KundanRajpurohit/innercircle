// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innercircle/data/models/message.dart';
import '../models/event.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ EVENTS ============

  // Create event
  Future<String> createEvent(Event event) async {
    try {
      final docRef = await _firestore.collection('events').add(event.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  // Get all events
  // services/firestore_service.dart

  Stream<List<Event>> getEvents() {
    print('🔥 Firestore: Starting events stream');

    return _firestore
        .collection('events')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
          print(
            '🔥 Firestore: Received snapshot with ${snapshot.docs.length} documents',
          );

          final events =
              snapshot.docs
                  .map((doc) {
                    try {
                      final data = doc.data();
                      print('🔥 Firestore: Processing event ${doc.id}');
                      return Event.fromJson({...data, 'id': doc.id});
                    } catch (e) {
                      print('❌ Firestore: Error parsing event ${doc.id}: $e');
                      return null;
                    }
                  })
                  .whereType<Event>()
                  .toList();

          print('🔥 Firestore: Mapped to ${events.length} Event objects');
          return events;
        })
        .handleError((error) {
          print('❌ Firestore: Stream error - $error');
        });
  }

  // Get event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return Event.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  // Get events by host
  Stream<List<Event>> getEventsByHost(String hostId) {
    return _firestore
        .collection('events')
        .where('hostId', isEqualTo: hostId)
        // No orderBy here
        .snapshots()
        .map((snapshot) {
          final events =
              snapshot.docs
                  .map((doc) => Event.fromJson({...doc.data(), 'id': doc.id}))
                  .toList();

          // Sort in code instead
          events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return events;
        });
  }

  // Get events user joined
  Stream<List<Event>> getJoinedEvents(String userId) {
    return _firestore
        .collection('events')
        .where('joinedUsers', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final events =
              snapshot.docs
                  .map((doc) => Event.fromJson({...doc.data(), 'id': doc.id}))
                  .toList();

          events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return events;
        });
  }

  // Join event
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'joinedUsers': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error joining event: $e');
      rethrow;
    }
  }

  // Leave event
  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'joinedUsers': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error leaving event: $e');
      rethrow;
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      // Delete event document
      await _firestore.collection('events').doc(eventId).delete();

      // Delete chat messages
      final chatSnapshot =
          await _firestore
              .collection('chats')
              .doc(eventId)
              .collection('messages')
              .get();

      for (var doc in chatSnapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('chats').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  // ============ CHAT ============

  // Send message
  Future<void> sendMessage({
    required String eventId,
    required ChatMessage message,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(eventId)
          .collection('messages')
          .add(message.toJson());
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages
  Stream<List<ChatMessage>> getMessages(String eventId) {
    return _firestore
        .collection('chats')
        .doc(eventId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessage.fromJson(doc.data(), doc.id))
                  .toList(),
        );
  }
}
