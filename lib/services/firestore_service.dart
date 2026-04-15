import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';
import '../models/diet_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ── Diet Profile ──────────────────────────────────────────────
  Future<void> saveProfile(DietProfile profile) async {
    await _db.collection('users').doc(_uid).set({
      'profile': profile.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DietProfile?> loadProfile() async {
    final doc = await _db.collection('users').doc(_uid).get();
    final data = doc.data();
    if (data == null || data['profile'] == null) return null;
    return DietProfile.fromJson(Map<String, dynamic>.from(data['profile']));
  }

  // ── Chat History ──────────────────────────────────────────────
  Future<void> saveMessage(Message message) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('messages')
        .add({
      'text': message.text,
      'sender': message.sender == Sender.user ? 'user' : 'bot',
      'time': message.time.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Message>> loadRecentMessages({int limit = 50}) async {
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.reversed.map((doc) {
      final data = doc.data();
      return Message(
        text: data['text'] as String,
        sender: data['sender'] == 'user' ? Sender.user : Sender.bot,
        time: DateTime.parse(data['time'] as String),
      );
    }).toList();
  }

  Future<void> clearChatHistory() async {
    final batch = _db.batch();
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('messages')
        .get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
