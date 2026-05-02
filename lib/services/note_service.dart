import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteService extends ChangeNotifier {
  final SharedPreferences prefs;
  final List<Note> _notes = [];

  static const String notesKey = 'notes';

  NoteService(this.prefs) {
    _loadNotes();
  }

  List<Note> get notes => _notes;

  void _loadNotes() {
    final List<String> savedNotes = prefs.getStringList(notesKey) ?? [];

    _notes.clear();

    for (String noteString in savedNotes) {
      final Map<String, dynamic> json = jsonDecode(noteString);
      _notes.add(Note.fromJson(json));
    }

    notifyListeners();
  }

  Future<void> _saveNotes() async {
    final List<String> notesString = _notes
        .map((note) => jsonEncode(note.toJson()))
        .toList();

    await prefs.setStringList(notesKey, notesString);
  }

  Future<void> addNote(String title, String content) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    _notes.add(note);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> deleteNote(int index) async {
    _notes.removeAt(index);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(int index, String title, String content) async {
    _notes[index] = Note(
      id: _notes[index].id,
      title: title,
      content: content,
      createdAt: _notes[index].createdAt,
    );

    await _saveNotes();
    notifyListeners();
  }
}