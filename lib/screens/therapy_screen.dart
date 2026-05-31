import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../core/config.dart';
import '../core/theme.dart';
import '../widgets/glass_card.dart';
import '../providers/auth_provider.dart';
import 'premium_screen.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Semua',
    'Kecemasan',
    'Karir',
    'Keluarga',
    'Trauma',
  ];

  // Status Booking untuk simulasi (0: Belum Booking, 1: Menunggu Approval, 2: Approved)
  final Map<String, int> _bookingStatus = {};

  // Data psikolog dengan kategori masing-masing
  List<Map<String, dynamic>> _psychologists = [
    {
      'name': 'Hidayat, S.Psi, M.Psi',
      'specialty': 'Konsultasi Umum',
      'experience': '2 Tahun',
      'rating': '5.0',
      'reviews': '15+',
      'imageUrl': 'https://i.pravatar.cc/150?img=11',
      'isAvailable': true,
      'price': 'Rp 100.000',
      'whatsappNumber': '+6281234567890',
      'categories': ['Semua', 'Karir'],
    },
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
    return _psychologists
        .where((p) => (p['categories'] as List<String>).contains(selected))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchPsychologists();
  }

  Future<void> _fetchPsychologists() async {
    if (!AppConfig.useFirebase) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'psychologist')
          .get();

      final List<Map<String, dynamic>> fetchedDocs = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        fetchedDocs.add({
          'name': data['name'] ?? 'Psikolog Baru',
          'specialty': 'Konsultasi Umum',
          'experience': '1 Tahun',
          'rating': '5.0',
          'reviews': '0',
          'imageUrl': 'https://i.pravatar.cc/150?u=${doc.id}',
          'isAvailable': true,
          'price': 'Rp 100.000',
          'whatsappNumber': '+628000000000', // Default placeholder
          'categories': ['Semua', 'Kecemasan'],
        });
      }

      if (mounted && fetchedDocs.isNotEmpty) {
        setState(() {
          for (var p in fetchedDocs) {
            if (!_psychologists.any((exist) => exist['name'] == p['name'])) {
              _psychologists.insert(0, p);
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil psikolog: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredPsychologists;
    final isPremium =
        Provider.of<AuthProvider>(context).user?.isPremium ?? false;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF0F6FF),
      body: CustomScrollView(
        slivers: [
          // ── BLUE SCROLLABLE HEADER ──
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF0A1128), const Color(0xFF162545)]
                      : [AppColors.secondary, AppColors.primary],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, topPadding, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 2),
                      child: Text(
                        'Sesi Terapi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Text(
                        'Temukan psikolog yang tepat untukmu',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Section title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Pilih Topik Terapi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blueGrey.shade800,
                ),
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
                            : (isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? Colors.white12
                                    : Colors.grey.shade200),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.grey.shade400
                                    : Colors.blueGrey.shade600),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
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
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.blueGrey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
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
                        isPremiumUser: isPremium,
                      );
                    }, childCount: filtered.length * 2 - 1),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // Helper to launch WhatsApp chat
  Future<void> _launchWhatsApp(String number, String name) async {
    final isPremium =
        Provider.of<AuthProvider>(context, listen: false).user?.isPremium ??
        false;

    if (!isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PremiumScreen()),
      );
      return;
    }

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

  void _showBookingDialog(String doctorName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.backgroundDark
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Booking Jadwal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Konsultasi dengan $doctorName',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pilih Topik Konsultasi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cth: Kecemasan, Masalah keluarga',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Waktu (Simulasi):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: 'Hari ini, 15:00',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                'Hari ini, 15:00',
                'Besok, 10:00',
                'Lusa, 13:00',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _bookingStatus[doctorName] = 1; // Menunggu persetujuan
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Booking berhasil dikirim! Menunggu persetujuan psikolog.',
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );

                  // Simulasi otomatis disetujui setelah 3 detik
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _bookingStatus[doctorName] = 2; // Disetujui
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Jadwal konsultasi telah disetujui!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kirim Permintaan Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    required bool isPremiumUser,
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
            border: Border(
              left: const BorderSide(color: AppColors.primary, width: 4),
            ),
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
                          radius: 22,
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
                                  color: isDark
                                      ? Colors.white
                                      : Colors.blueGrey.shade900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  rating,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.blueGrey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.work_history_rounded,
                              size: 14,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.blueGrey.shade300,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$experience Peng.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.blueGrey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($reviews ulasan)',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (isPremiumUser) {
                      if (!isAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Psikolog sedang offline/penuh.'),
                          ),
                        );
                        return;
                      }

                      final status = _bookingStatus[name] ?? 0;
                      if (status == 0) {
                        _showBookingDialog(name);
                      } else if (status == 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Jadwal Anda sedang menunggu persetujuan psikolog.',
                            ),
                          ),
                        );
                      } else if (status == 2) {
                        _launchWhatsApp(whatsappNumber, name);
                      } else if (status == 3) {
                        _showRatingDialog(name);
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable
                        ? ((_bookingStatus[name] ?? 0) == 3
                              ? Colors.orange
                              : AppColors.primary)
                        : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300),
                    foregroundColor: isAvailable
                        ? Colors.white
                        : (isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500),
                    elevation: isAvailable ? 4 : 0,
                    shadowColor:
                        ((_bookingStatus[name] ?? 0) == 3
                                ? Colors.orange
                                : AppColors.primary)
                            .withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: Builder(
                    builder: (context) {
                      if (!isAvailable) {
                        return const Text(
                          'Sedang Offline',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }

                      final status = _bookingStatus[name] ?? 0;
                      if (!isPremiumUser) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                size: 12,
                                color: Colors.orangeAccent,
                              ),
                            ),
                            Text(
                              'Booking Jadwal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }

                      if (status == 0) {
                        return const Text(
                          'Booking Jadwal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      } else if (status == 1) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Menunggu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      } else if (status == 2) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.chat_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'WA Sesuai Jadwal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Beri Rating',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
              if ((_bookingStatus[name] ?? 0) == 2) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _bookingStatus[name] = 3; // Selesai, siap rating
                      });
                    },
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 12,
                      color: Colors.green,
                    ),
                    label: const Text(
                      'Selesaikan Sesi',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(String doctorName) {
    int _rating = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Nilai Sesi Anda',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bagaimana konsultasi Anda dengan $doctorName?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.orange,
                      size: 32,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis ulasan Anda (opsional)...',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _bookingStatus[doctorName] = 0; // Reset ke awal
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terima kasih atas penilaian Anda!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Kirim Rating',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
