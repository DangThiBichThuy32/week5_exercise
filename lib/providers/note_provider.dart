import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all notes from database
  Future<void> loadNotes() async {
    try {
      _setLoading(true);

      _notes = await DatabaseHelper.instance.readAll();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Failed to load notes";
      print("❌ loadNotes error: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Add new note
  Future<void> addNote(Note note) async {
    try {
      await DatabaseHelper.instance.create(note);
      _notes.insert(0, note);   // UI mượt hơn
      notifyListeners();
    } catch (e) {
      print("❌ addNote error: $e");
    }
  }

  /// Update existing note
  Future<void> updateNote(Note note) async {
    try {
      await DatabaseHelper.instance.update(note);

      // Update in list without reloading DB
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        notifyListeners();
      }
    } catch (e) {
      print("❌ updateNote error: $e");
    }
  }

  /// Delete note
  Future<void> deleteNote(int id) async {
    try {
      await DatabaseHelper.instance.delete(id);

      _notes.removeWhere((note) => note.id == id);
      notifyListeners();
    } catch (e) {
      print("❌ deleteNote error: $e");
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
