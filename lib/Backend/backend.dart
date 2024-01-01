import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:crypt/crypt.dart';

//API CALLS

const _apiKey = '...'; // Replace with your actual API key

dynamic _endPoint = Endpoint(
  host: '...',
  port: 0,
  password: r"...",
  username: '...',
  database: '...',
);

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
      'Authorization': '...',
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
    'Authorization': '...',
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
    'Authorization': '...',
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

Future<Map<String, dynamic>> fetchMovieReviews(int movieId) async {
  final url =
      'https://api.themoviedb.org/3/movie/$movieId/reviews?language=en-US&page=1';

  final options = {
    'method': 'GET',
    'headers': {
      'accept': 'application/json',
      'Authorization': '...' //API KEY
    }
  };

  try {
    final response = await http.get(Uri.parse(url),
        headers: options['headers'] as Map<String, String>?);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse; // Return the reviews data
    } else {
      print('Error: ${response.statusCode}');
      return {}; // or return some default value if there's an error
    }
  } catch (error) {
    print('Error: $error');
    return {}; // or return some default value if there's an error
  }
}

Future<bool> addToWatchlist(int userID, int movieID) async {
  final conn = await Connection.open(_endPoint);

  try {
    final result = await conn.execute(
        'UPDATE "Users"."Users" SET "Watchlist"="Watchlist"||\'$movieID\' WHERE id=$userID');
    return true;
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

Future<bool> removeFromWatchlist(int userID, int movieID) async {
  final conn = await Connection.open(_endPoint);

  try {
    final List<dynamic> getList = await getWatchList(userID);
    getList.remove(movieID);
    String newList = getList.toString();
    final result = await conn.execute(
        'UPDATE "Users"."Users" SET "Watchlist"=\'$newList\' WHERE id=$userID');
    return true;
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

Future<bool> isInWatchlist(int userID, int movieID) async {
  final conn = await Connection.open(_endPoint);

  try {
    final result = await conn.execute(
        'SELECT * FROM "Users"."Users" WHERE id=$userID AND "Watchlist" @> \'[$movieID]\'');
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

Future<dynamic> getWatchList(int userID) async {
  final conn = await Connection.open(_endPoint);

  try {
    final result =
        await conn.execute('SELECT * FROM "Users"."Users" WHERE id=$userID');
    if (result.isNotEmpty) {
      print(result[0][4]);
      return result[0][4];
    } else {
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

Future<bool> createUser(
    String firstName, String lastName, String email, String password) async {
  final conn = await Connection.open(_endPoint);
  String newPassword = Crypt.sha256(password, salt: 'MovieMagic').toString();

  String lowerCaseEmail = email.toLowerCase();

  try {
    final result = await conn.execute(
        'INSERT INTO "Users"."Users" VALUES (\'$firstName\', \'$lastName\', \'$lowerCaseEmail\', \'$newPassword\', \'[]\')');
    print(result);
    return true;
  } catch (error) {
    print('Error registering user:, $error');
    return false;
  }
}

Future<dynamic> signIn(String email, String password) async {
  final conn = await Connection.open(_endPoint);
  String newPassword = Crypt.sha256(password, salt: 'MovieMagic').toString();

  String lowerCaseEmail = email.toLowerCase();

  try {
    final result = await conn.execute(
        'SELECT id FROM "Users"."Users" WHERE "Email" = \'$lowerCaseEmail\' and "Password" = \'$newPassword\'');
    print(result);
    if (result.isNotEmpty) {
      print(result[0][0]);
      return result[0][0];
    } else {
      return false;
    }
  } catch (error) {
    print('Error signing in: $error');
    return false;
  }
}

Future<dynamic> fetchUserCreds(int id) async {
  final conn = await Connection.open(_endPoint);

  try {
    final result = await conn.execute(
        'SELECT "FirstName", "LastName", "Email" FROM "Users"."Users" WHERE "id" = $id ');
    if (result.isNotEmpty) {
      print(result[0]);
      return result[0];
    } else {
      return false;
    }
  } catch (error) {
    print('Error signing in: $error');
    return false;
  }
}

Future<dynamic> updateUserCreds(String name, String email, int id) async {
  final conn = await Connection.open(_endPoint);
  List splittedName = name.split(" ");
  String firstName = splittedName[0];
  String lastName = splittedName[1];

  try {
    final result = await conn.execute(
        'UPDATE "Users"."Users" SET "FirstName" = \'$firstName\', "LastName" = \'$lastName\', "Email" = \'$email\' WHERE "id" = $id ');
    print(result);
    return true;
    // if (result.isNotEmpty) {
    //   print(result);
    //   return result;
    // } else {
    //   return false;
    // }
  } catch (error) {
    print('Error signing in: $error');
    return false;
  }
}

Future<dynamic> GSignIn(String email, String displayName) async {
  final conn = await Connection.open(_endPoint);

  try {
    final result = await conn
        .execute('SELECT id FROM "Users"."Users" WHERE "Email" = \'$email\'');

    if (result.isNotEmpty) {
      return result[0][0];
    } else {
      final newPassword = Crypt.sha256(email, salt: 'MovieMagic').toString();

      String firstName = displayName.split(' ')[0];
      String lastName = displayName.split(' ')[1];

      final newUser = await conn.execute(
          'INSERT INTO "Users"."Users" VALUES (\'$firstName\', \'$lastName\', \'$email\', \'$newPassword\', \'[]\')');
      signIn(email, newPassword);
    }
  } catch (error) {
    print('Error signing in: $error');
    return false;
  }
}
