import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch/models/entry.dart';

class MoodRepository extends ChangeNotifier {
  static const String _storageKey = 'mood_entries_v1';
  final List<Entry> _entries = [];
  bool _isInitialized = false;

  List<Entry> get entries => List.unmodifiable(_entries);
  bool get isInitialized => _isInitialized;

  int get streak {
    if (_entries.isEmpty) return 0;
    
    final sortedDates = _entries
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    // If the latest entry isn't today or yesterday, streak is 0
    if (sortedDates.first.isBefore(checkDate.subtract(const Duration(days: 1)))) {
      return 0;
    }

    for (var date in sortedDates) {
      if (date == checkDate || date == checkDate.subtract(const Duration(days: 1))) {
        currentStreak++;
        checkDate = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return currentStreak;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_storageKey);
    
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _entries.clear();
      _entries.addAll(decoded.map((e) => Entry.fromJson(e)).toList());
    } else {
      // Start with an empty list as requested - No mock data seeding
      _entries.clear();
    }
    
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addEntry(Entry entry) async {
    _entries.add(entry);
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateEntry(Entry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Entry? getEntryById(String id) {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
