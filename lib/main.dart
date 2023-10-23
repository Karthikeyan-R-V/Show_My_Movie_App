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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String movieName = '';

  void toggleDarkMode(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  Future<void> fetchMovieData(String query) async {
    var apiKey = 'c731cc03'; // Replace with your actual API key
    var url = Uri.parse('http://www.omdbapi.com/?apikey=$apiKey&t=$query');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(data: data),
        ),
      );
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Color goldColor = Color(0xFFFFD700);
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
        ],
      ),
      backgroundColor:
          themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[300],
    );
  }
}

class ResultPage extends StatelessWidget {
  final dynamic data;

  const ResultPage({Key? key, required this.data}) : super(key: key);

  void toggleDarkMode(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(data['Title']),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['Poster'] != 'N/A')
                Center(
                  child: Image.network(
                    data['Poster'],
                    height: 300,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Title: ${data['Title']}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Year: ${data['Year']}'),
              Text('Rated: ${data['Rated']}'),
              Text('Released: ${data['Released']}'),
              Text('Runtime: ${data['Runtime']}'),
              Text('Genre: ${data['Genre']}'),
              Text('Director: ${data['Director']}'),
              Text('Actors: ${data['Actors']}'),
              const SizedBox(height: 10),
              Text(
                'Plot:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(data['Plot']),
              const SizedBox(height: 10),
              Text(
                'IMDb Rating: ${data['imdbRating']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      backgroundColor:
          themeProvider.isDarkMode ? Colors.grey[900] : Colors.grey[300],
    );
  }
}
