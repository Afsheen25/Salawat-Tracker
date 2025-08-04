import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? 'unknown';

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  // ========================= DAILY SALAWAT COUNT =========================
  Future<void> saveDailyCount(DateTime date, int count) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('salawatCounts')
        .doc(_dateKey(date));
    await docRef.set({'count': count}, SetOptions(merge: true));
  }

  Future<int> getDailyCount(DateTime date) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('salawatCounts')
        .doc(_dateKey(date))
        .get();
    return (doc.data()?['count'] ?? 0) as int;
  }

  // ========================= SALAWAT HISTORY (ALL-TIME FOR PROGRESS PAGE) =========================
  Future<Map<DateTime, int>> getSalawatHistory() async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('salawatCounts')
        .get();

    final Map<DateTime, int> history = {};
    for (var doc in snapshot.docs) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(doc.id);
        history[DateTime(date.year, date.month, date.day)] = (doc['count'] ?? 0) as int;
      } catch (_) {}
    }
    return history;
  }

  // ========================= SALAWAT MONTHLY CHART =========================
  Future<Map<String, int>> getSalawatCountsForMonth(int year, int month) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('salawatCounts')
        .get();

    final Map<String, int> filtered = {};
    for (var doc in snapshot.docs) {
      final id = doc.id; // yyyy-MM-dd
      final docDate = DateTime.tryParse(id);
      if (docDate != null && docDate.year == year && docDate.month == month) {
        filtered[id] = (doc.data()['count'] ?? 0) as int;
      }
    }
    return filtered;
  }

  // ========================= HUBBUN NABI CHECKBOXES =========================
  Future<void> saveHubbunNabi(DateTime date, Map<String, bool> values) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('hubbunNabi')
        .doc(_dateKey(date));
    await docRef.set(values, SetOptions(merge: true));
  }

  Future<Map<String, bool>> getHubbunNabi(DateTime date) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('hubbunNabi')
        .doc(_dateKey(date))
        .get();

    final data = doc.data() ?? {};
    return {
      'readSeerah': data['readSeerah'] ?? false,
      'reciteDalail': data['reciteDalail'] ?? false,
    };
  }

  // ========================= HUBBUN NABI HISTORY (ALL-TIME FOR PROGRESS PAGE) =========================
  Future<Map<String, Map<DateTime, bool>>> getHubbunNabiHistory() async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('hubbunNabi')
        .get();

    final Map<DateTime, bool> seerahMap = {};
    final Map<DateTime, bool> dalailMap = {};

    for (var doc in snapshot.docs) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(doc.id);
        final normalized = DateTime(date.year, date.month, date.day);
        final data = doc.data();
        seerahMap[normalized] = data['readSeerah'] ?? false;
        dalailMap[normalized] = data['reciteDalail'] ?? false;
      } catch (_) {}
    }

    return {
      'seerah': seerahMap,
      'dalail': dalailMap,
    };
  }

  // ========================= HUBBUN NABI FILTERED MONTHLY DATA =========================
  Future<Map<String, Map<String, bool>>> getHubbunNabiForMonth(int year, int month) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('hubbunNabi')
        .get();

    final Map<String, Map<String, bool>> filtered = {};

    for (var doc in snapshot.docs) {
      final id = doc.id; // yyyy-MM-dd
      final docDate = DateTime.tryParse(id);
      if (docDate != null && docDate.year == year && docDate.month == month) {
        final data = doc.data();
        filtered[id] = {
          'readSeerah': data['readSeerah'] ?? false,
          'reciteDalail': data['reciteDalail'] ?? false,
        };
      }
    }

    return filtered;
  }

  // ========================= SALAWAT GOALS =========================
  Future<void> saveGoals(Map<String, int> goals) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('goals')
        .set(goals);
  }

  Future<Map<String, int>> getGoals() async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('goals')
        .get();

    final data = doc.data() ?? {};
    return {
      'daily_goal': data['daily_goal'] ?? 100,
      'weekly_goal': data['weekly_goal'] ?? 700,
      'monthly_goal': data['monthly_goal'] ?? 3000,
      'yearly_goal': data['yearly_goal'] ?? 36000,
    };
  }
}
