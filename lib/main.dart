import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_data/resources/my-search-delegate.dart';

import 'movie-details.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future movies;

  @override
  void initState() {
    movies = fetchMovies("all");
    super.initState();
  }

  // void searchMovies(searchWord) {
  //   setState(() {
  //     movies = fetchMovies(searchWord);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 240, 240, 240),
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 240, 240, 240),
            title: const Text("Busca una película o serie",
                style: TextStyle(color: Colors.black)),
            actions: [
              IconButton(
                  color: Colors.black,
                  onPressed: (() {
                    showSearch(
                        context: context,
                        delegate: MySearchDelegate(
                            fetchMovies: fetchMovies, buildList: buildList));
                  }),
                  icon: Icon(Icons.search))
            ]),
        body: FutureBuilder(
          future: movies,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Error"));
            } else if (snapshot.hasData) {
              return ListView(
                children: buildList(snapshot.data),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  List<Widget> buildList(data) {
    List<Widget> list = [];
    Color scoreColor;
    for (var i = 0; i < (data["search"] ?? []).length; i++) {
      //TUVE QUE AGREGAR UN "?? []" PORQUE EN LA BARRA DE BÚSQUEDA AL APRETAR LA X SE BORRA EL TEXTO PERO TAMBIÉN BUSCA Y DEVOLVIA VALOR NULO
      if (data["search"][i]["score_average"] != null) {
        if (data["search"][i]["score_average"] >= 70) {
          scoreColor = Color.fromARGB(255, 20, 175, 0);
        } else if (data["search"][i]["score_average"] >= 40 &&
            data["search"][i]["score_average"] < 70) {
          scoreColor = Color.fromARGB(255, 218, 203, 0);
        } else {
          scoreColor = Color.fromARGB(255, 209, 0, 0);
        }
      }else{
        scoreColor = Colors.grey;
      }

      list.add(ListTile(
        leading: FractionallySizedBox(
          widthFactor: 0.2,
          heightFactor: 1.2,
          child: Container(
              decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              margin: const EdgeInsets.all(16.0),
              child: Center(
                  child: Text((data["search"][i]["score_average"] ?? "-").toString()))),
        ),
        title: Text(
          data["search"][i]["title"] + (' (${data["search"][i]["year"] ?? 'N/A'})'),
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: Text(data["search"][i]["type"].toUpperCase()),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MovieDetails(movieId: data["search"][i]["id"]))),
      ));
    }
    return list;
  }
}

Future fetchMovies(String searchWord) async {
  final headers = {
    "X-RapidAPI-Key": "APIKEY HERE",
    "X-RapidAPI-Host": "mdblist.p.rapidapi.com"
  };

  final response = await http.get(
      Uri.parse("https://mdblist.p.rapidapi.com/?s=$searchWord"),
      headers: headers);
  Map data = jsonDecode(response.body);
  return data;
}
