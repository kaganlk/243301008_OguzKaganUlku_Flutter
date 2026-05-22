import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/log_model.dart';

class LogService {
  final _supabase = Supabase.instance.client;

  Future<void> addLog({
    required String userId,
    required String action,
    required String detail,
  }) async {
    await _supabase.from('logs').insert({
      'user_id': userId,
      'action': action,
      'detail': detail,
    });
  }

  Future<List<LogModel>> getUserLogs(String userId) async {
    final data = await _supabase
        .from('logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(20);
    return data.map((e) => LogModel.fromJson(e)).toList();
  }
}
