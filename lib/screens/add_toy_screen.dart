import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/toy_model.dart';
import '../services/toy_service.dart';
import '../services/auth_service.dart';

class AddToyScreen extends StatefulWidget {
  const AddToyScreen({super.key});

  @override
  State<AddToyScreen> createState() => _AddToyScreenState();
}

class _AddToyScreenState extends State<AddToyScreen> {
  final _toyService = ToyService();
  final _auth = AuthService();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Yapı';
  String _condition = 'İyi';
  String _shareType = 'takas';
  String _ageGroup = '3+';
  File? _imageFile;
  bool _loading = false;

  final _categories = ['Yapı', 'Araç', 'Bulmaca', 'Oyuncak', 'Diğer'];
  final _conditions = ['Mükemmel', 'Çok İyi', 'İyi', 'Orta'];
  final _ageGroups = ['3+', '5+', '6+', '7+', '8+', '10+'];

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oyuncak adı boş olamaz')),
      );
      return;
    }

    setState(() => _loading = true);

    final toy = ToyModel(
      id: '',
      ownerId: _auth.currentUserId,
      ownerName: _auth.currentUserName,
      name: _nameCtrl.text.trim(),
      category: _category,
      condition: _condition,
      shareType: _shareType,
      ageGroup: _ageGroup,
      description: _descCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _toyService.addToy(toy, imageFile: _imageFile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlan yayınlandı!'),
          backgroundColor: Color(0xFF6BCB77),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Oyuncak Ekle',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFFF6B35).withOpacity(0.3),
                              width: 2),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      color: Color(0xFF8892A4), size: 32),
                                  SizedBox(height: 8),
                                  Text('Fotoğraf ekle',
                                      style: TextStyle(
                                          color: Color(0xFF8892A4),
                                          fontSize: 13)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Oyuncak Adı'),
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Kategori'),
                    _chipGroup(_categories, _category,
                        (v) => setState(() => _category = v)),
                    const SizedBox(height: 16),
                    _sectionLabel('Durum'),
                    _chipGroup(_conditions, _condition,
                        (v) => setState(() => _condition = v)),
                    const SizedBox(height: 16),
                    _sectionLabel('Yaş Grubu'),
                    _chipGroup(_ageGroups, _ageGroup,
                        (v) => setState(() => _ageGroup = v)),
                    const SizedBox(height: 16),
                    _sectionLabel('Paylaşım Türü'),
                    Row(
                      children: [
                        _typeBtn('takas', '⇄ Takas', const Color(0xFFFF6B35)),
                        const SizedBox(width: 10),
                        _typeBtn(
                            'ödünç', '⏳ Geçici Ödünç', const Color(0xFF4ECDC4)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descCtrl,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Açıklama (opsiyonel)'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('İlanı Yayınla',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF8892A4),
              fontSize: 11,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _chipGroup(
      List<String> items, String selected, Function(String) onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selected == item;
        return GestureDetector(
          onTap: () => onTap(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFF6B35)
                  : const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(item,
                style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8892A4),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _typeBtn(String val, String label, Color color) {
    final selected = _shareType == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _shareType = val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : const Color(0xFF16213E),
            border: Border.all(
                color: selected ? color : Colors.transparent, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: selected ? color : const Color(0xFF8892A4),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ),
    );
  }
}
