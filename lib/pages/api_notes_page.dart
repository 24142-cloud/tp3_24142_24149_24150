import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/api_service.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  final ApiService apiService = ApiService();

  List<Note> notes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final result = await apiService.getAllNotes();

      setState(() {
        notes = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de chargement';
      });
    }
  }

  Future<void> addApiNote() async {
    final note = Note(
      title: 'Nouvelle note API',
      content: 'Note créée depuis Flutter',
      createdAt: DateTime.now(),
    );

    final success = await apiService.createNote(note);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note créée avec succès'),
        ),
      );

      setState(() {
        notes.insert(0, note);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création'),
        ),
      );
    }
  }

  Future<void> deleteApiNote(int index) async {
    final note = notes[index];

    if (note.id == null) return;

    final success = await apiService.deleteNote(note.id!);

    if (success) {
      setState(() {
        notes.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (errorMessage != null) {
      body = Center(
        child: Text(errorMessage!),
      );
    } else {
      body = ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          return Dismissible(
            key: ValueKey(note.id ?? index),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) {
              deleteApiNote(index);
            },
            child: Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes API'),
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: addApiNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}