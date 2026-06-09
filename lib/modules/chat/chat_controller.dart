import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();

  final _db = FirebaseFirestore.instance;
  final unreadCount = 0.obs;
  final isChatOpen = false.obs;
  DateTime? _lastReadAt;
  StreamSubscription? _chatSub;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  CollectionReference get _messagesRef =>
      _db.collection('support_chat').doc(_currentUid).collection('messages');

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.emailVerified) {
        _listenUnread();
      } else {
        closeListener();
        unreadCount.value = 0;
      }
    });
  }

  void _listenUnread() {
    _chatSub?.cancel();
    _chatSub = _messagesRef
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snap) {
          if (isChatOpen.value) {
            unreadCount.value = 0;
            _lastReadAt = DateTime.now();
            return;
          }
          int count = 0;
          for (final doc in snap.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final sender = data['sender'] as String? ?? '';
            final ts = data['timestamp'] as Timestamp?;
            if (sender == 'employee' && ts != null) {
              final msgTime = ts.toDate();
              if (_lastReadAt == null || msgTime.isAfter(_lastReadAt!)) {
                count++;
              }
            }
          }
          unreadCount.value = count;
        });
  }

  void closeListener() {
    _chatSub?.cancel();
    _chatSub = null;
  }

  void markAsRead() {
    _lastReadAt = DateTime.now();
    unreadCount.value = 0;
  }

  void onChatOpened() {
    isChatOpen.value = true;
    markAsRead();
  }

  void onChatClosed() {
    isChatOpen.value = false;
    markAsRead();
  }
}
