import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostDetailPage extends StatefulWidget {
  final int postId;

  PostDetailPage({required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map<String, dynamic>? post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPostDetail();
  }

  Future<void> fetchPostDetail() async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/${widget.postId}'),
        headers: {
          "User-Agent": "Mozilla/5.0",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          post = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar el detalle');
      }
    } catch (e) {
      print("Error al cargar post: $e");
      setState(() {
        isLoading = false;
        post = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle del Libro"),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : post == null
              ? Center(child: Text("No se pudo cargar el libro."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "ID: ${post!['id']}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Título",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            post!['title'],
                            style: TextStyle(fontSize: 16),
                          ),
                          Divider(height: 30),
                          Text(
                            "Contenido",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            post!['body'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
