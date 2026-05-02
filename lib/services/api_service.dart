import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Note>> getAllNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.take(20).map((item) {
        return Note(
          id: item['id'],
          title: item['title'],
          content: item['body'],
          createdAt: DateTime.now(),
        );
      }).toList();
    } else {
      throw Exception('Erreur lors du chargement des notes');
    }
  }

  Future<bool> createNote(Note note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': note.title,
        'body': note.content,
        'userId': 1,
      }),
    );

    return response.statusCode == 201;
  }

  Future<bool> deleteNote(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
    );

    return response.statusCode == 200;
  }
}