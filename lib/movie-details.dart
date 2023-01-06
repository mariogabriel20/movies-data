import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MovieDetails extends StatefulWidget {
  const MovieDetails({Key? key, required this.movieId}) : super(key: key);
  final String movieId;

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  late Future movieData;

  @override
  void initState() {
    movieData = fetchMovieData(widget.movieId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 240, 240, 240),
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 240, 240, 240),
            title: Text("Detalles", style: TextStyle(color: Colors.black))),
        body: FutureBuilder(
            future: movieData,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Error"));
              } else if (snapshot.hasData) {
                Map dataMap = snapshot.data as Map;
                return ListView(
                  children: [
                    Container(
                        margin: const EdgeInsets.only(
                            left: 64.0, right: 64.0, top: 16.0, bottom: 16.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(40.0),
                            child: Image.network(dataMap["poster"],
                                fit: BoxFit.fill))),
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Año: " + dataMap["year"].toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Duración: " +
                                dataMap["runtime"].toString() +
                                "min",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Disponible en: " + getStreamsAvailability(dataMap),
                            style: TextStyle(fontSize: 16),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0),
                            child: Text(dataMap["description"], style: TextStyle(fontSize: 14), textAlign: TextAlign.justify,),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }

  String getStreamsAvailability(dataMap) {
    if (dataMap["streams"].isEmpty || dataMap["streams"] == null) {
      return "N/A";
    } else {
      return dataMap["streams"].map((e) => e["name"]).toString();
    }
  }
}

Future fetchMovieData(movieId) async {
  final headers = {
    "X-RapidAPI-Key": "a2940bae76mshb14242d98204789p1026fajsnd29b3cfec854",
    "X-RapidAPI-Host": "mdblist.p.rapidapi.com"
  };

  final response = await http.get(
      Uri.parse("https://mdblist.p.rapidapi.com/?i=$movieId"),
      headers: headers);
  Map data = jsonDecode(response.body);
  return data;
}
