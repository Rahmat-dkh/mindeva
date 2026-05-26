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
                Text(
                  'Profil Saya',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 20),

                // Top: Profile Info Card
                GlassCard(
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.15),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'M',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user?.name ?? 'Sobat Mindeva',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.blueGrey.shade800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                  onPressed: () => _showEditNameDialog(user?.name ?? ''),
                                ),
                              ],
                            ),
                            Text(
                              user?.email ?? 'email@domain.com',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Streak', '$userStreak Hari', '🔥', Colors.amber),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem('Total Mood', '${moodProvider.moodLogs.length}', '📊', AppColors.moodNeutral),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem('Level', 'Lv.$userLevel', '🌟', AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),



                // Achievements / Badges Section
                Text(
                  'Lencana Pencapaian',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: streakProvider.achievements.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada lencana terbuka. Catat mood & tulis jurnal secara konsisten!',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: streakProvider.achievements.map((badge) {
                            return _buildBadgeListItem(badge);
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 24),

                // Settings Section (Dark Theme Toggle)
                Text(
                  'Pengaturan Aplikasi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Dark theme mode
                      _buildThemeTile(
                        title: 'Mode Gelap',
                        icon: Icons.dark_mode_rounded,
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (val) {
                          themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                      const Divider(height: 1),
                      // System Theme mode
                      _buildThemeTile(
                        title: 'Ikuti Tema Sistem',
                        icon: Icons.settings_brightness_rounded,
                        value: themeProvider.themeMode == ThemeMode.system,
                        onChanged: (val) {
                          themeProvider.setThemeMode(val ? ThemeMode.system : ThemeMode.light);
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

  Widget _buildThemeTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.blueGrey.shade800,
            ),
          ),
        ],
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildStatItem(String label, String value, String emoji, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? Colors.white : Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeListItem(badge) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose icon
    Widget badgeIcon = const Text('🏅', style: TextStyle(fontSize: 24));
    if (badge.icon == 'fire') {
      badgeIcon = const Text('🔥', style: TextStyle(fontSize: 24));
    } else if (badge.icon == 'book') {
      badgeIcon = const Text('📝', style: TextStyle(fontSize: 24));
    } else if (badge.icon == 'leaf') {
      badgeIcon = const Text('🌿', style: TextStyle(fontSize: 24));
    }

    return Container(
      width: (MediaQuery.of(context).size.width - 88) / 2, // 2 columns approx
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [AppColors.primaryDark.withOpacity(0.15), AppColors.surfaceDark]
            : [AppColors.primary.withOpacity(0.08), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: badgeIcon,
          ),
          const SizedBox(height: 10),
          Text(
            badge.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark ? Colors.white : Colors.blueGrey.shade800,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            style: TextStyle(fontSize: 9.5, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
