import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/note.dart';
import '../models/habit.dart';
import '../models/budget.dart';
import '../models/subscription.dart';
import '../models/goal.dart';

class StorageService {
  static const _tasksKey = 'tasks';
  static const _notesKey = 'notes';
  static const _habitsKey = 'habits';
  static const _budgetKey = 'budget';
  static const _subscriptionsKey = 'subscriptions';
  static const _goalsKey = 'goals';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Task.fromJson(e)).toList();
  }
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Note.fromJson(e)).toList();
  }
  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesKey, jsonEncode(notes.map((e) => e.toJson()).toList()));
  }

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_habitsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Habit.fromJson(e)).toList();
  }
  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_habitsKey, jsonEncode(habits.map((e) => e.toJson()).toList()));
  }

  Future<List<BudgetItem>> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_budgetKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => BudgetItem.fromJson(e)).toList();
  }
  Future<void> saveBudget(List<BudgetItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<List<Subscription>> loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_subscriptionsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Subscription.fromJson(e)).toList();
  }
  Future<void> saveSubscriptions(List<Subscription> subs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subscriptionsKey, jsonEncode(subs.map((e) => e.toJson()).toList()));
  }

  Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Goal.fromJson(e)).toList();
  }
  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalsKey, jsonEncode(goals.map((e) => e.toJson()).toList()));
  }
}
