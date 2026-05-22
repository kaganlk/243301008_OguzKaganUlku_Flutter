import 'package:flutter/material.dart';
import '../models/toy_model.dart';
import '../services/toy_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class DetailScreen extends StatefulWidget {
  final ToyModel toy;

  const DetailScreen({super.key, required this.toy});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _toyService = ToyService();
  final _auth = AuthService();
  bool _loading = false;
  bool _requested = false;

  Future<void> _sendRequest() async {
    setState(() => _loading = true);
    try {
      await _toyService.sendRequest(
        widget.toy.id,
        widget.toy.name,
        widget.toy.shareType,
      );
      setState(() => _requested = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Talebiniz gönderildi!'),
          backgroundColor: Color(0xFF6BCB77),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final toy = widget.toy;
    final isOwner = _auth.currentUserId == toy.ownerId;

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
                  const Text('Detay',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (isOwner)
                    IconButton(
                      onPressed: () async {
                        await _toyService.deleteToy(toy.id, toy.name);
                        if (mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xFFFF4D6D)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: toy.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(toy.imageUrl!,
                                  fit: BoxFit.cover),
                            )
                          : Center(
                              child: Text(
                                _categoryEmoji(toy.category),
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(toy.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900)),
                              Text(toy.category,
                                  style: const TextStyle(
                                      color: Color(0xFF8892A4), fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: toy.shareType == 'takas'
                                ? const Color(0xFFFF6B35).withOpacity(0.15)
                                : const Color(0xFF4ECDC4).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            toy.shareType == 'takas' ? '⇄ Takas' : ' Ödünç',
                            style: TextStyle(
                              color: toy.shareType == 'takas'
                                  ? const Color(0xFFFF6B35)
                                  : const Color(0xFF4ECDC4),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _infoRow(' Durum', toy.condition),
                          _infoRow(' Yaş Grubu', toy.ageGroup),
                          _infoRow(' Sahip', toy.ownerName),
                          _infoRow(' Kategori', toy.category, last: true),
                        ],
                      ),
                    ),
                    if (toy.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Açıklama',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            const SizedBox(height: 8),
                            Text(toy.description,
                                style: const TextStyle(
                                    color: Color(0xFF8892A4),
                                    fontSize: 13,
                                    height: 1.6)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (!isOwner)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    receiverId: toy.ownerId,
                                    receiverName: toy.ownerName,
                                    toyId: toy.id,
                                    toyName: toy.name,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF4ECDC4)),
                                foregroundColor: const Color(0xFF4ECDC4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(' Mesaj',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed:
                                  (_loading || _requested) ? null : _sendRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _requested
                                    ? const Color(0xFF6BCB77)
                                    : const Color(0xFFFF6B35),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : Text(
                                      _requested
                                          ? '✓ Talep Gönderildi'
                                          : toy.shareType == 'takas'
                                              ? '⇄ Takas Teklif Et'
                                              : ' Ödünç İste',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFF0F0F23), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8892A4), fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
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
