import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/streak_provider.dart';
import '../services/local_storage_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _nameEditController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _nameEditController.dispose();
    super.dispose();
  }

  // Dialog Edit Nama
  void _showEditNameDialog(String currentName) {
    _nameEditController.text = currentName;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Ubah Nama Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _nameEditController,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama baru...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              if (_nameEditController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                final success = await Provider.of<AuthProvider>(context, listen: false)
                    .updateProfileName(_nameEditController.text.trim());
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Nama profil berhasil diperbarui'),
                      backgroundColor: AppColors.moodHappy,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }



  // Aksi Logout
  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final streakProvider = Provider.of<StreakProvider>(context);

    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final userXp = user?.xp ?? 0;
    final userStreak = user?.streak ?? 0;
    final userLevel = streakProvider.getLevel(userXp);

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Saya',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.blueGrey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kelola akun & pencapaianmu',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text('Belum ada notifikasi baru saat ini.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                        ),
                        child: Stack(
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Colors.blueGrey, size: 22),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Top: Profile Info Card
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Fitur ganti foto segera hadir!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/default_avatar.png',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: const Icon(Icons.camera_alt_outlined, size: 12, color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Sobat Mindeva',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.blueGrey.shade800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? 'email@domain.com',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.wb_sunny_rounded, size: 12, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'Terus bertumbuh!',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Button
                      GestureDetector(
                        onTap: () => _showEditNameDialog(user?.name ?? ''),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_outlined, size: 16, color: Colors.blueAccent),
                              const SizedBox(height: 2),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Statistics Grid
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem('Streak', '$userStreak Hari', '🔥', Colors.redAccent, 'Pertahankan!'),
                      ),
                      Container(width: 1, height: 44, color: Colors.grey.withOpacity(0.2)),
                      Expanded(
                        child: _buildStatItem('Total Mood', '${moodProvider.moodLogs.length}', '📊', Colors.blueAccent, 'Kamu hebat!'),
                      ),
                      Container(width: 1, height: 44, color: Colors.grey.withOpacity(0.2)),
                      Expanded(
                        child: _buildStatItem('Level', 'Lv. $userLevel', '🌟', Colors.orangeAccent, 'Berkembang!'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),



                // Achievements / Badges Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lencana Pencapaian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.blueGrey.shade800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (ctx) => DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.6,
                            builder: (_, controller) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Semua Lencana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: streakProvider.achievements.isEmpty
                                        ? const Center(child: Text('Belum ada lencana terbuka.'))
                                        : GridView.builder(
                                            controller: controller,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 1.5,
                                            ),
                                            itemCount: streakProvider.achievements.length,
                                            itemBuilder: (context, index) => _buildBadgeListItem(
                                              streakProvider.achievements[index], index),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Lihat Semua >',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: streakProvider.achievements.isEmpty
                      ? GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Text(
                              'Belum ada lencana. Catat mood & tulis jurnal secara konsisten!',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: streakProvider.achievements.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(right: index < streakProvider.achievements.length - 1 ? 10.0 : 0),
                              child: _buildBadgeListItem(streakProvider.achievements[index], index),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),

                // Settings Section
                Text(
                  'Pengaturan Aplikasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      _buildSettingItem(Icons.person_rounded, Colors.blueAccent, 'Informasi Akun', onTap: () {
                        showDialog(context: context, builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Informasi Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nama: ${user?.name ?? '-'}'),
                              const SizedBox(height: 6),
                              Text('Email: ${user?.email ?? '-'}'),
                            ],
                          ),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
                        ));
                      }),
                      const Divider(height: 1, thickness: 0.5),
                      _buildSettingItem(Icons.lock_rounded, Colors.purpleAccent, 'Keamanan & Privasi', onTap: () {
                        showDialog(context: context, builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Keamanan & Privasi', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('Data kamu dienkripsi dan aman. Fitur ubah password segera hadir.'),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
                        ));
                      }),
                      const Divider(height: 1, thickness: 0.5),
                      _buildSettingItem(Icons.notifications_rounded, Colors.orangeAccent, 'Notifikasi', onTap: () {
                        showDialog(context: context, builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('Pengaturan notifikasi lebih lengkap segera hadir.'),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
                        ));
                      }),
                      const Divider(height: 1, thickness: 0.5),
                      _buildThemeTile(
                        title: 'Mode Gelap',
                        icon: Icons.dark_mode_rounded,
                        color: Colors.indigoAccent,
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (val) {
                          themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Logout Button
                CustomButton(
                  text: 'Keluar Akun',
                  color: Colors.redAccent.withOpacity(0.12),
                  textColor: Colors.redAccent,
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, Color color, String title, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.blueGrey.shade800,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile({
    required String title,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.blueGrey.shade800,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String emoji, Color color, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBadgeListItem(badge, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme colors for badges
    final List<Color> badgeColors = [
      Colors.green,
      Colors.blueAccent,
      Colors.orange,
      Colors.purple,
    ];
    final color = badgeColors[index % badgeColors.length];

    // Choose icon
    Widget badgeIcon = const Text('🏅', style: TextStyle(fontSize: 20));
    if (badge.icon == 'fire') {
      badgeIcon = const Text('🔥', style: TextStyle(fontSize: 20));
    } else if (badge.icon == 'book') {
      badgeIcon = const Text('📝', style: TextStyle(fontSize: 20));
    } else if (badge.icon == 'leaf') {
      badgeIcon = const Text('🌿', style: TextStyle(fontSize: 20));
    }

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: badgeIcon,
          ),
          const SizedBox(height: 6),
          Text(
            badge.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: isDark ? Colors.white : Colors.blueGrey.shade800,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
