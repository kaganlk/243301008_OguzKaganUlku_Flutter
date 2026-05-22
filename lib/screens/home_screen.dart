import 'package:flutter/material.dart';
import '../models/toy_model.dart';
import '../services/toy_service.dart';
import '../services/auth_service.dart';
import 'detail_screen.dart';
import 'add_toy_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _toyService = ToyService();
  final _auth = AuthService();
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'Tümü';
  List<ToyModel> _toys = [];
  bool _loading = true;

  final _categories = ['Tümü', 'Yapı', 'Araç', 'Bulmaca', 'Oyuncak', 'Diğer'];
  final _categoryIcons = {
    'Tümü': '', 'Yapı': '', 'Araç': '',
    'Bulmaca': '', 'Oyuncak': '', 'Diğer': ''
  };

  @override
  void initState() {
    super.initState();
    _loadToys();
  }

  Future<void> _loadToys() async {
    setState(() => _loading = true);
    final toys = await _toyService.getToys(
      category: _selectedCategory,
      search: _searchCtrl.text,
    );
    setState(() {
      _toys = toys;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isParent = _auth.currentUserRole == 'parent';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba, ${_auth.currentUserName} ',
                          style: const TextStyle(
                              color: Color(0xFF8892A4), fontSize: 13),
                        ),
                        const Text(
                          'Oyuncak Keşfet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MessagesScreen())),
                    icon: Stack(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4D6D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ).then((_) => _loadToys()),
                    icon: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFFF6B35),
                      child: Text(
                        _auth.currentUserName.isNotEmpty
                            ? _auth.currentUserName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => _loadToys(),
                decoration: const InputDecoration(
                  hintText: 'Oyuncak ara...',
                  hintStyle: TextStyle(color: Color(0xFF8892A4)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF8892A4)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _loadToys();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_categoryIcons[cat]} $cat',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF8892A4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFF6B35)))
                  : _toys.isEmpty
                      ? const Center(
                          child: Text('Oyuncak bulunamadı ',
                              style: TextStyle(color: Color(0xFF8892A4))))
                      : RefreshIndicator(
                          onRefresh: _loadToys,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: _toys.length,
                            itemBuilder: (_, i) => _ToyCard(
                              toy: _toys[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailScreen(toy: _toys[i]),
                                ),
                              ).then((_) => _loadToys()),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: isParent
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddToyScreen()),
              ).then((_) => _loadToys()),
              backgroundColor: const Color(0xFFFF6B35),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _ToyCard extends StatelessWidget {
  final ToyModel toy;
  final VoidCallback onTap;

  const _ToyCard({required this.toy, required this.onTap});

  static const _typeColors = {
    'takas': Color(0xFFFF6B35),
    'ödünç': Color(0xFF4ECDC4),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: toy.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(toy.imageUrl!,
                            fit: BoxFit.cover, width: double.infinity),
                      )
                    : Text(
                        _categoryEmoji(toy.category),
                        style: const TextStyle(fontSize: 48),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              toy.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (_typeColors[toy.shareType] ?? const Color(0xFFFF6B35))
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    toy.shareType == 'takas' ? '⇄ Takas' : '⏳ Ödünç',
                    style: TextStyle(
                      color: _typeColors[toy.shareType] ?? const Color(0xFFFF6B35),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${toy.ownerName} · ${toy.condition}',
              style: const TextStyle(color: Color(0xFF8892A4), fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
