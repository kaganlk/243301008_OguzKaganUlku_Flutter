import 'package:flutter/material.dart';
import '../models/toy_model.dart';
import '../models/log_model.dart';
import '../services/auth_service.dart';
import '../services/toy_service.dart';
import '../services/log_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _toyService = ToyService();
  final _logService = LogService();
  List<ToyModel> _myToys = [];
  List<LogModel> _logs = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final toys = await _toyService.getMyToys();
    final logs = await _logService.getUserLogs(_auth.currentUserId);
    setState(() {
      _myToys = toys;
      _logs = logs;
      _loading = false;
    });
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = _auth.currentUserRole;
    final name = _auth.currentUserName;
    final email = _auth.currentUserEmail;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                  ),
                  const Text('Profilim',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: role == 'parent'
                          ? const Color(0xFFFF6B35).withOpacity(0.15)
                          : const Color(0xFF4ECDC4).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role == 'parent' ? ' Ebeveyn' : ' Çocuk',
                      style: TextStyle(
                        color: role == 'parent'
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFF4ECDC4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFFF6B35),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                  Text(email,
                      style: const TextStyle(
                          color: Color(0xFF8892A4), fontSize: 12)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(_myToys.length.toString(), 'İlan'),
                        _stat(
                            _myToys
                                .where((t) => t.shareType == 'takas')
                                .length
                                .toString(),
                            'Takas'),
                        _stat(_logs.length.toString(), 'İşlem'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _tabBtn('İlanlarım', 0),
                  _tabBtn('Aktivite', 1),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFF6B35)))
                  : _tab == 0
                      ? _myToys.isEmpty
                          ? const Center(
                              child: Text('Henüz ilan yok ',
                                  style:
                                      TextStyle(color: Color(0xFF8892A4))))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              itemCount: _myToys.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final toy = _myToys[i];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16213E),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(_categoryEmoji(toy.category),
                                          style: const TextStyle(fontSize: 32)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(toy.name,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 13)),
                                            Text(
                                                '${toy.condition} · ${toy.category}',
                                                style: const TextStyle(
                                                    color: Color(0xFF8892A4),
                                                    fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: toy.shareType == 'takas'
                                              ? const Color(0xFFFF6B35)
                                                  .withOpacity(0.15)
                                              : const Color(0xFF4ECDC4)
                                                  .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(toy.shareType,
                                            style: TextStyle(
                                              color: toy.shareType == 'takas'
                                                  ? const Color(0xFFFF6B35)
                                                  : const Color(0xFF4ECDC4),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                      : _logs.isEmpty
                          ? const Center(
                              child: Text('Aktivite yok ',
                                  style:
                                      TextStyle(color: Color(0xFF8892A4))))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              itemCount: _logs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final log = _logs[i];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16213E),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF4ECDC4),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(log.detail,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                            Text(
                                                log.createdAt
                                                    .toLocal()
                                                    .toString()
                                                    .substring(0, 16),
                                                style: const TextStyle(
                                                    color: Color(0xFF8892A4),
                                                    fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F0F23),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(log.action,
                                            style: const TextStyle(
                                                color: Color(0xFF8892A4),
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _signOut,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF4D6D)),
                    foregroundColor: const Color(0xFFFF4D6D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Çıkış Yap',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String val, String label) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontSize: 20,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF8892A4), fontSize: 11)),
      ],
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFF6B35) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF8892A4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  String _categoryEmoji(String cat) {
    const map = {
      'Yapı': '', 'Araç': '', 'Bulmaca': '',
      'Oyuncak': '', 'Diğer': ''
    };
    return map[cat] ?? '';
  }
}
