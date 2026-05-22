import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/toy_model.dart';
import 'log_service.dart';
import 'auth_service.dart';

class ToyService {
  final _supabase = Supabase.instance.client;
  final _log = LogService();
  final _auth = AuthService();

  Future<List<ToyModel>> getToys({String? category, String? search}) async {
    var query = _supabase.from('toys').select();

    if (category != null && category != 'Tümü') {
      query = query.eq('category', category);
    }

    final data = await query.order('created_at', ascending: false);
    List<ToyModel> toys = data.map((e) => ToyModel.fromJson(e)).toList();

    if (search != null && search.isNotEmpty) {
      toys = toys
          .where((t) => t.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }

    return toys;
  }

  Future<List<ToyModel>> getMyToys() async {
    final data = await _supabase
        .from('toys')
        .select()
        .eq('owner_id', _auth.currentUserId)
        .order('created_at', ascending: false);
    return data.map((e) => ToyModel.fromJson(e)).toList();
  }

  Future<void> addToy(ToyModel toy, {File? imageFile}) async {
    String? imageUrl;

    if (imageFile != null) {
      final fileName = '${const Uuid().v4()}.jpg';
      await _supabase.storage.from('toy-images').upload(fileName, imageFile);
      imageUrl = _supabase.storage.from('toy-images').getPublicUrl(fileName);
    }

    final toyData = toy.toJson();
    if (imageUrl != null) toyData['image_url'] = imageUrl;

    await _supabase.from('toys').insert(toyData);

    await _log.addLog(
      userId: _auth.currentUserId,
      action: 'İLAN_EKLENDİ',
      detail: '${toy.name} ilanı eklendi',
    );
  }

  Future<void> deleteToy(String toyId, String toyName) async {
    await _supabase.from('toys').delete().eq('id', toyId);
    await _log.addLog(
      userId: _auth.currentUserId,
      action: 'İLAN_SİLİNDİ',
      detail: '$toyName ilanı silindi',
    );
  }

  Future<void> sendRequest(String toyId, String toyName, String shareType) async {
    await _supabase.from('requests').insert({
      'toy_id': toyId,
      'requester_id': _auth.currentUserId,
      'requester_name': _auth.currentUserName,
      'type': shareType,
      'status': 'beklemede',
    });

    await _log.addLog(
      userId: _auth.currentUserId,
      action: 'TALEP_GÖNDERİLDİ',
      detail: '$toyName için $shareType talebi gönderildi',
    );
  }
}
