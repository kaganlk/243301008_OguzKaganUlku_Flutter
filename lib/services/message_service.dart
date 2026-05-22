import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import 'log_service.dart';
import 'auth_service.dart';

class MessageService {
  final _supabase = Supabase.instance.client;
  final _log = LogService();
  final _auth = AuthService();

  Future<List<MessageModel>> getMessages(String toyId) async {
    final data = await _supabase
        .from('messages')
        .select()
        .eq('toy_id', toyId)
        .order('created_at', ascending: true);
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  Stream<List<MessageModel>> messagesStream(String toyId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('toy_id', toyId)
        .order('created_at')
        .map((data) => data.map((e) => MessageModel.fromJson(e)).toList());
  }

  Future<void> sendMessage({
    required String receiverId,
    required String toyId,
    required String text,
  }) async {
    await _supabase.from('messages').insert({
      'sender_id': _auth.currentUserId,
      'receiver_id': receiverId,
      'toy_id': toyId,
      'text': text,
    });

    await _log.addLog(
      userId: _auth.currentUserId,
      action: 'MESAJ_GÖNDERİLDİ',
      detail: 'Mesaj gönderildi',
    );
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final data = await _supabase
        .from('messages')
        .select('*, toys(name)')
        .or('sender_id.eq.${_auth.currentUserId},receiver_id.eq.${_auth.currentUserId}')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
