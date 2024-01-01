import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:postgres/postgres.dart';

//API CALLS

const _apiKey =
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwYmM4NTFiZDNmMjQ3MjFjNzVhNTE0NWRlYjkzYzllOCIsInN1YiI6IjY1NGQ0NGMzNjdiNjEzMDBjODRhM2YwNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Vs8nAKbcwB0gN32LiC7RrWBTNVhFa9riDFWdXb0ya9I'; // Replace with your actual API key

enum MovieFilter {
  nowPlaying,
  upcoming,
  topRated,
  popular;

  String get urlName => {
        MovieFilter.nowPlaying: 'now_playing',
        MovieFilter.upcoming: 'upcoming',
        MovieFilter.topRated: 'top_rated',
        MovieFilter.popular: 'popular',
      }[this]!;
}

Future<dynamic> searchMovies(String searchQuery) async {
  final url =
      'https://api.themoviedb.org/3/search/movie?query=$searchQuery&include_adult=false&language=en-US&page=1';

  final options = {
    'method': 'GET',
    'headers': {
      'accept': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    }
  };

  final response = await http.get(Uri.parse(url),
      headers: options['headers'] as Map<String, String>?);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    var results = jsonResponse['results'];
    return results;
  }
}

Future<dynamic> fetchMoviesByFilter(MovieFilter movieFilter,
    {int pageNumber = 1}) async {
  final url =
      'https://api.themoviedb.org/3/movie/${movieFilter.urlName}?language=en-US&page=$pageNumber';

  const headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json;
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<dynamic> fetchMovieDetails(int movieId) async {
  final url = 'https://api.themoviedb.org/3/movie/$movieId?language=en-US';

  const headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print(json);
      return json;
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<bool> addToWatchlist(int userID, int movieID) async {
  final conn = await Connection.open(Endpoint(
    host: '34.150.136.177',
    port: 5432,
    password: r"*4su3FMdAT_S5gp'",
    username: 'postgres',
    database: 'MovieMagic',
  ));

  try {
    await conn.execute(
        'UPDATE "Users"."Users" SET "Watchlist"="Watchlist"||$movieID WHERE id=$userID');
    return true;
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

Future<bool> isInWatchlist(int userID, int movieID) async {
  final conn = await Connection.open(Endpoint(
    host: '34.150.136.177',
    port: 5432,
    password: r"*4su3FMdAT_S5gp'",
    username: 'postgres',
    database: 'MovieMagic',
  ));

  try {
    final result = await conn.execute(
        'SELECT * FROM "Users"."Users" WHERE id=9 AND "Watchlist" @> "[8]"');
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
