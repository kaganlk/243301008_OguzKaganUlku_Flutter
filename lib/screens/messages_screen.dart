import 'package:flutter/material.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageService = MessageService();
  final _auth = AuthService();
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final convs = await _messageService.getConversations();
    setState(() {
      _conversations = convs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                  ),
                  const Text('Mesajlar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFF6B35)))
                  : _conversations.isEmpty
                      ? const Center(
                          child: Text('Henüz mesaj yok ',
                              style: TextStyle(color: Color(0xFF8892A4))))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _conversations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final conv = _conversations[i];
                            final isSender =
                                conv['sender_id'] == _auth.currentUserId;
                            final otherName = isSender
                                ? 'Alıcı'
                                : conv['sender_name'] ?? 'Kullanıcı';
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    receiverId: isSender
                                        ? conv['receiver_id']
                                        : conv['sender_id'],
                                    receiverName: otherName,
                                    toyId: conv['toy_id'],
                                    toyName:
                                        conv['toys']?['name'] ?? 'Oyuncak',
                                  ),
                                ),
                              ).then((_) => _load()),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16213E),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor:
                                          const Color(0xFF4ECDC4).withOpacity(0.2),
                                      child: Text(
                                        otherName.isNotEmpty
                                            ? otherName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Color(0xFF4ECDC4),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(otherName,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13)),
                                          Text(
                                            conv['text'] ?? '',
                                            style: const TextStyle(
                                                color: Color(0xFF8892A4),
                                                fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
