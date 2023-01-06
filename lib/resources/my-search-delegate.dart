import 'package:flutter/material.dart';
import 'package:movies_data/main.dart';

class MySearchDelegate extends SearchDelegate {
  MySearchDelegate({required this.fetchMovies, required this.buildList});
  final fetchMovies;
  final buildList;
  late Future movies;

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () => close(context, null), //cerrar barra de buscar
      icon: Icon(Icons.arrow_back));

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
        )
      ];

  @override
  Widget buildResults(BuildContext context) {
    movies = fetchMovies(query);
    return FutureBuilder(
        future: movies,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error"));
          } else if (snapshot.hasData) {
            return ListView(
              children: buildList(snapshot.data),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = ["Better Call Saul", "Dark", "Severance"];
    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            title: Text(suggestion),
            onTap: () {
              query = suggestion;
              showResults(context);
            },
          );
        });
  }
}
