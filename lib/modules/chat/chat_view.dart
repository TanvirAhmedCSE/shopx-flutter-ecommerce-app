import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'chat_controller.dart';
import '../../modules/bottom_nav/bottom_nav_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentRole = 'customer';
  Color _customerBubbleColor = AppColors.primary;
  Color _employeeBubbleColor = AppColors.primary;

  bool _isInitializing = true;

  static const String _greetingFirst = 'Hi, how can I help you?';

  Color get _myBubbleColor =>
      _currentRole == 'customer' ? _customerBubbleColor : _employeeBubbleColor;

  final List<Color> _availableColors = [
    AppColors.primary,
    const Color(0xFF1A73E8),
    const Color(0xFF4CAF50),
    const Color(0xFF9C27B0),
    const Color(0xFFFF6D00),
    const Color(0xFF00ACC1),
  ];

  CollectionReference get _messagesRef {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return _firestore
        .collection('support_chat')
        .doc(uid)
        .collection('messages');
  }

  @override
  void initState() {
    super.initState();
    ChatController.to.onChatOpened();
    _sendGreetingIfEmpty();
  }

  @override
  void dispose() {
    ChatController.to.onChatClosed();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendGreetingIfEmpty() async {
    if (mounted) setState(() => _isInitializing = true);

    final snapshot = await _messagesRef.limit(1).get();

    if (snapshot.docs.isEmpty) {
      await _messagesRef.add({
        'text': _greetingFirst,
        'sender': 'employee',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      final countSnapshot = await _messagesRef.limit(2).get();
      if (countSnapshot.docs.length == 1) {
        final data = countSnapshot.docs.first.data() as Map<String, dynamic>;
        final sender = data['sender'] as String? ?? '';
        final text = data['text'] as String? ?? '';
        if (sender == 'employee' && text == _greetingFirst) {
          await countSnapshot.docs.first.reference.delete();
          await _messagesRef.add({
            'text': _greetingFirst,
            'sender': 'employee',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    if (mounted) setState(() => _isInitializing = false);
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    await _messagesRef.add({
      'text': text,
      'sender': _currentRole,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Color selectedColor = _myBubbleColor;
            return Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.transparent),
                ),
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Chat Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Bubble color & role',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: _availableColors.map((color) {
                              final isSelected = selectedColor == color;
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() => selectedColor = color);
                                  setState(() {
                                    if (_currentRole == 'customer') {
                                      _customerBubbleColor = color;
                                    } else {
                                      _employeeBubbleColor = color;
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.textPrimary,
                                            width: 3,
                                          )
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentRole = _currentRole == 'customer'
                                    ? 'employee'
                                    : 'customer';
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _currentRole == 'customer'
                                        ? Icons.support_agent_rounded
                                        : Icons.person_rounded,
                                    color: AppColors.textPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _currentRole == 'customer'
                                        ? 'Switch to Employee'
                                        : 'Switch to Customer',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMessage(Map<String, dynamic> data) {
    final sender = data['sender'] as String? ?? 'customer';
    final isMe = sender == _currentRole;
    final text = data['text'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;
    final bubbleColor = isMe ? _myBubbleColor : AppColors.divider;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isMe
                        ? [
                            BoxShadow(
                              color: _myBubbleColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatTime(timestamp.toDate()),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 30) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60)
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24)
      return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays < 7)
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Usually replies instantly',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: () => BottomNavController.to.changePage(0),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: _showSettingsDialog,
          ),
          const SizedBox(width: 3),
        ],
      ),
      body: Stack(
        children: [
          _isInitializing
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: _messagesRef
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<Map<String, dynamic>> messages = [];
                    if (snapshot.hasData) {
                      messages.addAll(
                        snapshot.data!.docs.map(
                          (d) => d.data() as Map<String, dynamic>,
                        ),
                      );
                    }
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                    );
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 12, bottom: 100),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => _buildMessage(messages[i]),
                    );
                  },
                ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildInputBar()),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _myBubbleColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _myBubbleColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
