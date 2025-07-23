import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pages/posts_list_page.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca App',
      home: PostsListPage(),
    );
  }
}

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar los posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Posts')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post['title']),
                  subtitle: Text(post['body']),
                );
              },
            ),
    );
  }
}
