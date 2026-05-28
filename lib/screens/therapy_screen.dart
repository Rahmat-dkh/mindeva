import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Semua', 'Kecemasan', 'Karir', 'Keluarga', 'Trauma'];

  // Data psikolog dengan kategori masing-masing
  final List<Map<String, dynamic>> _psychologists = [
    {
      'name': 'Dr. Sarah Adinda, M.Psi',
      'specialty': 'Kecemasan & Depresi',
      'experience': '8 Tahun',
      'rating': '4.9',
      'reviews': '120+',
      'imageUrl': 'https://i.pravatar.cc/150?img=5',
      'isAvailable': true,
      'price': 'Rp 150.000',
      'whatsappNumber': '+628123456789',
      'categories': ['Kecemasan', 'Trauma'],
    },
    {
      'name': 'Dr. Anita Wijaya, M.Psi',
      'specialty': 'Hubungan & Keluarga',
      'experience': '12 Tahun',
      'rating': '5.0',
      'reviews': '300+',
      'imageUrl': 'https://i.pravatar.cc/150?img=9',
      'isAvailable': true,
      'price': 'Rp 200.000',
      'whatsappNumber': '+628987654321',
      'categories': ['Keluarga', 'Kecemasan'],
    },
    {
      'name': 'Budi Santoso, S.Psi, M.Psi',
      'specialty': 'Manajemen Stres & Karir',
      'experience': '5 Tahun',
      'rating': '4.8',
      'reviews': '85+',
      'imageUrl': 'https://i.pravatar.cc/150?img=11',
      'isAvailable': false,
      'price': 'Rp 120.000',
      'whatsappNumber': '+628112233445',
      'categories': ['Karir', 'Trauma'],
    },
    {
      'name': 'Dr. Maya Sari, M.Psi',
      'specialty': 'Trauma & PTSD',
      'experience': '10 Tahun',
      'rating': '4.9',
      'reviews': '200+',
      'imageUrl': 'https://i.pravatar.cc/150?img=20',
      'isAvailable': true,
      'price': 'Rp 175.000',
      'whatsappNumber': '+628111222333',
      'categories': ['Trauma', 'Kecemasan'],
    },
  ];

  List<Map<String, dynamic>> get _filteredPsychologists {
    if (_selectedCategoryIndex == 0) return _psychologists; // Semua
    final selected = _categories[_selectedCategoryIndex];
    return _psychologists.where((p) =>
      (p['categories'] as List<String>).contains(selected)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredPsychologists;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.backgroundDark, const Color(0xFF1E1B4B)]
                : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== PREMIUM HEADER =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sesi Terapi',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Temukan psikolog yang tepat',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section title
                      Text(
                        'Pilih Topik Terapi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blueGrey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Horizontal Category List ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategoryIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? Colors.white12 : Colors.grey.shade200),
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ── Psychologist Cards (filtered) ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                const Text('🔍', style: TextStyle(fontSize: 40)),
                                const SizedBox(height: 12),
                                Text(
                                  'Tidak ada psikolog untuk topik ini',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index.isOdd) return const SizedBox(height: 12);
                            final p = filtered[index ~/ 2];
                            return _buildPremiumPsychologistCard(
                              context: context,
                              name: p['name'],
                              specialty: p['specialty'],
                              experience: p['experience'],
                              rating: p['rating'],
                              reviews: p['reviews'],
                              imageUrl: p['imageUrl'],
                              isAvailable: p['isAvailable'],
                              price: p['price'],
                              whatsappNumber: p['whatsappNumber'],
                            );
                          },
                          childCount: filtered.length * 2 - 1,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to launch WhatsApp chat
  Future<void> _launchWhatsApp(String number, String name) async {
    final url =
        "https://wa.me/${number.replaceAll('+', '')}?text=Halo%20${Uri.encodeComponent(name)}%2C%20saya%20ingin%20konsultasi%20tentang%20...";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  Widget _buildPremiumPsychologistCard({
    required BuildContext context,
    required String name,
    required String specialty,
    required String experience,
    required String rating,
    required String reviews,
    required String imageUrl,
    required bool isAvailable,
    required String price,
    required String whatsappNumber,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: const BorderSide(color: AppColors.primary, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                      ),
                      if (isAvailable)
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.blueGrey.shade900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  rating,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            specialty,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.work_history_rounded,
                              size: 14,
                              color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade300,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$experience Peng.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($reviews ulasan)',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga Sesi',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.blueGrey.shade900,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isAvailable
                        ? () => _launchWhatsApp(whatsappNumber, name)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable
                          ? AppColors.primary
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      foregroundColor: isAvailable
                          ? Colors.white
                          : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                      elevation: isAvailable ? 4 : 0,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      isAvailable ? 'Konsultasi WA' : 'Sedang Penuh',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
