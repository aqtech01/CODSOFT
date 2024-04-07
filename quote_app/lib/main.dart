import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class Quote {
  final String content;
  final String author;

  Quote({required this.content, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['content'] ?? "",
      author: json['author'] ?? "Unknown",
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspiring Quotes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuoteScreen(),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late Future<Quote> _quoteFuture;
  String _favoriteQuote = "";

  @override
  void initState() {
    super.initState();
    _quoteFuture = fetchQuote();
    loadFavoriteQuote();
  }

  Future<Quote> fetchQuote() async {
    final response =
        await http.get(Uri.parse('https://api.quotable.io/random'));
    if (response.statusCode == 200) {
      return Quote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load quote');
    }
  }

  Future<void> loadFavoriteQuote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteQuote = prefs.getString('favoriteQuote') ?? "";
    });
  }

  Future<void> saveFavoriteQuote(String quote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('favoriteQuote', quote);
    setState(() {
      _favoriteQuote = quote;
    });
  }

  void shareQuote(String quote) {
    // Implement share functionality here
    print("Shared quote: $quote");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspiring Quotes'),
      ),
      body: Center(
        child: FutureBuilder<Quote>(
          future: _quoteFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Quote quote = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "\"${quote.content}\"",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "- ${quote.author}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons.favorite),
                    color: _favoriteQuote == quote.content ? Colors.red : null,
                    onPressed: () {
                      if (_favoriteQuote == quote.content) {
                        saveFavoriteQuote("");
                      } else {
                        saveFavoriteQuote(quote.content);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      shareQuote(quote.content);
                    },
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _quoteFuture = fetchQuote();
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
