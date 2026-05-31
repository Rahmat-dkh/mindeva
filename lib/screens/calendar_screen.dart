import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../providers/mood_provider.dart';
import '../models/mood_model.dart';
import '../widgets/glass_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with AutomaticKeepAliveClientMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Mendapatkan warna berdasarkan jenis mood
  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
        return AppColors.moodHappy;
      case 'neutral':
        return AppColors.moodNeutral;
      case 'sad':
        return AppColors.moodSad;
      case 'angry':
        return AppColors.moodAngry;
      case 'anxious':
        return AppColors.moodAnxious;
      default:
        return Colors.transparent;
    }
  }

  // Helper untuk mencocokkan tanggal log dengan hari di kalender
  List<MoodModel> _getMoodsForDay(DateTime day, List<MoodModel> allLogs) {
    return allLogs.where((log) {
      return log.createdAt.year == day.year &&
          log.createdAt.month == day.month &&
          log.createdAt.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final moodsForSelectedDay = _getMoodsForDay(_selectedDay ?? _focusedDay, moodProvider.moodLogs);
    final moodDistribution = _getMoodDistribution(moodProvider.moodLogs);

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
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // ===== PREMIUM HEADER =====
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kalender Emosi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.blueGrey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pantau pola emosimu setiap harinya.',
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
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 36),
                    ),
                  ],
                ),
              ),

                // Table Calendar Card
                GlassCard(
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    locale: 'id_ID',
                    // Fix hari kepotong: berikan tinggi eksplisit
                    daysOfWeekHeight: 40,
                    rowHeight: 52,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    // Kustom penanda warna mood
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final moods = _getMoodsForDay(day, moodProvider.moodLogs);
                        if (moods.isNotEmpty) {
                          final primaryColor = _getMoodColor(moods.first.mood);
                          return _buildColoredDayCell(day, primaryColor, Colors.white);
                        }
                        return null;
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final moods = _getMoodsForDay(day, moodProvider.moodLogs);
                        final baseColor = moods.isNotEmpty ? _getMoodColor(moods.first.mood) : AppColors.primary;
                        return _buildColoredDayCell(day, baseColor.withOpacity(0.3), isDark ? Colors.white : Colors.blueGrey.shade800, isToday: true);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                        final moods = _getMoodsForDay(day, moodProvider.moodLogs);
                        final baseColor = moods.isNotEmpty ? _getMoodColor(moods.first.mood) : AppColors.primary;
                        return _buildColoredDayCell(day, baseColor, Colors.white, isSelected: true);
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(color: isDark ? Colors.white : Colors.blueGrey.shade800),
                      weekendTextStyle: TextStyle(color: isDark ? Colors.redAccent.shade100 : Colors.red.shade400),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500,
                      ),
                      weekendStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.redAccent.shade100 : Colors.red.shade400,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      formatButtonTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      titleTextStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.blueGrey.shade800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Selected Day Logs List
                Text(
                  'Catatan Mood Tanggal ${DateFormat('dd MMMM yyyy').format(_selectedDay ?? _focusedDay)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                
                if (moodsForSelectedDay.isEmpty)
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Tidak ada entri mood untuk tanggal ini.',
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600),
                      ),
                    ),
                  )
                else
                  ...moodsForSelectedDay.map((log) => _buildDayLogItem(log)),

                const SizedBox(height: 24),

                // Analytics Title
                Text(
                  'Distribusi Emosi Bulanan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blueGrey.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // Pie Chart Card
                GlassCard(
                  child: Column(
                    children: [
                      if (moodProvider.moodLogs.isEmpty)
                        const SizedBox(
                          height: 160,
                          child: Center(child: Text('Belum ada data visualisasi emosi.')),
                        )
                      else ...[
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: _getPieChartSections(moodDistribution),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Legend
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildLegendItem('😊 Senang', AppColors.moodHappy),
                            _buildLegendItem('😐 Calm', AppColors.moodNeutral),
                            _buildLegendItem('😢 Sedih', AppColors.moodSad),
                            _buildLegendItem('😠 Marah', AppColors.moodAngry),
                            _buildLegendItem('😰 Cemas', AppColors.moodAnxious),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColoredDayCell(DateTime day, Color backgroundColor, Color textColor, {bool isSelected = false, bool isToday = false}) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String name, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDayLogItem(MoodModel log) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String emoji = '😐';
    String moodName = 'Netral';
    Color color = AppColors.moodNeutral;

    if (log.mood == 'happy') {
      emoji = '😊';
      moodName = 'Senang';
      color = AppColors.moodHappy;
    } else if (log.mood == 'sad') {
      emoji = '😢';
      moodName = 'Sedih';
      color = AppColors.moodSad;
    } else if (log.mood == 'angry') {
      emoji = '😠';
      moodName = 'Marah';
      color = AppColors.moodAngry;
    } else if (log.mood == 'anxious') {
      emoji = '😰';
      moodName = 'Cemas';
      color = AppColors.moodAnxious;
    }

    final formattedTime = DateFormat('HH:mm').format(log.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : color.withOpacity(0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 6)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          moodName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: isDark ? Colors.white : Colors.blueGrey.shade900,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      log.note.isNotEmpty ? log.note : "Mencatat mood tanpa keterangan tambahan.",
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hitung jumlah emosi
  Map<String, int> _getMoodDistribution(List<MoodModel> logs) {
    final dist = {'happy': 0, 'neutral': 0, 'sad': 0, 'angry': 0, 'anxious': 0};
    for (var log in logs) {
      if (dist.containsKey(log.mood)) {
        dist[log.mood] = dist[log.mood]! + 1;
      }
    }
    return dist;
  }

  // Konversi data emosi ke PieChartSectionData
  List<PieChartSectionData> _getPieChartSections(Map<String, int> distribution) {
    final total = distribution.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return [];

    List<PieChartSectionData> sections = [];
    distribution.forEach((key, count) {
      if (count > 0) {
        final percentage = (count / total * 100).toStringAsFixed(0);
        sections.add(
          PieChartSectionData(
            value: count.toDouble(),
            color: _getMoodColor(key),
            title: '$percentage%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });

    return sections;
  }
}
