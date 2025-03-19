import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Corrected import
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(PokemonBattleApp());
}

class PokemonBattleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon Battle',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PokemonBattleScreen(),
    );
  }
}

class PokemonBattleScreen extends StatefulWidget {
  @override
  _PokemonBattleScreenState createState() => _PokemonBattleScreenState();
}

class _PokemonBattleScreenState extends State<PokemonBattleScreen> {
  final String apiUrl = "https://api.pokemontcg.io/v2/cards";
  Map<String, dynamic>? pokemonx;
  Map<String, dynamic>? pokemony;
  String winnerMessage = "Press the button to start the battle!";

  @override
  void initState() {
    super.initState();
    fetchRandomPokemon();
  }

  Future<void> fetchRandomPokemon() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      final random = Random();

      // Get two random Pokémon cards
      Map<String, dynamic> p1 = data[random.nextInt(data.length)];
      Map<String, dynamic> p2 = data[random.nextInt(data.length)];

      setState(() {
        pokemonx = p1;
        pokemony = p2;
        winnerMessage = determineWinner(p1, p2);
      });
    } else {
      setState(() {
        winnerMessage = "Failed to load Pokémon data!";
      });
    }
  }

  String determineWinner(Map<String, dynamic> p1, Map<String, dynamic> p2) {
    int hp1 = int.tryParse(p1['hp'] ?? '0') ?? 0;
    int hp2 = int.tryParse(p2['hp'] ?? '0') ?? 0;

    if (hp1 > hp2) {
      return "${p1['name']} Wins!";
    } else if (hp2 > hp1) {
      return "${p2['name']} Wins!";
    } else {
      return "It's a Tie!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon Battle'),
        backgroundColor: Colors.deepPurple, // Changed app bar color
      ),
      backgroundColor: Colors.purple.shade50, // Set a soft background color for the whole screen
      body: pokemonx == null || pokemony == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PokemonCardWidget(pokemon: pokemonx!),
              Text(
                "VS",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              PokemonCardWidget(pokemon: pokemony!),
            ],
          ),
          SizedBox(height: 20),
          Text(
            winnerMessage,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchRandomPokemon,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle: TextStyle(fontSize: 18),
            ),
            child: Text("Battle Again!"),
          ),
        ],
      ),
    );
  }
}

class PokemonCardWidget extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  PokemonCardWidget({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          pokemon['images']['small'],
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 10),
        Text(
          pokemon['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          "HP: ${pokemon['hp'] ?? 'N/A'}",
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
      ],
    );
  }
}