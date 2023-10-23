import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String movieName = '';

  void toggleDarkMode(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  Future<List<dynamic>> fetchMovieData(String query) async {
    var apiKey = 'c731cc03'; // Replace with your actual API key
    var url = Uri.parse('http://www.omdbapi.com/?apikey=$apiKey&s=$query');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['Response'] == "True") {
          return data['Search'];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
      return [];
    }
  }

  Color goldColor = const Color(0xFFFFD700);
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple, // Set your rich color theme here
        title: Text(
          "Show My Movies",
          style: TextStyle(color: goldColor), // Set gold as the font color
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => toggleDarkMode(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                themeProvider.isDarkMode ? 'assets/moon.png' : 'assets/sun.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  movieName = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter Movie Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => fetchMovieData(movieName),
            child: const Text('Search'),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchMovieData(movieName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var movie = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultPage(movie: movie),
                            ),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            title:
                                Text(movie['Title'] ?? 'Title not available'),
                            subtitle: Text(
                                'Year: ${movie['Year'] ?? 'Year not available'}'),
                            leading: movie['Poster'] != null &&
                                    movie['Poster'] != 'N/A'
                                ? Image.network(movie['Poster']!,
                                    height: 50, width: 50, fit: BoxFit.cover)
                                : const Icon(Icons.movie),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No movies found'));
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor:
          themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[300],
    );
  }
}

class ResultPage extends StatelessWidget {
  final dynamic movie;

  const ResultPage({Key? key, required this.movie}) : super(key: key);

  Future<dynamic> fetchMovieDetails(String imdbID) async {
    var apiKey = 'c731cc03'; // Replace with your actual API key
    var url = Uri.parse('http://www.omdbapi.com/?apikey=$apiKey&i=$imdbID');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        return {};
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['Title'] ?? 'Title not available'),
      ),
      body: FutureBuilder(
        future: fetchMovieDetails(movie['imdbID']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data['Poster'] != null && data['Poster'] != 'N/A')
                      Center(
                        child: Image.network(
                          data['Poster'],
                          height: 300,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Title: ${data['Title'] ?? 'Title not available'}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('Year: ${data['Year'] ?? 'Year not available'}'),
                    Text('Rated: ${data['Rated'] ?? 'Rating not available'}'),
                    Text(
                        'Released: ${data['Released'] ?? 'Release date not available'}'),
                    Text(
                        'Runtime: ${data['Runtime'] ?? 'Runtime not available'}'),
                    Text('Genre: ${data['Genre'] ?? 'Genre not available'}'),
                    Text(
                        'Director: ${data['Director'] ?? 'Director not available'}'),
                    Text('Actors: ${data['Actors'] ?? 'Actors not available'}'),
                    const SizedBox(height: 10),
                    const Text(
                      'Plot:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(data['Plot'] ?? 'Plot not available'),
                    const SizedBox(height: 10),
                    Text(
                      'IMDb Rating: ${data['imdbRating'] ?? 'Rating not available'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No movie details found'));
          }
        },
      ),
    );
  }
}
