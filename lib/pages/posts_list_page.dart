import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post_detail_page.dart';

void showCreateBookModal(BuildContext context) {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String body = '';
  int userId = 1;

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text("Crear nuevo libro"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Título"),
                  validator: (value) => value!.isEmpty ? "Campo requerido" : null,
                  onSaved: (value) => title = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Contenido"),
                  validator: (value) => value!.isEmpty ? "Campo requerido" : null,
                  onSaved: (value) => body = value!,
                ),
                DropdownButtonFormField<int>(
                  value: userId,
                  decoration: InputDecoration(labelText: "Usuario"),
                  items: [1, 2, 3, 4, 5].map((id) {
                    return DropdownMenuItem(value: id, child: Text("Usuario $id"));
                  }).toList(),
                  onChanged: (value) => userId = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final response = await http.post(
                  Uri.parse('https://jsonplaceholder.typicode.com/posts'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "title": title,
                    "body": body,
                    "userId": userId,
                  }),
                );

                if (response.statusCode == 201) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Libro creado correctamente")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al crear libro")),
                  );
                }
              }
            },
            child: Text("Crear"),
          ),
        ],
      );
    },
  );
}

class PostsListPage extends StatefulWidget {
  @override
  _PostsListPageState createState() => _PostsListPageState();
}

class _PostsListPageState extends State<PostsListPage> {
  List<dynamic> allPosts = [];
  List<dynamic> filteredPosts = [];
  int currentPage = 1;
  int rowsPerPage = 10;
  String filter = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allPosts = data;
          filteredPosts = data;
          isLoading = false;
        });
      } else {
        throw Exception("Error al cargar los posts");
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void applyFilter() {
    setState(() {
      filteredPosts = allPosts
          .where((post) => post['title'].toString().toLowerCase().contains(filter.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final totalPages = (filteredPosts.length / rowsPerPage).ceil();
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    final visiblePosts = filteredPosts.sublist(
      start,
      end > filteredPosts.length ? filteredPosts.length : end,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Prueba App"),
        backgroundColor: Colors.purple,
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(12),
        child: Text(
          "© 2025 Prueba App - Todos los derechos reservados",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreateBookModal(context);
        },
        tooltip: "Crear libro",
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
// Cuerpo principal
body: isLoading
    ? Center(child: CircularProgressIndicator())
    : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Filtrar por título...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      filter = value;
                      applyFilter();
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: rowsPerPage,
                  onChanged: (value) {
                    setState(() {
                      rowsPerPage = value!;
                      currentPage = 1;
                    });
                  },
                  items: [10, 20, 50].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text("$e por página"),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Mostrando ${filteredPosts.length} resultados",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(
                  label: Text(
                    'ID',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Título',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Contenido',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: visiblePosts.map((post) {
                return DataRow(
                  cells: [
                    DataCell(Text(post['id'].toString())),
                    DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 160),
                        child: Text(
                          post['title'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailPage(postId: post['id']),
                          ),
                        );
                      },
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(                    
      post['body'].toString().substring(0, post['body'].toString().length > 10 ? 10 : post['body'].toString().length),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
  ),
),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
              ),
              Text("Página $currentPage de $totalPages"),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),

    );
  }
}
