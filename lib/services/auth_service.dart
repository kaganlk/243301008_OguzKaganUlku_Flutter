import 'package:supabase_flutter/supabase_flutter.dart';
import 'log_service.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  String get currentUserId => _supabase.auth.currentUser!.id;

  String get currentUserEmail => _supabase.auth.currentUser!.email ?? '';

  String get currentUserRole =>
      _supabase.auth.currentUser?.userMetadata?['role'] ?? 'parent';

  String get currentUserName =>
      _supabase.auth.currentUser?.userMetadata?['name'] ?? 'Kullanıcı';

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );
    if (res.user != null) {
      await LogService().addLog(
        userId: res.user!.id,
        action: 'KAYIT',
        detail: '$email adresiyle $role olarak kayıt oldu',
      );
    }
    return res;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user != null) {
      await LogService().addLog(
        userId: res.user!.id,
        action: 'GİRİŞ',
        detail: '$email ile giriş yapıldı',
      );
    }
    return res;
  }

  Future<void> signOut() async {
    await LogService().addLog(
      userId: currentUserId,
      action: 'ÇIKIŞ',
      detail: 'Oturumu kapattı',
    );
    await _supabase.auth.signOut();
  }
}
