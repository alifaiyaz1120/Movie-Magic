import 'package:flutter/material.dart';
import 'Backend/backend.dart';
import 'movie_detail_page.dart';
import 'package:localstorage/localstorage.dart';
import 'login_page.dart';

class WatchListPage extends StatefulWidget {
  const WatchListPage({Key? key}) : super(key: key);

  @override
  State<WatchListPage> createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage> {
  // List movieIds = [];
  @override
  void initState() {
    super.initState();
    getUserCreds();
    _loadMovies();
  }

  ElevatedButton _signOutButton() {
    return ElevatedButton(
      onPressed: _signOut,
      style: ElevatedButton.styleFrom(
        primary: Colors.red,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8,
        minimumSize: Size(300, 50),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Color buttonColor = Color(0xFF242A32);
  List<Map<String, dynamic>> movies = [];

  String name = '';
  String email = '';
  final LocalStorage storage = LocalStorage('MovieApp.json');

  void _editProfileInfo() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    nameController.text = name;
    emailController.text = email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  name = nameController.text;
                  email = emailController.text;
                });
                await updateUserCreds(name, email, storage.getItem('userID'));
                //
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _loadMovies();
  // }

  Future<void> _loadMovies() async {
    // setState((){
    final movieIds = await getWatchList(storage.getItem('userID'));
    // })
    // print(storage.getItem('userID'))
    // print(movieIds);
    // final movieIds = [1, 2, 3, 5];

    for (final movieId in movieIds) {
      try {
        final results = await fetchMovieDetails(movieId);
        setState(() {
          movies.add({
            'id': movieId, // Added movie ID
            'name': results['original_title'],
            'genre': results['genres'][0]['name'],
            'rating': results['vote_average'],
            'releaseYear': int.parse(results['release_date'].substring(0, 4)),
            'duration': results['runtime'],
            'imageURL':
                'https://image.tmdb.org/t/p/w500${results['poster_path']}',
          });
        });
      } catch (error) {
        print('Error loading movies: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '';

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF242A32),
          elevation: 4,
          centerTitle: true,
        ),
        backgroundColor: Color(0xFF242A32),
        body: Center(
            child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _editProfileInfo,
                    style: ElevatedButton.styleFrom(
                      primary: buttonColor,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 8,
                      minimumSize: Size(300, 50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Edit Profile Information',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _signOutButton(),
                  SizedBox(height: 16),
                  Text(
                    'Watch List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...movies.map(
                        (movie) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                    movieId: movie['id'],
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    movie['imageURL'],
                                    width: 100,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${movie['rating']}',
                                            style: TextStyle(
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.category,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${movie['genre']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${movie['releaseYear']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${movie['duration']} min',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )));
  }

// await fetchUserCreds(storage.getItem('userID'));
  void getUserCreds() async {
    try {
      final userData = await fetchUserCreds(storage.getItem('userID'));
      print(userData);
      if (userData.length != 0) {
        setState(() {
          name = userData[0] + " " + userData[1];
          email = userData[2];
        });
      }
    } catch (e) {
      print("Error getting user credentials: $e");
    }
  }

  Future<void> _handleRefresh() async {
    // Reload movies when pull-to-refresh is triggered
    setState(() {
      movies.clear(); // Clear existing movies
    });
    await _loadMovies(); // Load movies again
  }

  void _signOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
