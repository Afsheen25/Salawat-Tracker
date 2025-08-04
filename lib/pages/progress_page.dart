import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Map<DateTime, int> salawatHistory = {};
  Map<DateTime, bool> seerahHistory = {};
  Map<DateTime, bool> dalailHistory = {};
  DateTime selectedMonth = DateTime.now();
  bool isLoading = true;

  int monthlyGoal = 0;
  int yearlyGoal = 0;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final salawatSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('salawatCounts')
          .get();

      final hubbunNabiSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('hubbunNabi')
          .get();

      // Correct path for goals
      final goalsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('goals')
          .get();

      final Map<DateTime, int> salawat = {};
      final Map<DateTime, bool> seerah = {};
      final Map<DateTime, bool> dalail = {};

      for (var doc in salawatSnap.docs) {
        final date = DateFormat('yyyy-MM-dd').parse(doc.id);
        salawat[DateTime(date.year, date.month, date.day)] =
        (doc['count'] ?? 0) as int;
      }

      for (var doc in hubbunNabiSnap.docs) {
        final date = DateFormat('yyyy-MM-dd').parse(doc.id);
        final data = doc.data();
        final normalized = DateTime(date.year, date.month, date.day);
        seerah[normalized] = data['readSeerah'] ?? false;
        dalail[normalized] = data['reciteDalail'] ?? false;
      }

      setState(() {
        salawatHistory = salawat;
        seerahHistory = seerah;
        dalailHistory = dalail;

        // Load goals from the correct path
        final goals = goalsSnap.data() ?? {};
        monthlyGoal = goals['monthly_goal'] ?? 0;
        yearlyGoal = goals['yearly_goal'] ?? 0;

        isLoading = false;
      });
    } catch (e) {
      print("Error loading progress: $e");
      setState(() => isLoading = false);
    }
  }

  // ─────────────────────── Helpers ───────────────────────

  int _calculateStreak(Map<DateTime, dynamic> data, {bool isBoolean = false}) {
    int streak = 0;
    DateTime today = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final normalized = DateTime(date.year, date.month, date.day);
      final value = data[normalized];

      if (isBoolean ? value == true : (value ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateBestStreak(Map<DateTime, dynamic> data, {bool isBoolean = false}) {
    int best = 0, current = 0;
    final sorted = data.keys.toList()..sort();

    for (final date in sorted) {
      final value = data[date];
      if (isBoolean ? value == true : (value ?? 0) > 0) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }

    return best;
  }

  int _calculateMonthTotal(Map<DateTime, dynamic> data, {bool isBoolean = false}) {
    return data.entries
        .where((entry) =>
    entry.key.year == selectedMonth.year &&
        entry.key.month == selectedMonth.month &&
        (isBoolean ? entry.value == true : (entry.value ?? 0) > 0))
        .fold(0, (sum, e) =>
    isBoolean ? sum + 1 : sum + ((e.value ?? 0) as num).toInt());
  }

  int _calculateYearTotal(Map<DateTime, dynamic> data, {bool isBoolean = false}) {
    return data.entries
        .where((entry) =>
    entry.key.year == selectedMonth.year &&
        (isBoolean ? entry.value == true : (entry.value ?? 0) > 0))
        .fold(0, (sum, e) =>
    isBoolean ? sum + 1 : sum + ((e.value ?? 0) as num).toInt());
  }

  String _getMotivation(int streak) {
    if (streak >= 30) return "🌟 MashaAllah! 30-day streak!";
    if (streak >= 7) return "🔥 You're on fire!";
    if (streak >= 3) return "✨ Keep going!";
    return "Start your journey today!";
  }

  void _prevMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  // ─────────────────────── UI ───────────────────────

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Progress")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MonthNavigator(
              selectedMonth: selectedMonth,
              onPrev: _prevMonth,
              onNext: _nextMonth,
            ),
            const SizedBox(height: 12),

            _StatBlock(
              icon: "📆",
              label: "This Month (Salawat)",
              value: _calculateMonthTotal(salawatHistory).toString(),
            ),
            _StatBlock(
              icon: "🔥",
              label: "Current Streak",
              value: _calculateStreak(salawatHistory).toString(),
            ),
            _StatBlock(
              icon: "🏆",
              label: "Best Streak",
              value: _calculateBestStreak(salawatHistory).toString(),
            ),
            Text(_getMotivation(_calculateStreak(salawatHistory))),
            const SizedBox(height: 20),

            Text("🎯 Goal Progress", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _TextProgressBar(
              label: "Monthly",
              value: _calculateMonthTotal(salawatHistory).toDouble(),
              goal: monthlyGoal.toDouble(),
            ),
            _TextProgressBar(
              label: "Yearly",
              value: _calculateYearTotal(salawatHistory).toDouble(),
              goal: yearlyGoal.toDouble(),
            ),

            const SizedBox(height: 20),
            const Text("Salawat Recited"),
            _buildCalendarHeader(),
            const SizedBox(height: 4),
            _buildHeatmap(salawatHistory, today),

            const SizedBox(height: 24),
            _GoalSection(
              title: "Read Seerah",
              data: seerahHistory,
              selectedMonth: selectedMonth,
              today: today,
            ),
            const SizedBox(height: 24),
            _GoalSection(
              title: "Dalā’il al-Khayrāt",
              data: dalailHistory,
              selectedMonth: selectedMonth,
              today: today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
          .map((d) => Expanded(
        child: Center(
          child: Text(d,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildHeatmap(Map<DateTime, int> data, DateTime today) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth =
    DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final weekOffset = firstDay.weekday % 7;

    return GridView.builder(
      itemCount: daysInMonth + weekOffset,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemBuilder: (context, index) {
        if (index < weekOffset) return const SizedBox.shrink();
        final day = index - weekOffset + 1;
        final date = DateTime(selectedMonth.year, selectedMonth.month, day);
        final count = data[date] ?? 0;

        Color color;
        if (count >= 50) {
          color = isDark ? Colors.greenAccent.shade700 : Colors.green.shade800;
        } else if (count >= 20) {
          color = isDark ? Colors.greenAccent.shade400 : Colors.green.shade500;
        } else if (count > 0) {
          color = isDark ? Colors.greenAccent.shade100 : Colors.green.shade200;
        } else {
          color = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
        }

        return Tooltip(
          message: "${DateFormat.MMMd().format(date)}: $count",
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: DateUtils.isSameDay(date, today)
                  ? Border.all(color: Colors.black, width: 2)
                  : null,
            ),
            child: Center(
              child: Text("$day",
                  style: TextStyle(
                    color: count > 0 ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────── Reusable Widgets ───────────────────────

class _MonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: onPrev, icon: const Icon(Icons.arrow_back_ios)),
        Text(DateFormat.yMMMM().format(selectedMonth),
            style: Theme.of(context).textTheme.titleLarge),
        IconButton(onPressed: onNext, icon: const Icon(Icons.arrow_forward_ios)),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text("$icon $label: $value",
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _TextProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final double goal;

  const _TextProgressBar({
    required this.label,
    required this.value,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (value / goal).clamp(0, 1) : 0.0;
    final color = percent >= 1
        ? Colors.green
        : Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label Goal: ${value.toInt()} / ${goal.toInt()}",
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: percent?.toDouble() ?? 0.0,
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
class _GoalSection extends StatelessWidget {
  final String title;
  final Map<DateTime, bool> data;
  final DateTime selectedMonth;
  final DateTime today;

  const _GoalSection({
    required this.title,
    required this.data,
    required this.selectedMonth,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth =
    DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final weekOffset = firstDay.weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((d) => Expanded(
            child: Center(
              child: Text(d,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          itemCount: daysInMonth + weekOffset,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            if (index < weekOffset) return const SizedBox.shrink();
            final day = index - weekOffset + 1;
            final date = DateTime(selectedMonth.year, selectedMonth.month, day);
            final value = data[date] ?? false;

            Color color = value
                ? (isDark ? Colors.greenAccent : Colors.green.shade800)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300);

            return Tooltip(
              message: "${DateFormat.MMMd().format(date)}: ${value ? '✓' : '✗'}",
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: DateUtils.isSameDay(date, today)
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    "$day",
                    style: TextStyle(
                      color: value ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
