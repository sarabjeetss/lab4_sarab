import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200], // Set background color
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PokemonListScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.jpg',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemonCards = [];
  List<dynamic> filteredCards = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPokemonCards();
  }

  Future<void> fetchPokemonCards() async {
    final dio = Dio();
    final response = await dio.get(
        'https://api.pokemontcg.io/v2/cards?q=name:gardevoir');

    setState(() {
      pokemonCards = response.data['data'];
      filteredCards = pokemonCards;
      isLoading = false;
    });
  }

  void filterCards(String query) {
    setState(() {
      searchQuery = query;
      filteredCards = pokemonCards.where((card) {
        final name = card['name'].toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF87CEEB), // Set the AppBar color to sky blue
        title: Text(
          'Pokémon Cards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: filterCards,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                hintStyle: TextStyle(fontWeight: FontWeight.normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                fillColor: Colors.white, // Set background color to white
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: filteredCards.length,
        itemBuilder: (context, index) {
          final card = filteredCards[index];
          return Container(
            color: index.isEven ? Colors.white : Color(0xFF87CEFA), // Alternate row colors
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 4.0),
              elevation: 4.0,
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                leading: SizedBox(
                  width: 120, // Adjust the size as needed
                  height: 120, // Adjust the size as needed
                  child: Image.network(card['images']['small']),
                ),
                title: Text(
                  card['name'],
                  style: TextStyle(fontWeight: FontWeight.bold), // Make text bold
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailScreen(
                        imageUrl: card['images']['large'],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class PokemonDetailScreen extends StatelessWidget {
  final String imageUrl;

  PokemonDetailScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokémon Card',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: InteractiveViewer(
            child: Image.network(imageUrl),
            minScale: 0.1,
            maxScale: 4.0,
          ),
        ),
      ),
    );
  }
}
