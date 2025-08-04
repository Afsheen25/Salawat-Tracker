import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stracker/services/firestore_service.dart';

class MyGoalsPage extends StatefulWidget {
  const MyGoalsPage({Key? key}) : super(key: key);

  @override
  State<MyGoalsPage> createState() => _MyGoalsPageState();
}

class _MyGoalsPageState extends State<MyGoalsPage> {
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  final _monthlyController = TextEditingController();
  final _yearlyController = TextEditingController();

  final Color darkGreen = const Color(0xFF2C6E49);

  bool _readSeerah = false;
  bool _reciteDalail = false;

  final FirestoreService _firestore = FirestoreService();
  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _loadHubbunNabi();
  }

  Future<void> _loadGoals() async {
    try {
      final goals = await _firestore.getGoals();
      setState(() {
        _dailyController.text = (goals['daily_goal'] ?? 100).toString();
        _weeklyController.text = (goals['weekly_goal'] ?? 700).toString();
        _monthlyController.text = (goals['monthly_goal'] ?? 3000).toString();
        _yearlyController.text = (goals['yearly_goal'] ?? 36000).toString();
      });
    } catch (e) {
      debugPrint("Error loading goals: $e");
    }
  }

  Future<void> _loadHubbunNabi() async {
    try {
      final data = await _firestore.getHubbunNabi(DateTime.now());
      setState(() {
        _readSeerah = data['readSeerah'] ?? false;
        _reciteDalail = data['reciteDalail'] ?? false;
      });
    } catch (e) {
      debugPrint("Error loading: $e");
    }
  }

  Future<void> _saveGoals() async {
    try {
      await _firestore.saveGoals({
        'daily_goal': int.tryParse(_dailyController.text) ?? 100,
        'weekly_goal': int.tryParse(_weeklyController.text) ?? 700,
        'monthly_goal': int.tryParse(_monthlyController.text) ?? 3000,
        'yearly_goal': int.tryParse(_yearlyController.text) ?? 36000,
      });

      await _firestore.saveHubbunNabi(DateTime.now(), {
        'readSeerah': _readSeerah,
        'reciteDalail': _reciteDalail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals progress saved!')),
      );
    } catch (e) {
      debugPrint("Error saving: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Goals "),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "🌱 Salawat Goals",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildGoalInput("Daily Goal", _dailyController),
          const SizedBox(height: 12),
          _buildGoalInput("Weekly Goal", _weeklyController),
          const SizedBox(height: 12),
          _buildGoalInput("Monthly Goal", _monthlyController),
          const SizedBox(height: 12),
          _buildGoalInput("Yearly Goal", _yearlyController),
          const SizedBox(height: 24),
          const Divider(thickness: 1),
          const SizedBox(height: 16),
          const Text(
            "Increase your Love for the Prophet ﷺ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text("📖 Read Seerah Today"),
            value: _readSeerah,
            activeColor: darkGreen,
            onChanged: (val) {
              setState(() => _readSeerah = val ?? false);
              _firestore.saveHubbunNabi(DateTime.now(), {
                'readSeerah': _readSeerah,
                'reciteDalail': _reciteDalail,
              });
            },
          ),
          CheckboxListTile(
            title: const Text("📿 Recited Dalā’il al-Khayrāt"),
            value: _reciteDalail,
            activeColor: darkGreen,
            onChanged: (val) {
              setState(() => _reciteDalail = val ?? false);
              _firestore.saveHubbunNabi(DateTime.now(), {
                'readSeerah': _readSeerah,
                'reciteDalail': _reciteDalail,
              });
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveGoals,
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Save All", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: darkGreen),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: darkGreen),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
