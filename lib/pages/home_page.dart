import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/note_service.dart';
import '../services/connectivity_service.dart';
import 'api_notes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    final result = await ConnectivityService().isConnected();

    setState(() {
      isConnected = result;
    });
  }

  void showAddNoteDialog() {
    titleController.clear();
    contentController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                ),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<NoteService>().addNote(
                      titleController.text,
                      contentController.text,
                    );

                Navigator.pop(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteService = context.watch<NoteService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc-Notes Local'),
        actions: [
          IconButton(
            icon: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: isConnected ? Colors.green : Colors.red,
            ),
            onPressed: checkConnection,
          ),
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed: () {
              if (isConnected) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ApiNotesPage(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pas de connexion Internet'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: noteService.notes.isEmpty
          ? const Center(
              child: Text('Aucune note pour le moment'),
            )
          : ListView.builder(
              itemCount: noteService.notes.length,
              itemBuilder: (context, index) {
                final note = noteService.notes[index];

                return Dismissible(
                  key: ValueKey(note.id),
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
                    noteService.deleteNote(index);
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}